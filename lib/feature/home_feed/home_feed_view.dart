import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/utils/error_handler.dart';
import 'package:social_media_app/core/widgets/error_offline_widgets.dart';
import 'package:social_media_app/core/widgets/post_card.dart';
import 'package:social_media_app/core/widgets/responsive_wrapper.dart';
import 'package:social_media_app/feature/auth/auth_view_model.dart';
import 'package:social_media_app/feature/home_feed/home_feed_state.dart';
import 'package:social_media_app/feature/profile/profile_view_model.dart';

class HomeFeedView extends ConsumerStatefulWidget {
  const HomeFeedView({super.key});

  @override
  ConsumerState<HomeFeedView> createState() => _HomeFeedViewState();
}

class _HomeFeedViewState extends ConsumerState<HomeFeedView> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authViewModelProvider);
      if (authState.isAuthenticated) {
        ref.read(homeFeedViewModelProvider.notifier).fetchPost();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 200) {
      ref.read(homeFeedViewModelProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeFeedViewModelProvider);

    ref.listen<HomeFeedState>(homeFeedViewModelProvider, (prev, next) {
      if (next.status == HomeFeedStatus.error &&
          next.posts.isNotEmpty &&
          next.error != null) {
        AppSnackBar.showError(context, next.error);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        title: const Text(
          'Spark',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Consumer(
            builder: (context, ref, _) {
              final profile = ref.watch(profileViewModelProvider).user;
              return CircleAvatar(
                backgroundColor: const Color(0xFF16181C),
                backgroundImage: profile?.avatarUrl != null &&
                        profile!.avatarUrl!.trim().isNotEmpty
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null ||
                        profile!.avatarUrl!.trim().isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 16)
                    : null,
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.auto_awesome_mosaic_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () => Navigator.pushNamed(context, '/interests'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: Colors.grey[900], height: 1),
        ),
      ),
      body: ResponsiveContent(
        maxWidth: Breakpoints.maxFeedWidth,
        child: _buildBody(state),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent[400],
        shape: const CircleBorder(),
        onPressed: () => Navigator.pushNamed(context, '/create-post'),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _buildBody(HomeFeedState state) {
    if (state.isLoading && state.posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      );
    }

    if (state.status == HomeFeedStatus.error && state.posts.isEmpty) {
      return AppErrorView(
        error: state.error,
        onRetry: () =>
            ref.read(homeFeedViewModelProvider.notifier).fetchPost(),
      );
    }

    if (state.posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.feed_outlined, size: 56, color: Colors.grey[700]),
              const SizedBox(height: 16),
              const Text(
                'Welcome to your feed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Follow accounts, pick interests, or share a new post to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(homeFeedViewModelProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh Feed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16181C),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey[800]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.blueAccent,
      backgroundColor: Colors.black,
      onRefresh: () => ref.read(homeFeedViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.posts.length) {
            return state.isLoadingMore
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }
          return PostCard(post: state.posts[index]);
        },
      ),
    );
  }
}
