import 'package:flutter_riverpod/legacy.dart';
import 'package:social_media_app/core/services/comment_service.dart';
import 'package:social_media_app/feature/comments/comments_model.dart';
import 'package:social_media_app/feature/comments/comments_state.dart';

final commentViewModelProvider =
    StateNotifierProvider<CommentsViewModel, CommentsState>((ref) {
      return CommentsViewModel(ref.read(commentServiceProvider));
    });

class CommentsViewModel extends StateNotifier<CommentsState> {
  final CommentService _service;
  CommentsViewModel(this._service) : super(const CommentsState());
  Future<void> fetchComments(String postId) async {
    state = state.copyWith(status: CommentsStatus.loading);
    try {
      final comments = await _service.fetchComments(postId);
      final commentsWithReplies = await Future.wait(
        comments.map((comment) async {
          final replies = await _service.fetchReplies(comment.id);
          return CommentModel(
            id: comment.id,
            postId: comment.postId,
            userId: comment.userId,
            parentCommentId: comment.parentCommentId,
            actorName: comment.actorName,
            actorAvatar: comment.actorAvatar,
            replies: replies,
            content: comment.content,
            createdAt: comment.createdAt,
          );
        }),
      );
      state = state.copyWith(
        status: CommentsStatus.fetched,
        commentsList: commentsWithReplies,
      );
    } catch (e) {
      state = state.copyWith(status: CommentsStatus.error, error: e.toString());
    }
  }

  Future<void> fetchReplies(String parentCommentId) async {
    try {
      final replies = await _service.fetchReplies(parentCommentId);
      final updateList = state.commentsList.map((comment) {
        if (comment.id != parentCommentId) return comment;
        return CommentModel(
          id: comment.id,
          postId: comment.postId,
          userId: comment.userId,
          content: comment.content,
          createdAt: comment.createdAt,
          parentCommentId: comment.parentCommentId,
          replies: replies,
          actorAvatar: comment.actorAvatar,
          actorName: comment.actorName,
        );
      }).toList();
      state = state.copyWith(commentsList: updateList);
    } catch (e) {
      state = state.copyWith(status: CommentsStatus.error, error: e.toString());
    }
  }

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    state = state.copyWith(status: CommentsStatus.loading);
    try {
      await _service.addComment(postId: postId, content: content);
      final comments =  await _service.fetchComments(postId);
      state = state.copyWith(
      status: CommentsStatus.fetched,
      commentsList: comments,
    );
    } catch (e) {
      state = state.copyWith(status: CommentsStatus.error, error: e.toString());
    }
  }

  Future<void> addReply({
    required String postId,
    required String parentCommentId,
    required String content,
  }) async {
    state = state.copyWith(status: CommentsStatus.loading);
    try {
      await _service.replyComment(
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
      );
      await fetchReplies(parentCommentId);
      state = state.copyWith(
      status: CommentsStatus.fetched,
    );
    } catch (e) {
      state = state.copyWith(status: CommentsStatus.error, error: e.toString());
    }
  }

  Future<void> deleteComment({
    required String commentId,
    required String postId,
  }) async {
    state = state.copyWith(status: CommentsStatus.loading);
    try {
      await _service.deleteComment(commentId: commentId);

      final updateList = state.commentsList
          .where((c) => c.id != commentId)
          .toList();
      state = state.copyWith(
        status: CommentsStatus.delete,
        commentsList: updateList,
      );
    } catch (e) {
      state = state.copyWith(status: CommentsStatus.error, error: e.toString());
    }
  }
}
