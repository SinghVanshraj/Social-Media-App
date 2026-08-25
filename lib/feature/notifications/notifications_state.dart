import 'package:social_media_app/feature/notifications/notifications_model.dart';

enum NotificationStatus { initial, loading, fetched, error }

class NotificationsState {
  final NotificationStatus status;
  final List<NotificationsModel> list;
  final String? error;
  final int unreadCount;

  const NotificationsState({
    this.status = NotificationStatus.initial,
    this.list = const [],
    this.error,
    this.unreadCount = 0
  });

  bool get isLoading => status == NotificationStatus.loading;

  NotificationsState copyWith({
    NotificationStatus? status,
    List<NotificationsModel>? list,
    String? error,
    int? unreadCount
  }) {
    return NotificationsState(
      status: status ?? this.status,
      list: list ?? this.list,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount
    );
  }
}
