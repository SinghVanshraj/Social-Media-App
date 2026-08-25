import 'dart:developer';

import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/services/supabase_service.dart';
import 'package:social_media_app/feature/notifications/notifications_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final _db = SupabaseService.database.from('notifications');
  RealtimeChannel? _channel;

  Future<List<NotificationsModel>> fetchNotifications() async {
    try {
      final user = SupabaseService.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final data = await _db
          .select(
            '''id, type, created_at, post_id, comment_id,users!notifications_actor_id_fkey(full_name,avatar_url) ''',
          )
          .eq('recipient_id', user.id)
          .order('created_at', ascending: false)
          .limit(20);

      return data.map((n) => NotificationsModel.fromJson(n)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  void listenToNotifications({required VoidCallback onNotification}) {
    final user = SupabaseService.auth.currentUser;
    if (user == null) return;
    _channel?.unsubscribe();
    _channel = SupabaseService.database
        .channel('notifications_${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'recipient_id',
            value: user.id,
          ),
          callback: (payload) {
            onNotification();
          },
        )
        .subscribe();
  }

  Future<void> disposeRealtime() async {
    await _channel?.unsubscribe();
    _channel = null;
  }
  // Future<void> markAsRead(String id) async {
  //   try {
  //     await _db.update({'is_read': true}).eq('id', id);
  //   } catch (e) {
  //     log(e.toString());
  //     rethrow;
  //   }
  // }

  // Future<void> markAllAsRead() async {
  //   try {

  //     final user = SupabaseService.auth.currentUser;
  //     if (user == null) throw Exception('No authenticated user');

  //     await _db.update({'is_read': true}).eq('recipient_id', user.id).eq('is_read', false);
  //   } catch (e) {
  //     log(e.toString());
  //     rethrow;
  //   }
  // }

  // Future<int> getUnreadCount() async {
  //   try {
  //     final user = SupabaseService.auth.currentUser;
  //     if (user == null) return 0;

  //     final response = await _db.count().eq('recipient_id', user.id).eq('is_read', false);
  //     return response;
  //   } catch (e) {
  //     log(e.toString());
  //     return 0;
  //   }
  // }
}

final notificationServiceProvider = Provider((_) => NotificationService());
