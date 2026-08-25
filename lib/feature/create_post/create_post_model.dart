class CreatePostModel {
  final String userId;
  final String? caption;
  final List<String>? mediaUrl;

  CreatePostModel({
    required this.userId,
    this.caption,
    this.mediaUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'caption': caption,
      'media_url': mediaUrl,
    };
  }

  factory CreatePostModel.fromJson(Map<String, dynamic> json) {
    return CreatePostModel(
      userId: json['user_id'] as String,
      caption: json['caption'] as String?,
      mediaUrl: List<String>.from(json['media_url'] ?? []),
    );
  }
}