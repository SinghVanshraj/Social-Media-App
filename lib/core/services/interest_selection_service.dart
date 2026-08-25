import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/services/supabase_service.dart';
import 'package:social_media_app/feature/interest_selection/interest_selection_model.dart';

class InterestSelectionService {
  final _db = SupabaseService.database.from('user_interests');

  Future<void> insert(List<String> interestIds, String userId) async {
    if (interestIds.isEmpty) return;
    final rows = interestIds.map((interestId) {
      return {'user_id': userId, 'interest_id': interestId};
    }).toList();
    await _db.insert(rows);
  }

  Future<void> update(List<String> interestIds, String userId) async {
    if (userId.isEmpty) return;
    final rows = interestIds.map((interestId) {
      return {'user_id': userId, 'interest_id': interestId};
    }).toList();
    await _db.upsert(rows, onConflict: 'user_id,interest_id');
  }

  Future<void> delete(List<String> interestIds, String userId) async {
    if (interestIds.isEmpty) return;
    for (final i in interestIds) {
      await _db.delete().eq('user_id', userId).eq('interest_id', i);
    }
  }

  Future<List<InterestSelectionModel>> read(String? userId) async {
    if (userId == null) return [];

    final data = await _db.select().eq('user_id', userId);

    return (data as List)
        .map(
          (item) =>
              InterestSelectionModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}

final interestSelectionServiceProvider = Provider(
  (_) => InterestSelectionService(),
);
