import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/services/connectivity_service.dart';
import 'package:social_media_app/core/utils/error_handler.dart';

class AppOfflineView extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;
  final bool compact;

  const AppOfflineView({
    super.key,
    this.onRetry,
    this.message,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.amberAccent[200], size: 28),
              const SizedBox(height: 8),
              Text(
                message ?? 'You are currently offline.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Retry'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.amberAccent.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.amberAccent,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "You're Offline",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ??
                  'No internet connection detected. Please check your network and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Check Connection & Retry',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16181C),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey[800]!),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppErrorView extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final String? title;
  final IconData? icon;
  final String retryButtonText;

  const AppErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.title,
    this.icon,
    this.retryButtonText = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    final isOffline = AppErrorHandler.isOfflineError(error);
    if (isOffline) {
      return AppOfflineView(onRetry: onRetry);
    }

    final errorMessage = AppErrorHandler.getErrorMessage(error);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                color: Colors.redAccent[100],
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title ?? 'Something went wrong',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  retryButtonText,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16181C),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey[800]!),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OfflineBanner extends ConsumerStatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner> {
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);
    final isOffline = connectivityAsync.value == ConnectivityStatus.offline;

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            offset: isOffline ? Offset.zero : const Offset(0, -2.5),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: isOffline ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !isOffline,
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1408),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amberAccent.withValues(alpha: 0.7),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            color: Colors.amberAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No Internet Connection',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Offline mode active. Reconnecting...',
                                  style: TextStyle(
                                    color: Color(0xFFD1D5DB),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _isRetrying
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.amberAccent,
                                  ),
                                )
                              : InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    setState(() => _isRetrying = true);
                                    await ref
                                        .read(connectivityServiceProvider)
                                        .checkConnectivity(force: true);
                                    if (mounted) {
                                      setState(() => _isRetrying = false);
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Icon(
                                      Icons.refresh_rounded,
                                      size: 20,
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
