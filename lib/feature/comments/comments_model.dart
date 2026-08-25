class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String? parentCommentId;
  final String content;
  final DateTime createdAt;
  final String? actorName;
  final String? actorAvatar;
  final List<CommentModel> replies;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentCommentId,
    required this.content,
    required this.createdAt,
    this.actorName,
    this.actorAvatar,
    this.replies = const [],
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }
  factory CommentModel.fromJson(Map<String, dynamic> json) {
  final user = json['users'] as Map<String, dynamic>?;

  return CommentModel(
    id: json['id'] as String,
    postId: json['post_id'] as String,
    userId: json['user_id'] as String,
    parentCommentId: json['parent_comment_id'] as String?,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),

    actorName: user?['full_name'] as String? ?? 'Someone',
    actorAvatar: user?['avatar_url'] as String?,

    replies: (json['replies'] as List<dynamic>? ?? [])
        .map(
          (r) => CommentModel.fromJson(
            r as Map<String, dynamic>,
          ),
        )
        .toList(),
  );
}
}
