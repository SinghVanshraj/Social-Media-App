import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:social_media_app/core/services/supabase_service.dart';
import 'package:social_media_app/feature/comments/comments_model.dart';
import 'package:social_media_app/feature/home_feed/home_feed_model.dart';
import 'package:social_media_app/feature/profile/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _userProfileData = SupabaseService.database.from('users');
  final _userBucket = SupabaseService.bucket.from('avatars');

  Stream<ProfileModel?> getProfileStream() {
    final user = SupabaseService.auth.currentUser;
    if (user == null) return Stream.value(null);
    return _userProfileData.stream(primaryKey: ['id']).eq('id', user.id).map((
      data,
    ) {
      if (data.isEmpty) return null;
      return ProfileModel.fromJson(data.first);
    });
  }

  Future<ProfileModel?> fetchProfileData(String uid) async {
  try {
    final session = SupabaseService.auth.currentSession;

    log('User: ${session?.user.id}');
    log('Expires at: ${session?.expiresAt}');
    log('Now: ${DateTime.now().millisecondsSinceEpoch ~/ 1000}');

    final token = session?.accessToken;

    if (token != null) {
      final parts = token.split('.');
      final payload = jsonDecode(
        utf8.decode(
          base64Url.decode(base64Url.normalize(parts[1])),
        ),
      );

      final iat = payload['iat'];
      final exp = payload['exp'];
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      log('JWT iat: $iat');
      log('JWT exp: $exp');
      log('Current time: $now');
      log('iat - now: ${iat - now}');
      log('exp - now: ${exp - now}');
    }

    final data = await _userProfileData
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (data == null) return null;

    return ProfileModel.fromJson(data);
  } catch (e, stackTrace) {
    log(e.toString(), stackTrace: stackTrace);
    rethrow;
  }
}

  Future<String> uploadAvatar(String path) async {
    final user = SupabaseService.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    final file = File(path);
    final ext = path.split('.').last.toLowerCase();
    final name = '${user.id}.$ext';
    try {
      await _userBucket.upload(
        name,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      return _userBucket.getPublicUrl(name);
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? username,
    String? fullname,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final user = SupabaseService.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final Map<String, dynamic> updates = {};
      if (username != null) updates['username'] = username;
      if (fullname != null) updates['full_name'] = fullname;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (updates.isEmpty) return;

      await _userProfileData.update(updates).eq('id', user.id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    final data = await _userProfileData
        .select('username')
        .eq('username', username)
        .maybeSingle();
    return data == null; 
  }

  Future<bool> isFollowing(String targetUserId) async {
    final user = SupabaseService.auth.currentUser;
    if (user == null) return false;

    final data = await SupabaseService.database
        .from("follows")
        .select()
        .eq('follower_id', user.id)
        .eq('following_id', targetUserId)
        .maybeSingle();

    return data != null;
  }

  Future<void> followUser(String targetUserId) async {
    final user = SupabaseService.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await SupabaseService.database.from('follows').insert({
      'follower_id': user.id,
      'following_id': targetUserId,
    });
  }

  Future<void> unfollowUser(String targetUserId) async {
    final user = SupabaseService.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await SupabaseService.database
        .from('follows')
        .delete()
        .eq('follower_id', user.id)
        .eq('following_id', targetUserId);
  }

  Future<List<HomeFeedModel>> getUserPosts(String id) async {
    try {
      final data = await SupabaseService.database
          .from('posts')
          .select('''id,
      user_id,
      caption,
      media_url,
      created_at''')
          .eq('user_id', id);
      if (data.isEmpty) return [];
      return data.map((post) {
        return HomeFeedModel.fromJson(post);
      }).toList();
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<CommentModel>> getUserReplies(String id) async {
  try {
    final data = await SupabaseService.database
        .from('comments')
        .select('''
          id,
          post_id,
          user_id,
          parent_comment_id,
          content,
          created_at,
          parent_comment:comments!parent_comment_id (
            id,
            user_id,
            content,
            user:users!user_id (
              id,
              username,
              full_name,
              avatar_url
            )
          )
        ''')
        .eq('user_id', id)
        .not('parent_comment_id', 'is', null)
        .order('created_at', ascending: false);

    if (data.isEmpty) return [];

    return data.map((reply) {
      final parent = reply['parent_comment'];

      final parentComment = parent is List && parent.isNotEmpty
          ? parent.first
          : parent;

      final parentUser = parentComment is Map
          ? parentComment['user']
          : null;

      final user = parentUser is List && parentUser.isNotEmpty
          ? parentUser.first
          : parentUser;

      return CommentModel(
        id: reply['id'] as String,
        postId: reply['post_id'] as String,
        userId: reply['user_id'] as String,
        parentCommentId: reply['parent_comment_id'] as String?,
        content: reply['content'] as String,
        createdAt: DateTime.parse(reply['created_at'] as String),
        actorName: user is Map ? user['username'] as String? : null,
        actorAvatar: user is Map ? user['avatar_url'] as String? : null,
      );
    }).toList();
  } catch (e, stackTrace) {
    log(e.toString(), stackTrace: stackTrace);
    return [];
  }
}

  Future<void> removeAvatar() async {
    final user = SupabaseService.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    try {
      final data = await _userProfileData
          .select()
          .eq('id', user.id)
          .maybeSingle();
      final avatarUrl = data?['avatar_url'] as String?;

      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        final uri = Uri.tryParse(avatarUrl);

        if (uri != null && uri.pathSegments.last.isNotEmpty) {
          final fileName = uri.pathSegments.last;
          await _userBucket.remove([fileName]);
        }
      }
      await _userProfileData.update({'avatar_url': null}).eq('id', user.id);
    } catch (e, stackTrace) {
      log(e.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }
}
