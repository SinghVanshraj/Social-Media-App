import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:social_media_app/core/services/search_service.dart';
import 'package:social_media_app/feature/home_feed/home_feed_model.dart';
import 'package:social_media_app/feature/profile/profile_model.dart';
import 'package:social_media_app/feature/search/search_state.dart';

final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
      return SearchViewModel(ref.read(searchServiceProvider));
    });

class SearchViewModel extends StateNotifier<SearchState> {
  final SearchService _service;
  Timer? _debounce;
  SearchViewModel(this._service) : super(const SearchState());

  void search(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    state = state.copyWith(status: SearchStatus.loading);
    try {
      final results = await Future.wait([
        _service.searchByPost(query),
        _service.searchByUsername(query),
      ]);
      state = state.copyWith(
        status: SearchStatus.fetched,
        users: results[1] as List<ProfileModel>,
        posts: results[0] as List<HomeFeedModel>,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(status: SearchStatus.error, error: e.toString());
    }
  }

  void clearSearch() {
    _debounce?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
