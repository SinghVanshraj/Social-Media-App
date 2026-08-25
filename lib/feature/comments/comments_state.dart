import 'package:social_media_app/feature/comments/comments_model.dart';

enum CommentsStatus { initial, fetched, upload, delete, loading, error }

class CommentsState {
  final CommentsStatus status;
  final List<CommentModel> commentsList;
  final String? error;

  const CommentsState({
    this.status = CommentsStatus.initial,
    this.commentsList = const [],
    this.error,
  });

  bool get isLoading => status == CommentsStatus.loading;

  CommentsState copyWith({
    CommentsStatus? status,
    List<CommentModel>? commentsList,
    String? error,
  }) {
    return CommentsState(
      status: status ?? this.status,
      commentsList: commentsList ?? this.commentsList,
      error: error,
    );
  }
}