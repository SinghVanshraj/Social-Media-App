import 'package:social_media_app/feature/comments/comments_model.dart';
import 'package:social_media_app/feature/home_feed/home_feed_model.dart';
import 'package:social_media_app/feature/profile/profile_model.dart';

enum ProfileStatus { initial, fetched, uploaded, updated, loading, error }

class ProfileState {
  final ProfileStatus status;
  final ProfileModel? user;
  final List<HomeFeedModel>? post;
  final List<CommentModel>? reply;
  final String? error;
  final bool isOwnProfile;
  final bool isFollowing;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.post,
    this.reply,
    this.isOwnProfile = false,
    this.isFollowing = false,
    this.error,
  });

  bool get isFetching => status == ProfileStatus.loading;
  bool get isFetched => status == ProfileStatus.fetched;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? user,
    String? error,
    List<HomeFeedModel>? post,
    List<CommentModel>? reply,
    bool? isOwnProfile,
    bool? isFollowing,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      post: post ?? this.post,
      reply: reply ?? this.reply,
      isOwnProfile: isOwnProfile ?? this.isOwnProfile,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
