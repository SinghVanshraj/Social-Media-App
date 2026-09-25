import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/widgets/error_offline_widgets.dart';
import 'package:social_media_app/core/widgets/responsive_wrapper.dart';
import 'package:social_media_app/feature/profile/profile_view.dart';
import 'package:social_media_app/feature/search/search_state.dart';
import 'package:social_media_app/feature/search/search_view_model.dart';
import 'package:social_media_app/helpers/full_one_post.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Breakpoints.maxFeedWidth),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF16181C),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (query) =>
                    ref.read(searchViewModelProvider.notifier).search(query),
                decoration: InputDecoration(
                  hintText: 'Search metrics, trends, handles...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                  suffixIcon: _controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            ref
                                .read(searchViewModelProvider.notifier)
                                .clearSearch();
                            setState(() {});
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.grey[500],
                            size: 18,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey[500],
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: Colors.grey[900]),
        ),
      ),
      body: ResponsiveContent(
        maxWidth: Breakpoints.maxFeedWidth,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.status == SearchStatus.initial) return _buildTrendingSection();

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
      );
    }

    if (state.status == SearchStatus.error) {
      return AppErrorView(
        error: state.error,
        onRetry: () {
          if (_controller.text.isNotEmpty) {
            ref.read(searchViewModelProvider.notifier).search(_controller.text);
          }
        },
      );
    }

    if (state.users.isEmpty && state.posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 12),
              const Text(
                'No results found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try searching for different keywords or usernames.',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      children: [
        if (state.users.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'People',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...state.users.map(
            (user) => ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 2,
              ),
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF16181C),
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
              ),
              title: Text(
                user.username ?? 'Unknown',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                user.fullName ?? '',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileView(userId: user.id),
                  ),
                );
              },
            ),
          ),
        ],
        if (state.posts.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Posts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...state.posts.map(
            (post) => ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF16181C),
                backgroundImage: post.avatarUrl != null
                    ? NetworkImage(post.avatarUrl!)
                    : null,
                child: post.avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 18)
                    : null,
              ),
              title: Text(
                post.caption ?? 'No caption',
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                "@${post.username ?? ''}",
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              trailing: post.mediaUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        post.mediaUrl.first,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullOnePost(post: post),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrendingSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Trends optimized for you',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _trendingItem(
          'Engineering • Trending Frameworks',
          '#Flutter3',
          '48.9K context points',
        ),
        _trendingItem(
          'Interaction Systems',
          'Micro Architecture UI',
          '14.2K interaction flows',
        ),
        _trendingItem(
          'Artificial Intelligence',
          'Agentic Workflows Design',
          '112K discussions',
        ),
      ],
    );
  }

  Widget _trendingItem(String category, String topic, String volume) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            topic,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(volume, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
