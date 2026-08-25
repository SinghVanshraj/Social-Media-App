// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/core/services/supabase_service.dart';
import 'package:social_media_app/feature/home_feed/home_feed_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  final _postCreateData = SupabaseService.database.from('posts');
  final _postGetData = SupabaseService.database.from('posts');
  final _postLikedData = SupabaseService.database.from('likes');
  // Create Post

  Future<void> createPost(List<XFile>? localFiles, String? caption) async {
    final user = SupabaseService.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user');
    }

    final cleanCaption = caption?.trim();

    if ((localFiles == null || localFiles.isEmpty) &&
        (cleanCaption == null || cleanCaption.isEmpty)) {
      throw Exception('Post must have text or media');
    }

    final uploadedPaths = <String>[];

    try {
      final mediaUrls = <String>[];

      if (localFiles != null && localFiles.isNotEmpty) {
        for (final file in localFiles) {
          final result = await _uploadPostMedia(file: file, userId: user.id);

          mediaUrls.add(result.url);
          uploadedPaths.add(result.path);
        }
      }

      await _postCreateData.insert({
        'user_id': user.id,
        'caption': cleanCaption,
        'media_url': mediaUrls,
      });
    } catch (e, stackTrace) {
      log('CREATE POST ERROR: $e');
      log('$stackTrace');
      if (uploadedPaths.isNotEmpty) {
        try {
          await SupabaseService.bucket.from('posts').remove(uploadedPaths);
        } catch (deleteError) {
          log('ROLLBACK ERROR: $deleteError');
        }
      }

      rethrow;
    }
  }

  Future<_UploadedMedia> _uploadPostMedia({
    required XFile file,
    required String userId,
  }) async {
    final filePath = file.path;

    if (filePath.isEmpty) {
      throw Exception('Selected media has an empty path');
    }

    final localFile = File(filePath);

    if (!await localFile.exists()) {
      throw Exception('Selected media file does not exist');
    }

    final fileSize = await localFile.length();

    if (fileSize == 0) {
      throw Exception('Selected media file is empty');
    }

    final extension = _getExtension(file);

    final contentType = _getMediaContentType(file: file, extension: extension);

    final fileName =
        '${userId}/${DateTime.now().microsecondsSinceEpoch}.$extension';

    log('Uploading media: $filePath');
    log('Extension: $extension');
    log('Content-Type: $contentType');
    log('Size: $fileSize bytes');
    log('Storage path: $fileName');

    await SupabaseService.bucket
        .from('posts')
        .upload(
          fileName,
          localFile,
          fileOptions: FileOptions(
            contentType: contentType,
            cacheControl: '3600',
            upsert: false,
          ),
        );

    final publicUrl = SupabaseService.bucket
        .from('posts')
        .getPublicUrl(fileName);

    log('Uploaded successfully: $publicUrl');

    return _UploadedMedia(url: publicUrl, path: fileName);
  }

  String _getExtension(XFile file) {
    final path = file.path;

    if (path.contains('.')) {
      final extension = path.split('.').last.toLowerCase().trim();

      if (extension.isNotEmpty && extension.length <= 5) {
        return extension;
      }
    }

    final mime = file.mimeType?.toLowerCase();

    switch (mime) {
      case 'image/jpeg':
        return 'jpg';

      case 'image/png':
        return 'png';

      case 'image/webp':
        return 'webp';

      case 'image/gif':
        return 'gif';

      case 'video/mp4':
        return 'mp4';

      case 'video/quicktime':
        return 'mov';

      case 'video/webm':
        return 'webm';

      case 'video/x-m4v':
        return 'm4v';

      default:
        throw Exception(
          'Unsupported media type: ${file.mimeType ?? 'unknown'}',
        );
    }
  }

  String _getMediaContentType({
    required XFile file,
    required String extension,
  }) {
    final mime = file.mimeType;

    if (mime != null && mime.isNotEmpty) {
      return mime;
    }

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';

      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      case 'gif':
        return 'image/gif';

      case 'mp4':
        return 'video/mp4';

      case 'mov':
        return 'video/quicktime';

      case 'm4v':
        return 'video/x-m4v';

      case 'webm':
        return 'video/webm';

      default:
        throw Exception('Unsupported media extension: .$extension');
    }
  }

  // Home Feed
  Future<List<HomeFeedModel>> fetchedPost({
    DateTime? cursor,
    int limit = 10,
  }) async {
    try {
      final user = SupabaseService.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      var query = _postGetData.select('''
            id,
            user_id,
            caption,
            media_url,
            like_count,
            comment_count,
            created_at,
            users(
            full_name,
            username,
            avatar_url
            ),
            likes!left (
            user_id
            )
            ''');

      if (cursor != null) {
        query = query.lt('created_at', cursor.toIso8601String());
      }

      final data = await query
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .limit(limit);

      return data.map((post) {
        final likes = post['likes'] as List;
        final isLiked = likes.any((like) => like['user_id'] == user.id);
        return HomeFeedModel.fromJson({...post, 'is_liked': isLiked});
      }).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      final user = SupabaseService.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');
      final postOwner = await SupabaseService.database
          .from('posts')
          .select('user_id')
          .eq('id', postId)
          .single();
      final postOwnerId = postOwner['user_id'] as String;
      await _postLikedData.insert({'post_id': postId, 'user_id': user.id});
      await SupabaseService.database.from('notifications').insert({
        'actor_id': user.id,
        'recipient_id': postOwnerId,
        'type': 'like_post',
        'post_id': postId,
      });
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> unLikePost(String postId) async {
    try {
      final user = SupabaseService.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');
      await _postLikedData
          .delete()
          .eq('post_id', postId)
          .eq('user_id', user.id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<HomeFeedModel>> fetchFollowingPosts({
    DateTime? cursor,
    int limit = 10,
  }) async {
    try {
      final user = SupabaseService.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final following = await SupabaseService.database
          .from('follows')
          .select('following_id')
          .eq('follower_id', user.id);

      final followingIds = following
          .map((f) => f['following_id'] as String)
          .toList();

      if (followingIds.isEmpty) return [];

      var query = _postGetData.select('''
            id,
            user_id,
            caption,
            media_url,
            like_count,
            comment_count,
            created_at,
            users(
            full_name,
            username,
            avatar_url
            ),
            likes!left (
            user_id
            )
            ''');

      if (cursor != null) {
        query = query.lt('created_at', cursor.toIso8601String());
      }

      final data = await query
          .inFilter('user_id', followingIds)
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .limit(limit);

      return data.map((post) {
        final likes = post['likes'] as List;
        final isLiked = likes.any((like) => like['user_id'] == user.id);
        return HomeFeedModel.fromJson({...post, 'is_liked': isLiked});
      }).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

class PostCursor {
  final DateTime createdAt;
  final String id;

  PostCursor({required this.createdAt, required this.id});
}

final postServiceProvider = Provider((_) => PostService());

class _UploadedMedia {
  final String url;
  final String path;

  const _UploadedMedia({required this.url, required this.path});
}
