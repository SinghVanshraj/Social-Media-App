// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:social_media_app/core/services/profile_service.dart';
import 'package:social_media_app/core/services/supabase_service.dart';
import 'package:social_media_app/feature/profile/profile_model.dart';
import 'package:social_media_app/feature/profile/profile_state.dart';

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(),
);

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
      return ProfileViewModel(ref.read(profileServiceProvider));
    });

class ProfileViewModel extends StateNotifier<ProfileState> {
  final ProfileService _service;
  StreamSubscription<ProfileModel?>? _subscription;

  ProfileViewModel(this._service) : super(const ProfileState()) {
    _init();
  }

  void _init() {
    state = state.copyWith(status: ProfileStatus.loading);

    _subscription = _service.getProfileStream().listen(
      (profile) {
        if (profile == null) {
          state = state.copyWith(
            status: ProfileStatus.error,
            error: 'Profile not found',
            user: null,
          );
          return;
        }
        state = state.copyWith(status: ProfileStatus.fetched, user: profile);
      },
      onError: (error) {
        state = state.copyWith(
          error: error.toString(),
          user: null,
          status: ProfileStatus.error,
        );
      },
    );
  }

  Future<bool> checkUsername(String username) async {
    try {
      return await _service.isUsernameAvailable(username);
    } catch (e) {
      return false;
    }
  }

  Future<void> getMyProfile() async {
    state = state.copyWith(status: ProfileStatus.loading, error: null);
    try {
      final user = SupabaseService.auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          status: ProfileStatus.error,
          error: 'User not logged in',
        );
        return;
      }

      final profile = await _service.fetchProfileData(user.id);

      if (profile == null) {
        state = state.copyWith(
          status: ProfileStatus.error,
          error: 'Profile not found',
        );
        return;
      }
      final posts = await _service.getUserPosts(user.id);

      state = state.copyWith(
        status: ProfileStatus.fetched,
        user: profile,
        post: posts,
      );
    } catch (e) {
      log(e.toString());
      state = state.copyWith(status: ProfileStatus.error, error: e.toString());
    }
  }

  Future<void> uploadAvatar(String path) async {
    state = state.copyWith(status: ProfileStatus.loading, error: null);
    try {
      final _url = await _service.uploadAvatar(path);
      await _service.updateProfile(avatarUrl: _url);
    } catch (e) {
      log(e.toString());
      state = state.copyWith(status: ProfileStatus.error, error: e.toString());
    }
  }

  Future<void> loadProfile(String userId) async {
    final currentUser = SupabaseService.auth.currentUser;
    final isOwnProfile = currentUser?.id == userId;

    state = state.copyWith(
      status: ProfileStatus.loading,
      isOwnProfile: isOwnProfile,
    );

    try {
      final profile = await _service.fetchProfileData(userId);
      if (profile == null) {
        state = state.copyWith(
          status: ProfileStatus.error,
          error: 'Profile not found',
        );
        return;
      }

      bool isFollowing = false;
      if (!isOwnProfile) {
        isFollowing = await _service.isFollowing(userId);
      }

      final posts = await _service.getUserPosts(userId);
      final reply = await _service.getUserReplies(userId);

      state = state.copyWith(
        status: ProfileStatus.fetched,
        user: profile,
        post: posts,
        reply: reply,
        isOwnProfile: isOwnProfile,
        isFollowing: isFollowing,
      );
    } catch (e) {
      log(e.toString());
      state = state.copyWith(status: ProfileStatus.error, error: e.toString());
    }
  }

  Future<void> updateProfile({
    String? username,
    String? fullname,
    String? bio,
    String? avatarUrl,
  }) async {
    state = state.copyWith(status: ProfileStatus.loading, error: null);
    try {
      await _service.updateProfile(
        username: username,
        bio: bio,
        fullname: fullname,
        avatarUrl: avatarUrl,
      );
      final currentUser = SupabaseService.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }
      final updateProfile = await _service.fetchProfileData(currentUser.id);
      if (updateProfile == null) {
        throw Exception('Profile not found');
      }
      state = state.copyWith(
        status: ProfileStatus.fetched,
        user: updateProfile,
      );
    } catch (e) {
      log(e.toString());
      state = state.copyWith(status: ProfileStatus.error, error: e.toString());
    }
  }

  Future<void> getUserPosts(String id) async {
    state = state.copyWith(status: ProfileStatus.loading, error: null);
    try {
      final post = await _service.getUserPosts(id);
      state = state.copyWith(status: ProfileStatus.fetched, post: post);
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      state = state.copyWith(status: ProfileStatus.error, error: e.toString());
    }
  }

  Future<void> toggleFollow() async {
    final user = state.user?.id;
    if (user == null) return;

    state = state.copyWith(isFollowing: !state.isFollowing);
    try {
      if (!state.isFollowing) {
        await _service.unfollowUser(user);
      } else {
        await _service.followUser(user);
      }
    } catch (e) {
      state = state.copyWith(isFollowing: !state.isFollowing);
      log(e.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
