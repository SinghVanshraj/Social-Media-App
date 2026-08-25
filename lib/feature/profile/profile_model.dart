class ProfileModel {
  final String id;
  final String? username;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    this.username,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'posts_count': postsCount,
      'followers_count': followersCount,
      'following_count': followingCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      postsCount: json['posts_count'] ?? 0,        
      followersCount: json['followers_count'] ?? 0, 
      followingCount: json['following_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}