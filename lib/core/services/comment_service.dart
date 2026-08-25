import 'dart:developer';

import 'package:riverpod/riverpod.dart';
import 'package:social_media_app/core/services/supabase_service.dart';
import 'package:social_media_app/feature/comments/comments_model.dart';

class CommentService {
  final _db = SupabaseService.database.from('comments');

  Future<List<CommentModel>> fetchComments(String postId) async {
    try {
      final data = await _db.select('''
id,
post_id,
user_id,
parent_comment_id,
content,
created_at,
users(
full_name,
avatar_url
)
''')
.eq('post_id', postId)
.isFilter('parent_comment_id', null)
.order('created_at', ascending: false);
return data.map((n) => CommentModel.fromJson(n)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<CommentModel>> fetchReplies(String parentCommentId) async {
    try {
      final data = await _db.select('''
id,
post_id,
user_id,
parent_comment_id,
content,
created_at,
users(
full_name,
avatar_url
)
''')
.eq('parent_comment_id', parentCommentId)
.order('created_at', ascending: true);
log(
      'FETCH REPLIES: parent=$parentCommentId count=${data.length}',
    );

    log('REPLIES DATA: $data');
return data.map((n) => CommentModel.fromJson(n)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> addComment({
    required String postId, required String content
  }) async {
    try {
      final user = SupabaseService.auth.currentUser;
      if(user == null) throw Exception('No authenticated user');
      final postOwner = await SupabaseService.database.from('posts').select('user_id').eq('id', postId).single();
      final postOwnerId = postOwner['user_id'] as String;

      await _db.insert({
        'post_id':postId,
        'user_id':user.id,
        'content': content
      });

      await SupabaseService.database.from('notifications').insert({
        'actor_id' : user.id,
        'recipient_id': postOwnerId,
        'type': 'comment',
        'post_id' : postId
      });

    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> replyComment({
    required String postId, required String content, required parentCommentId
  }) async {
    try {
      final user = SupabaseService.auth.currentUser;
      if(user == null) throw Exception('No authenticated user');

      await _db.insert({
        'post_id':postId,
        'user_id':user.id,
        'content': content,
        'parent_comment_id': parentCommentId
      });
      
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteComment({
    required String commentId
  }) async {
    try {
      final user = SupabaseService.auth.currentUser;
      if(user == null) throw Exception('No authenticated user');

      await _db.delete().eq('id', commentId).eq('user_id',user.id);
      
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

final commentServiceProvider = Provider((_) => CommentService());