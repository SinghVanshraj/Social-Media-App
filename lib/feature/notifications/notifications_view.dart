// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/widgets/error_offline_widgets.dart';
import 'package:social_media_app/core/widgets/responsive_wrapper.dart';
import 'package:social_media_app/feature/notifications/notifications_model.dart';
import 'package:social_media_app/feature/notifications/notifications_state.dart';
import 'package:social_media_app/feature/notifications/notifications_view_model.dart';

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key});

  @override
  ConsumerState<NotificationsView> createState() =>
      _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(notificationsViewModelProvider.notifier).clearUnreadCount();
      ref.read(notificationsViewModelProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsViewModelProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: Colors.grey[900]),
        ),
      ),
      body: ResponsiveContent(
        maxWidth: Breakpoints.maxFeedWidth,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(NotificationsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (state.status == NotificationStatus.error) {
      return AppErrorView(
        error: state.error,
        onRetry: () =>
            ref.read(notificationsViewModelProvider.notifier).refresh(),
      );
    }
    if (state.list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 56,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 12),
              const Text(
                'No notifications yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'When people interact with your posts or profile, you\'ll see updates here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: Colors.blueAccent,
      backgroundColor: Colors.black,
      onRefresh: () =>
          ref.read(notificationsViewModelProvider.notifier).refresh(),
      child: ListView.separated(
        itemCount: state.list.length,
        separatorBuilder: (_, __) =>
            Divider(color: Colors.grey[950], height: 1),
        itemBuilder: (context, index) {
          final item = state.list[index];
          return _buildNotificationItem(item);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationsModel item) {
    return Container(
      color: Colors.blueAccent.withValues(alpha: 0.02),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.icon,
            color: item.type.contains('like')
                ? Colors.pinkAccent
                : Colors.blueAccent,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.timeAgo,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.message,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
