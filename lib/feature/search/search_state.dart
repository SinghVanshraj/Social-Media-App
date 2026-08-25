import 'package:social_media_app/feature/home_feed/home_feed_model.dart';
import 'package:social_media_app/feature/profile/profile_model.dart';

enum SearchStatus { initial, loading, fetched, error }

class SearchState {
  final SearchStatus status;
  final List<ProfileModel> users;
  final List<HomeFeedModel> posts;
  final String? error;

  const SearchState({
    this.status = SearchStatus.initial,
    this.posts = const [],
    this.users = const [],
    this.error,
  });

  bool get isLoading => status == SearchStatus.loading;

  SearchState copyWith({
    SearchStatus? status,
    List<ProfileModel>? users,
    List<HomeFeedModel>? posts,
    String? error,
  }) {
    return SearchState(
      status: status ?? this.status,
      users: users ?? this.users,
      posts: posts ?? this.posts,
      error: error ?? this.error,
    );
  }
}
