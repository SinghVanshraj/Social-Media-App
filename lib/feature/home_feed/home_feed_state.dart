import 'package:flutter_riverpod/legacy.dart';
import 'package:social_media_app/core/services/post_service.dart';
import 'package:social_media_app/feature/home_feed/home_feed_model.dart';
import 'package:social_media_app/feature/home_feed/home_feed_view_model.dart';

enum HomeFeedStatus { initial, fetched, loading, error }

final homeFeedViewModelProvider =
    StateNotifierProvider<HomeFeedViewModel, HomeFeedState>((ref) {
      return HomeFeedViewModel(ref.read(postServiceProvider));
    });

class HomeFeedState {
  final HomeFeedStatus status;
  final List<HomeFeedModel> posts;
  final String? error;
  final bool hasMore;
  final bool isLoadingMore;

  const HomeFeedState({
    this.status = HomeFeedStatus.initial,
    this.posts = const [],
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
  });

  bool get isLoading => status == HomeFeedStatus.loading;
  // bool get isFetched => status == HomeFeedStatus.fetched;

  HomeFeedState copyWith({
    HomeFeedStatus? status,
    List<HomeFeedModel>? posts,
    String? error,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HomeFeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}