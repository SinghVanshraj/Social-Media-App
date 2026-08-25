// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/services/supabase_service.dart';
import 'package:social_media_app/feature/profile/profile_view_model.dart';
import 'package:social_media_app/helpers/profile/edit_avatar_screen.dart';
import 'package:social_media_app/helpers/profile/edit_bio_screen.dart';
import 'package:social_media_app/helpers/profile/edit_name_screen.dart';
import 'package:social_media_app/helpers/profile/edit_username_screen.dart';

class EditProfileHelper extends ConsumerStatefulWidget {
  const EditProfileHelper({super.key});

  @override
  ConsumerState<EditProfileHelper> createState() => _EditProfileHelperState();
}

class _EditProfileHelperState extends ConsumerState<EditProfileHelper> {
  Future<void> _editAvatar(String avatar) async {
    final newAvatar = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => EditAvatarScreen(currentAvatar: avatar),
      ),
    );
    debugPrint('RETURNED AVATAR = $newAvatar');

    if (!mounted || newAvatar == null) {
      return;
    }

    final userId = SupabaseService.auth.currentUser;
    if (userId != null) {
      await ref.read(profileViewModelProvider.notifier).loadProfile(userId.id);
    }
    debugPrint('AVATAR AFTER RELOAD = ${ref.read(profileViewModelProvider).user?.avatarUrl}');
  }

  @override
  void initState() {
    super.initState();
    final userId = SupabaseService.auth.currentUser;

    if (userId == null) {
      debugPrint('ProfileView: No authenticated user');
      return;
    }

    if (!mounted) return;
    Future.microtask(() {
      ref.read(profileViewModelProvider.notifier).loadProfile(userId.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    if (state.isFetching) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (state.user == null) {
      return Scaffold(body: Center(child: Text("Profile not found")));
    }
    final _user = state.user!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Edit profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: Colors.grey[900], height: 1),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _editAvatar(_user.avatarUrl ?? ''),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage:
                            (_user.avatarUrl != null &&
                                _user.avatarUrl!.isNotEmpty)
                            ? NetworkImage(_user.avatarUrl.toString())
                            : null,
                        child: _user.avatarUrl != null
                            ? null
                            : Icon(Icons.person),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _editAvatar(_user.avatarUrl ?? ''),
                  child: const Text(
                    'Change photo',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey[900], height: 1),

          _buildEditTile(
            label: 'Name',
            value: _user.fullName ?? "",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditNameScreen(currentName: _user.fullName ?? ""),
                ),
              );
            },
          ),
          _buildEditTile(
            label: 'Username',
            value: '@${_user.username}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditUsernameScreen(currentUsername: _user.username ?? ""),
                ),
              );
            },
          ),
          _buildEditTile(
            label: 'Bio',
            value: _user.bio ?? "",
            isMultiline: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditBioScreen(currentBio: _user.bio ?? ""),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditTile({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isMultiline = false,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              value.isEmpty ? 'Add your $label' : value,
              maxLines: isMultiline ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey[700] : Colors.white,
                fontSize: 15,
                height: 1.3,
              ),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey[700],
            size: 20,
          ),
        ),
        Divider(color: Colors.grey[900], height: 1),
      ],
    );
  }
}
