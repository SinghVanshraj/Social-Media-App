// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/feature/comments/comments_view.dart';
import 'package:social_media_app/feature/home_feed/home_feed_model.dart';
import 'package:social_media_app/feature/home_feed/home_feed_state.dart';
import 'package:social_media_app/feature/profile/profile_view.dart';
import 'package:social_media_app/helpers/full_screen_image.dart';
import 'package:social_media_app/helpers/full_screen_video_player.dart';

class PostCard extends ConsumerStatefulWidget {
  final HomeFeedModel post;
  const PostCard({super.key, required this.post});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileView(userId: post.userId))),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF16181C),
                  backgroundImage: post.avatarUrl != null
                      ? NetworkImage(post.avatarUrl!)
                      : null,
                  child: post.avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.name ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '@${post.username ?? ''}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),

        if (post.caption != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              post.caption!,
              style: const TextStyle(
                color: Color(0xFFE7E9EA),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),

        if (post.caption != null) const SizedBox(height: 10),
        const SizedBox(height: 8),
        if (post.mediaUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PostImages(mediaUrl: post.mediaUrl),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => ref
                    .read(homeFeedViewModelProvider.notifier)
                    .toggleLike(post.id),
                child: Row(
                  children: [
                    Icon(
                      post.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: post.isLiked ? Colors.pinkAccent : Colors.grey,
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.likeCount.toString(),
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CommentsView(postId: post.id),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.grey,
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.commentCount.toString(),
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              Icon(Icons.share_outlined, color: Colors.grey[600], size: 22),

              const Spacer(),

              Icon(
                Icons.bookmark_border_rounded,
                color: Colors.grey[600],
                size: 22,
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(
            _timeAgo(post.createdAt),
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ),

        Divider(color: Colors.grey[900], height: 1),
      ],
    );
  }

  String _timeAgo(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }
}

class _PostImages extends StatefulWidget {
  final List<String> mediaUrl;
  const _PostImages({required this.mediaUrl});

  @override
  State<_PostImages> createState() => __PostImagesState();
}

class __PostImagesState extends State<_PostImages> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _isVideo(String url) {
    url = url.toLowerCase();
    return url.endsWith(".mp4") ||
        url.endsWith(".mov") ||
        url.endsWith(".webm") ||
        url.endsWith(".avi");
  }

  void _openMedia(int index) {
    final url = widget.mediaUrl[index];

    if (_isVideo(url)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FullScreenVideoPlayer(mediaUrl: url)),
      );
    } else {
      final imageUrls = widget.mediaUrl.where((n) => !_isVideo(url)).toList();
      final imageUrl = imageUrls.indexOf(url).clamp(0, imageUrls.length - 1);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              FullScreenImage(mediaUrl: imageUrls, initialIndex: imageUrl),
        ),
      );
    }
  }

  Widget _buildItem(String url, int index) {
    final isVideo = _isVideo(url);

    return GestureDetector(
      onTap: () => _openMedia(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isVideo)
            Container(
              color: const Color(0xFF16181C),
              child: const Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 56,
              ),
            )
          else
            Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(
                      color: const Color(0xFF16181C),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blueAccent,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF16181C),
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaUrl.isEmpty) return const SizedBox.shrink();

    if (widget.mediaUrl.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(12),
        child: AspectRatio(
          aspectRatio: 1,
          child: _buildItem(widget.mediaUrl.first, 0),
        ),
      );
    }
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.mediaUrl.length,
              onPageChanged: (value) => setState(() => _currentPage = value),
              itemBuilder: (context, index) =>
                  _buildItem(widget.mediaUrl[index], index),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.mediaUrl.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.blueAccent
                    : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
