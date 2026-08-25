// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/services/supabase_service.dart';
import 'package:social_media_app/feature/auth/auth_view_model.dart';
import 'package:social_media_app/feature/profile/profile_view_model.dart';
import 'package:social_media_app/helpers/full_one_post.dart';

class ProfileView extends ConsumerStatefulWidget {
  final String? userId;
  const ProfileView({super.key, required this.userId});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  bool _showDiscoverPeople = true;

  final List<Map<String, String>> _discoverPeople = [
    {
      'name': 'Sarah Connor',
      'username': '@sarah_c',
      'avatar': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'name': 'David Chen',
      'username': '@dchen_dev',
      'avatar': 'https://i.pravatar.cc/150?img=8',
    },
    {
      'name': 'Elena Rostova',
      'username': '@elena_design',
      'avatar': 'https://i.pravatar.cc/150?img=9',
    },
    {
      'name': 'Marcus Vance',
      'username': '@mvance',
      'avatar': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'name': 'Aria Montgomery',
      'username': '@aria_m',
      'avatar': 'https://i.pravatar.cc/150?img=16',
    },
  ];

  Future<void> _refreshProfile() async {
    final currentUser = SupabaseService.auth.currentUser;
    final userId = widget.userId ?? currentUser?.id;

    if (userId == null) {
      debugPrint('ProfileView: No authenticated user');
      return;
    }
    await ref.read(profileViewModelProvider.notifier).loadProfile(userId);
  }

  @override
  void initState() {
    super.initState();
    final currentUser = SupabaseService.auth.currentUser;
    final userId = widget.userId ?? currentUser?.id;

    debugPrint('ProfileView currentUser: ${currentUser?.id}');
    debugPrint('ProfileView userId: $userId');

    if (userId == null) {
      debugPrint('ProfileView: No authenticated user');
      return;
    }

    Future.microtask(() {
      if (!mounted) return;

      ref.read(profileViewModelProvider.notifier).loadProfile(userId);
      ref.read(authViewModelProvider.notifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final stateAuth = ref.watch(authViewModelProvider.notifier);
    if (state.isFetching && state.user == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (state.user == null) {
      return Scaffold(body: Center(child: Text("Profile not found")));
    }
    final _user = state.user!;
    final _post = state.post ?? [];
    final _reply = state.reply ?? [];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _user.fullName ?? "",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'Logout') {
                await stateAuth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent, size: 20),
                    SizedBox(width: 10),
                    Text('Logout', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          physics: const ClampingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.grey[900],
                          child: ClipOval(
                            child: Image.network(
                              _user.avatarUrl ?? '',
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 40,
                                );
                              },
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            _statItem(_user.postsCount.toString(), 'Posts'),
                            const SizedBox(width: 24),
                            _statItem(
                              _user.followersCount.toString(),
                              'Followers',
                            ),
                            const SizedBox(width: 24),
                            _statItem(
                              _user.followingCount.toString(),
                              'Following',
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _user.fullName ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _user.username ?? "",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _user.bio ?? "",
                      style: const TextStyle(
                        color: Color(0xFFE7E9EA),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.isOwnProfile)
                      OutlinedButton(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/edit-profile',
                          );
                          if (result == true && mounted) {
                            await _refreshProfile();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 38),
                          side: BorderSide(color: Colors.grey[900]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => ref
                                  .read(profileViewModelProvider.notifier)
                                  .toggleFollow(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: state.isFollowing
                                    ? const Color(0xFF16181C)
                                    : Colors.white,
                                foregroundColor: state.isFollowing
                                    ? Colors.white
                                    : Colors.black,
                                minimumSize: const Size(double.infinity, 38),
                                side: state.isFollowing
                                    ? BorderSide(color: Colors.grey[700]!)
                                    : BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                state.isFollowing ? 'Following' : 'Follow',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (_showDiscoverPeople)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Discover people',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _discoverPeople.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return _buildDiscoverPersonCard(
                              _discoverPeople[index],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: Colors.blueAccent[400],
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Replies'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              ListView.separated(
                padding: const EdgeInsets.only(top: 8),
                itemCount: _post.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[900], height: 1),
                itemBuilder: (context, index) {
                  final post = _post[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullOnePost(post: post),
                          ),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey[900],
                            backgroundImage:
                                _user.avatarUrl?.trim().isNotEmpty == true
                                ? NetworkImage(_user.avatarUrl!.trim())
                                : null,
                            child: _user.avatarUrl?.trim().isNotEmpty != true
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 40,
                                  )
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
                                      _user.fullName ?? "",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _user.username ?? "",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  post.caption ?? "No caption, only media",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFE7E9EA),
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ListView.separated(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _reply.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[900], height: 1),
                itemBuilder: (context, index) {
                  final reply = _reply[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.turn_right_rounded,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Replying to ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              reply.actorName ?? "",
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey[900],
                              backgroundImage:
                                  _user.avatarUrl?.trim().isNotEmpty == true
                                  ? NetworkImage(_user.avatarUrl!.trim())
                                  : null,
                              child: _user.avatarUrl?.trim().isNotEmpty != true
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 20,
                                    )
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
                                        _user.fullName ?? "",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _user.username ?? "",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        reply.timeAgo,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reply.content,
                                    style: const TextStyle(
                                      color: Color(0xFFE7E9EA),
                                      fontSize: 14,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildDiscoverPersonCard(Map<String, String> person) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16181C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[900]!),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _discoverPeople.remove(person);
                });
              },
              child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(person['avatar']!),
              ),
              const SizedBox(height: 8),
              Text(
                person['name']!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                person['username']!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 28,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Follow',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: Colors.grey[900]!, width: 0.5),
        ),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
