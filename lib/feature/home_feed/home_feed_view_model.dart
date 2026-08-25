import 'dart:developer';

import 'package:flutter_riverpod/legacy.dart';
import 'package:social_media_app/core/services/post_service.dart';
import 'package:social_media_app/feature/home_feed/home_feed_model.dart';
import 'package:social_media_app/feature/home_feed/home_feed_state.dart';

final homeFeedViewModelProvider =
    StateNotifierProvider<HomeFeedViewModel, HomeFeedState>((ref) {
  return HomeFeedViewModel(ref.read(postServiceProvider));
});

class HomeFeedViewModel extends StateNotifier<HomeFeedState> {
  final PostService _service;
  static const int _limit = 10;
  DateTime? _cursor;
  HomeFeedViewModel(this._service) : super(const HomeFeedState());

  Future<void> fetchPost() async {
    _cursor = null;
    state = state.copyWith(status: HomeFeedStatus.loading);

    try {
      final posts = await _service.fetchedPost(cursor: _cursor, limit: _limit);
      _cursor = posts.isNotEmpty ? posts.last.createdAt : null;

      state = state.copyWith(
        posts: posts,
        status: HomeFeedStatus.fetched,
        hasMore: posts.length == _limit,
      );
    } catch (e) {
      log(e.toString());
      state = state.copyWith(status: HomeFeedStatus.error, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final posts = await _service.fetchedPost(cursor: _cursor, limit: _limit);
      if (posts.isNotEmpty) _cursor = posts.last.createdAt;
      state = state.copyWith(
        posts: [...state.posts, ...posts],
        status: HomeFeedStatus.fetched,
        hasMore: posts.length == _limit,
        isLoadingMore: false,
      );
    } catch (e) {
      log(e.toString());
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    _cursor = null;
    state = const HomeFeedState();
    await fetchPost();
  }

  Future<void> toggleLike(String postId) async {
    final index = state.posts.indexWhere((p) => p.id == postId);

    if (index == -1) return;

    final targetPost = state.posts[index];
    final currentlyLiked = targetPost.isLiked;

    final updatedPost = HomeFeedModel(
      id: targetPost.id,
      userId: targetPost.userId,
      caption: targetPost.caption,
      mediaUrl: targetPost.mediaUrl,
      likeCount: currentlyLiked
          ? targetPost.likeCount - 1
          : targetPost.likeCount + 1,
      commentCount: targetPost.commentCount,
      createdAt: targetPost.createdAt,
      name: targetPost.name,
      username: targetPost.username,
      avatarUrl: targetPost.avatarUrl,
      isLiked: !currentlyLiked,
    );

    final updateList = List<HomeFeedModel>.from(state.posts);
    updateList[index] = updatedPost;
    state = state.copyWith(posts: updateList);

    try {
      if (currentlyLiked) {
        await _service.unLikePost(postId);
      } else {
        await _service.likePost(postId);
      }
    } catch (e) {
      log('Failed to toggle like: $e');
      final revertedList = List<HomeFeedModel>.from(state.posts);
      revertedList[index] = targetPost;
      state = state.copyWith(posts: revertedList);
    }
  }
}
