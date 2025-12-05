import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/core/models/timeline_entry.dart';
import 'package:mood_tracker/core/providers/auth_providers.dart';
import 'package:mood_tracker/core/utils/firebase_error_handler.dart';
import 'package:mood_tracker/features/search/data/search_repository.dart';

final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
      final repository = ref.watch(searchRepositoryProvider);
      final notifier = SearchViewModel(repository: repository);

      final auth = ref.watch(firebaseAuthProvider);
      notifier.setUser(auth.currentUser);

      ref.listen<AsyncValue<User?>>(authStateChangesProvider, (_, next) {
        next.when(
          data: notifier.setUser,
          loading: () {},
          error: (error, stackTrace) => notifier.setAuthError(error, stackTrace),
        );
      });

      return notifier;
    });

class SearchState {
  const SearchState({
    required this.query,
    required this.results,
    required this.hasSearched,
    this.userId,
  });

  final String query;
  final AsyncValue<List<TimelineEntry>> results;
  final bool hasSearched;
  final String? userId;

  SearchState copyWith({
    String? query,
    AsyncValue<List<TimelineEntry>>? results,
    bool? hasSearched,
    String? userId,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      hasSearched: hasSearched ?? this.hasSearched,
      userId: userId ?? this.userId,
    );
  }

  List<TimelineEntry> get entries =>
      results.valueOrNull ?? const <TimelineEntry>[];
}

class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel({required SearchRepository repository})
    : _repository = repository,
      super(
        const SearchState(
          query: '',
          results: AsyncData<List<TimelineEntry>>(<TimelineEntry>[]),
          hasSearched: false,
        ),
      );

  final SearchRepository _repository;

  void setUser(User? user) {
    final userId = user?.uid;
    if (userId == state.userId) {
      return;
    }

    if (userId == null) {
      state = const SearchState(
        query: '',
        results: AsyncData<List<TimelineEntry>>(<TimelineEntry>[]),
        hasSearched: false,
      );
      return;
    }

    state = state.copyWith(userId: userId);
  }

  void setAuthError(Object error, StackTrace stackTrace) {
    final message = FirebaseErrorHandler.getErrorMessage(error);
    state = state.copyWith(
      results: AsyncError<List<TimelineEntry>>(message, stackTrace),
      hasSearched: true,
      userId: null,
    );
  }

  void updateQuery(String value) {
    final trimmed = value.trim();
    var nextState = state.copyWith(query: value);

    if (trimmed.isEmpty) {
      nextState = nextState.copyWith(
        results: const AsyncData<List<TimelineEntry>>(<TimelineEntry>[]),
        hasSearched: false,
      );
    }

    state = nextState;
  }

  Future<void> search() async {
    final query = state.query.trim();
    final userId = state.userId;

    state = state.copyWith(hasSearched: true);

    if (query.isEmpty) {
      state = state.copyWith(
        results: const AsyncData<List<TimelineEntry>>(<TimelineEntry>[]),
      );
      return;
    }

    if (userId == null) {
      state = state.copyWith(
        results: AsyncError<List<TimelineEntry>>(
          '로그인이 필요합니다.',
          StackTrace.current,
        ),
      );
      return;
    }

    state = state.copyWith(
      results: const AsyncLoading<List<TimelineEntry>>(),
    );

    try {
      final entries = await _repository.fetchEntries(userId: userId);
      final filtered = entries
          .where((entry) => _matchesQuery(entry.message, query))
          .toList();

      state = state.copyWith(
        results: AsyncData<List<TimelineEntry>>(filtered),
      );
    } catch (error, stackTrace) {
      final message = FirebaseErrorHandler.getErrorMessage(error);
      state = state.copyWith(
        results: AsyncError<List<TimelineEntry>>(message, stackTrace),
      );
    }
  }

  bool _matchesQuery(String? source, String query) {
    if (source == null || source.isEmpty) {
      return false;
    }
    final normalizedSource = source.toLowerCase();
    final normalizedQuery = query.toLowerCase();
    return normalizedSource.contains(normalizedQuery);
  }
}
