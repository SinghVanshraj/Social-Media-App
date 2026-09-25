import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

enum ConnectivityStatus { online, offline, checking }

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final connectivityStatusProvider =
    StreamNotifierProvider<ConnectivityStatusNotifier, ConnectivityStatus>(() {
  return ConnectivityStatusNotifier();
});

class ConnectivityStatusNotifier extends StreamNotifier<ConnectivityStatus> {
  @override
  Stream<ConnectivityStatus> build() async* {
    final service = ref.watch(connectivityServiceProvider);
    yield service.currentStatus;
    yield* service.statusStream;
  }
}

class ConnectivityService {
  final _controller = StreamController<ConnectivityStatus>.broadcast();
  ConnectivityStatus _currentStatus = ConnectivityStatus.online;
  Timer? _timer;
  bool _isChecking = false;

  Stream<ConnectivityStatus> get statusStream => _controller.stream;
  ConnectivityStatus get currentStatus => _currentStatus;
  bool get isOnline => _currentStatus == ConnectivityStatus.online;
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  ConnectivityService({bool autoStart = true}) {
    if (autoStart) {
      _startMonitoring();
    }
  }

  void markOffline() {
    if (_currentStatus != ConnectivityStatus.offline) {
      _currentStatus = ConnectivityStatus.offline;
      if (!_controller.isClosed) {
        _controller.add(ConnectivityStatus.offline);
      }
    }
  }

  void markOnline() {
    if (_currentStatus != ConnectivityStatus.online) {
      _currentStatus = ConnectivityStatus.online;
      if (!_controller.isClosed) {
        _controller.add(ConnectivityStatus.online);
      }
    }
  }

  void _startMonitoring() {
    // Initial check in background after startup
    Future.delayed(const Duration(seconds: 2), () {
      checkConnectivity();
    });
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      checkConnectivity();
    });
  }

  Future<ConnectivityStatus> checkConnectivity({bool force = false}) async {
    if (_isChecking && !force) return _currentStatus;
    _isChecking = true;

    try {
      bool hasConnection = false;

      // 1. Try DNS lookups on common reliable hosts
      if (!kIsWeb) {
        const testHosts = ['google.com', 'cloudflare.com', 'supabase.co', 'one.one.one.one'];
        for (final host in testHosts) {
          try {
            final result = await InternetAddress.lookup(host)
                .timeout(const Duration(seconds: 2));
            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
              hasConnection = true;
              break;
            }
          } catch (_) {
            continue;
          }
        }
      }

      // 2. If DNS lookups were inconclusive, test HTTP endpoint reachability
      if (!hasConnection) {
        const testUrls = [
          'https://vktehtsyufpbjqefatnq.supabase.co/rest/v1/',
          'https://www.google.com',
          'https://www.cloudflare.com',
        ];
        for (final url in testUrls) {
          try {
            final res = await http
                .get(Uri.parse(url))
                .timeout(const Duration(seconds: 3));
            if (res.statusCode > 0) {
              hasConnection = true;
              break;
            }
          } catch (_) {
            continue;
          }
        }
      }

      final newStatus =
          hasConnection ? ConnectivityStatus.online : ConnectivityStatus.offline;

      _currentStatus = newStatus;
      if (!_controller.isClosed) {
        _controller.add(newStatus);
      }
      return newStatus;
    } catch (_) {
      return _currentStatus;
    } finally {
      _isChecking = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
