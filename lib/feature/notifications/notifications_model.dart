import 'package:flutter/material.dart';

class NotificationsModel {
  final String id;
  final String type;
  final String actorName;
  final String? actorAvatar;
  final DateTime createdAt;
  final String? postId;
  final String? commentId;

  NotificationsModel({
    required this.id,
    required this.type,
    required this.actorName,
    this.actorAvatar,
    required this.createdAt,
    this.postId,
    this.commentId,
  });

  String get title {
    switch(type) {
      case 'follow':
        return '$actorName followed you';
      case 'like_post':
        return '$actorName liked your post';
      case 'like_comment':
        return '$actorName liked your comment';
      case 'comment':
        return '$actorName commented on your post';
      case 'reply':
        return '$actorName replied to your comment';
      default:
        return '$actorName interacted with you';
    }
  }

  String get message {
    switch(type) {
      case 'follow':
        return 'Check out their profile';
      case 'like_post':
        return 'Your post is getting attention';
      case 'like_comment':
        return 'Your comment is getting attention';
      case 'comment':
        return 'See what they said';
      case 'reply':
        return 'See their reply';
      default:
        return '';
    }
  }

  IconData get icon {
    switch(type) {
      case 'follow':
        return Icons.person_add_alt_1;
      case 'like_post':
      case 'like_comment':
        return Icons.favorite_rounded;
      case 'comment':
      case 'reply':
        return Icons.chat_bubble_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24)   return '${diff.inHours}h';
    if (diff.inDays < 7)     return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    final actor = json['users'] as Map<String, dynamic>?;
    return NotificationsModel(
      id:           json['id'] as String,
      type:         json['type'] as String,
      actorName:    actor?['full_name'] as String? ?? 'Someone',
      actorAvatar:  actor?['avatar_url'] as String?,
      createdAt:    DateTime.parse(json['created_at'] as String),
      postId:       json['post_id'] as String?,
      commentId:    json['comment_id'] as String?,
    );
  }
}
