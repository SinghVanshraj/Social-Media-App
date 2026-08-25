import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/services/supabase_service.dart';
import 'package:social_media_app/feature/home_feed/home_feed_model.dart';
import 'package:social_media_app/feature/profile/profile_model.dart';

class SearchService {
  final _db = SupabaseService.database;

  Future<List<ProfileModel>> searchByUsername(String query) async {
    try {
      if (query.isEmpty) return [];
      final data = await _db
          .from('users')
          .select('id, avatar_url, email, full_name, username, created_at, bio')
          .or('username.ilike.%$query%,full_name.ilike.%$query%')
          .limit(20);

          return data.map((n) => ProfileModel.fromJson(n)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<HomeFeedModel>> searchByPost(String query) async {
    try {
      final user = SupabaseService.auth.currentUser;
      if(user == null) return [];
      if (query.isEmpty) return [];
      final data = await _db
          .from('posts')
          .select('id, caption, user_id, media_url, like_count, comment_count,created_at, users(full_name, username,avatar_url) likes!left(user_id)')
          .ilike('caption','%$query%')
          .order('created_at', ascending: false)
          .limit(20);
          log('SEARCH QUERY: $query');
    log('SEARCH RESULT: $data');

          return data.map(
            (post) {
              final likes = (post['likes'] as List?) ?? [];
              final isLiked = likes.any((like) => like['user_id'] == user.id);
              return HomeFeedModel.fromJson({...post, 'is_liked':isLiked});
            }
          ).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

final searchServiceProvider = Provider((_) => SearchService());