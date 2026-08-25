// ignore_for_file: unnecessary_underscores

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/feature/comments/comments_model.dart';
import 'package:social_media_app/feature/comments/comments_state.dart';
import 'package:social_media_app/feature/comments/comments_view_model.dart';
import 'package:social_media_app/feature/profile/profile_view_model.dart';

class CommentsView extends ConsumerStatefulWidget {
  final String postId;
  const CommentsView({super.key, required this.postId});

  static Future<void> show(BuildContext context, String postId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsView(postId: postId),
    );
  }

  @override
  ConsumerState<CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends ConsumerState<CommentsView> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  String? _replyToId;
  String? _replyToName;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(commentViewModelProvider.notifier)
          .fetchComments(widget.postId),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _startReply(String commentId, String name) {
    setState(() {
      _replyToId = commentId;
      _replyToName = name;
    });
    FocusScope.of(context).requestFocus(_inputFocusNode);
  }

  void _cancelReply() {
    setState(() {
      _replyToId = null;
      _replyToName = null;
    });
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    _commentController.clear();

    if (_replyToId != null) {
      await ref
          .read(commentViewModelProvider.notifier)
          .addReply(
            postId: widget.postId,
            parentCommentId: _replyToId!,
            content: content,
          );
      _cancelReply();
    } else {
      await ref
          .read(commentViewModelProvider.notifier)
          .addComment(postId: widget.postId, content: content);
    }
  }

  ImageProvider? _getAvatarProvider(String? urlOrPath) {
    if (urlOrPath == null || urlOrPath.trim().isEmpty) return null;
    final trimmed = urlOrPath.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }
    return FileImage(File(trimmed));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentViewModelProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Comments',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey[900], height: 1),

            Expanded(child: _buildBody(state)),

            if (_replyToId != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF1E1E1E),
                child: Row(
                  children: [
                    Text(
                      "Replying to $_replyToName",
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),

            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  border: Border(top: BorderSide(color: Colors.grey[900]!)),
                ),
                child: Row(
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final profile = ref.watch(profileViewModelProvider).user;
                        final avatarProvider = _getAvatarProvider(profile?.avatarUrl);

                        return CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF262626),
                          backgroundImage: avatarProvider,
                          child: avatarProvider == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 16,
                                )
                              : null,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262626),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _commentController,
                          focusNode: _inputFocusNode,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: _replyToId != null
                                ? 'Write a reply...'
                                : 'Add a comment...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sendComment,
                      icon: const Icon(Icons.arrow_upward_rounded),
                      color: Colors.blueAccent,
                      iconSize: 22,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blueAccent.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(CommentsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
    }

    if (state.status == CommentsStatus.error || state.commentsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey[700]),
            const SizedBox(height: 12),
            Text(
              'No comments yet',
              style: TextStyle(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Start the conversation.',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: state.commentsList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final comment = state.commentsList[index];
        return _buildCommentItem(comment);
      },
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    debugPrint(
      'COMMENT ${comment.id}: ${comment.content} | '
      'REPLIES COUNT: ${comment.replies.length}',
    );

    final avatarProvider = _getAvatarProvider(comment.actorAvatar);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF262626),
                backgroundImage: avatarProvider,
                child: avatarProvider == null
                    ? const Icon(Icons.person, color: Colors.grey, size: 18)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.actorName ?? "Unknown",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${comment.timeAgo}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      comment.content,
                      style: const TextStyle(
                        color: Color(0xFFE7E9EA),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _startReply(
                            comment.id,
                            comment.actorName ?? "Unknown",
                          ),
                          child: Text(
                            "Reply",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            ref
                                .read(commentViewModelProvider.notifier)
                                .deleteComment(
                                  commentId: comment.id,
                                  postId: comment.postId,
                                );
                          },
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.grey[700],
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 10),
              child: Column(
                children: comment.replies.map((reply) {
                  final replyAvatarProvider = _getAvatarProvider(reply.actorAvatar);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF262626),
                          backgroundImage: replyAvatarProvider,
                          child: replyAvatarProvider == null
                              ? const Icon(Icons.person, color: Colors.grey, size: 12)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reply.actorName ?? comment.actorName ?? "Unknown",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reply.content,
                                style: const TextStyle(
                                  color: Color(0xFFD0D0D0),
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}