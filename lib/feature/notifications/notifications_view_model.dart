import 'package:flutter_riverpod/legacy.dart';
import 'package:social_media_app/core/services/notification_service.dart';
import 'package:social_media_app/feature/notifications/notifications_state.dart';

final notificationsViewModelProvider =
    StateNotifierProvider<NotificationsViewModel, NotificationsState>((ref) {
      return NotificationsViewModel(ref.read(notificationServiceProvider));
    });

class NotificationsViewModel extends StateNotifier<NotificationsState> {
  final NotificationService _service;
  NotificationsViewModel(this._service) : super(const NotificationsState()) {
    _service.listenToNotifications(onNotification: () => _onNewNotification());
  }

  Future<void> refresh() => fetchNotifications();

  void _onNewNotification() {
    state = state.copyWith(
      unreadCount: state.unreadCount+1
    );

    fetchNotifications();
  }

  void clearUnreadCount() {
    state = state.copyWith(unreadCount: 0);
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(status: NotificationStatus.loading);
    try {
      final result = await _service.fetchNotifications();
      state = state.copyWith(
        status: NotificationStatus.fetched,
        list: result,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        error: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _service.disposeRealtime();
    super.dispose();
  }
}
