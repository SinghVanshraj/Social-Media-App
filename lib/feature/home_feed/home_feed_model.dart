class HomeFeedModel {
  final String id;
  final String userId;
  final String? caption;
  final List<String> mediaUrl;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final String? name;
  final String? username;
  final String? avatarUrl;
  final bool isLiked;

  const HomeFeedModel({
    required this.id,
    required this.userId,
    this.caption,
    required this.mediaUrl,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.name,
    this.username,
    this.avatarUrl,
    required this.isLiked,
  });

  factory HomeFeedModel.fromJson(Map<String, dynamic> json) {
    return HomeFeedModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      caption: json['caption'] as String?,
      mediaUrl: List<String>.from(json['media_url'] ?? []),
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      name: json['users']?['full_name'] as String?,
      username: json['users']?['username'] as String?,
      avatarUrl: json['users']?['avatar_url'] as String?,
      isLiked: json['is_liked'] ?? false,
    );
  }
}