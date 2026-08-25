import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/widgets/post_card.dart';
import 'package:social_media_app/feature/auth/auth_view_model.dart';
import 'package:social_media_app/feature/home_feed/home_feed_state.dart';
import 'package:social_media_app/feature/profile/profile_view.dart';
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
    if (state.posts.isEmpty && state.isLoading) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }
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
          padding: EdgeInsets.all(10.0),
          child: Consumer(
            builder: (context, ref, _) {
              final profile = ref.watch(profileViewModelProvider).user;
              return CircleAvatar(
              backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl.toString()) : null,
              
              child: profile?.avatarUrl == null ? const Icon(Icons.person, color: Colors.white, size: 16) : null,
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
      
      body: _buildBody(state),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.error ?? 'Something went wrong',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  ref.read(homeFeedViewModelProvider.notifier).fetchPost(),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.blueAccent,
      backgroundColor: Colors.black,
      onRefresh: () => ref.read(homeFeedViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _controller,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if(index == state.posts.length) {
            return state.isLoadingMore ? const Padding(
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
