import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';
import 'package:mood_tracker/core/providers/auth_providers.dart';
import 'package:mood_tracker/features/home/data/mood_repository.dart';
import 'package:mood_tracker/core/utils/firebase_error_handler.dart';

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  final repository = ref.watch(moodRepositoryProvider);
  final notifier = HomeViewModel(repository: repository);

  final auth = ref.watch(firebaseAuthProvider);
  notifier.setUser(auth.currentUser);

  ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
    next.when(
      data: (user) => notifier.setUser(user),
      loading: () {},
      error: (error, stackTrace) => notifier.setAuthError(error, stackTrace),
    );
  });

  return notifier;
});

class HomeState {
  const HomeState({
    required this.selectedDate,
    required this.entries,
    required this.weekDates,
    required this.weeklyMoods,
    this.userId,
    this.displayName,
  });

  final DateTime selectedDate;
  final AsyncValue<List<TimelineEntry>> entries;
  final List<DateTime> weekDates;
  final Map<DateTime, EmotionType> weeklyMoods;
  final String? userId;
  final String? displayName;

  HomeState copyWith({
    DateTime? selectedDate,
    AsyncValue<List<TimelineEntry>>? entries,
    List<DateTime>? weekDates,
    Map<DateTime, EmotionType>? weeklyMoods,
    String? userId,
    String? displayName,
  }) {
    return HomeState(
      selectedDate: selectedDate ?? this.selectedDate,
      entries: entries ?? this.entries,
      weekDates: weekDates ?? this.weekDates,
      weeklyMoods: weeklyMoods ?? this.weeklyMoods,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
    );
  }

  List<TimelineEntry> get entriesValue =>
      entries.valueOrNull ?? const <TimelineEntry>[];
}

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel({required MoodRepository repository})
    : _repository = repository,
      super(() {
        final today = _normalizeDate(DateTime.now());
        final week = _computeWeekDates(today);
        return HomeState(
          selectedDate: today,
          entries: const AsyncLoading(),
          weekDates: week,
          displayName: 'Username',
          weeklyMoods: const <DateTime, EmotionType>{},
        );
      }());

  final MoodRepository _repository;
  String? _userId;
  StreamSubscription<List<TimelineEntry>>? _weekEntriesSubscription;
  DateTime? _currentWeekStart;
  Map<DateTime, List<TimelineEntry>> _cachedWeekEntries =
      <DateTime, List<TimelineEntry>>{};

  //인증 메서드
  void setUser(User? user) {
    final userId = user?.uid;
    final displayName = user?.displayName ?? 'User';
    if (_userId == userId && state.displayName == displayName) {
      return;
    }
    _userId = userId;
    if (userId == null) {
      _weekEntriesSubscription?.cancel();
      _currentWeekStart = null;
      _cachedWeekEntries = <DateTime, List<TimelineEntry>>{};
      state = state.copyWith(
        userId: null,
        displayName: 'Username',
        entries: AsyncData<List<TimelineEntry>>(<TimelineEntry>[]),
        weeklyMoods: const <DateTime, EmotionType>{},
      );
      return;
    }

    state = state.copyWith(
      userId: userId,
      displayName: displayName,
      entries: const AsyncLoading(),
      weeklyMoods: const <DateTime, EmotionType>{},
    );
    _cachedWeekEntries = <DateTime, List<TimelineEntry>>{};
    _currentWeekStart = null;
    _listenWeekEntries(forceReload: true);
  }

  void setAuthError(Object error, StackTrace stackTrace) {
    _weekEntriesSubscription?.cancel();
    _userId = null;
    _currentWeekStart = null;
    _cachedWeekEntries = <DateTime, List<TimelineEntry>>{};
    final message = FirebaseErrorHandler.getErrorMessage(error);
    state = state.copyWith(
      userId: null,
      displayName: 'Username',
      entries: AsyncError<List<TimelineEntry>>(message, stackTrace),
      weeklyMoods: const <DateTime, EmotionType>{},
    );
  }

  void selectDate(DateTime date) {
    final normalized = _normalizeDate(date);
    if (normalized == state.selectedDate) {
      return;
    }
    final week = _computeWeekDates(normalized);
    state = state.copyWith(selectedDate: normalized, weekDates: week);
    if (_userId == null) {
      state = state.copyWith(
        weeklyMoods: const <DateTime, EmotionType>{},
        entries: AsyncData<List<TimelineEntry>>(<TimelineEntry>[]),
      );
      return;
    }

    final weekStart = week.first;
    if (_currentWeekStart != null && _currentWeekStart == weekStart) {
      _emitWeekState();
    } else {
      _cachedWeekEntries = <DateTime, List<TimelineEntry>>{};
      _listenWeekEntries(forceReload: true);
    }
  }

  //CRUD
  Future<TimelineEntry> createEntry({
    required DateTime timestamp,
    required EmotionType emotion,
    String? message,
  }) {
    final userId = _requireUserId();
    return _repository.createEntry(
      userId: userId,
      timestamp: timestamp,
      emotion: emotion,
      message: message,
    );
  }

  Future<void> updateEntry(TimelineEntry entry) {
    return _repository.updateEntry(entry);
  }

  Future<void> deleteEntry(String entryId) {
    final userId = _requireUserId();
    return _repository.deleteEntry(userId: userId, entryId: entryId);
  }

  //Data streem
  void _listenWeekEntries({bool forceReload = false}) {
    final userId = _userId;
    if (userId == null) {
      state = state.copyWith(
        entries: AsyncData<List<TimelineEntry>>(<TimelineEntry>[]),
        weeklyMoods: const <DateTime, EmotionType>{},
      );
      return;
    }

    if (state.weekDates.isEmpty) {
      return;
    }

    final weekStart = state.weekDates.first;
    if (!forceReload &&
        _currentWeekStart != null &&
        _currentWeekStart == weekStart) {
      _emitWeekState();
      return;
    }

    _weekEntriesSubscription?.cancel();
    _currentWeekStart = weekStart;
    _cachedWeekEntries = <DateTime, List<TimelineEntry>>{};
    state = state.copyWith(
      entries: const AsyncLoading(),
      weeklyMoods: const <DateTime, EmotionType>{},
    );

    final weekEnd = weekStart.add(const Duration(days: DateTime.daysPerWeek));
    _weekEntriesSubscription = _repository
        .watchEntriesInRange(userId: userId, start: weekStart, end: weekEnd)
        .listen(
          (entries) {
            _cachedWeekEntries = _groupEntriesByDate(entries);
            _emitWeekState();
          },
          onError: (error, stackTrace) {
            final message = FirebaseErrorHandler.getErrorMessage(error);
            state = state.copyWith(
              entries: AsyncError<List<TimelineEntry>>(message, stackTrace),
              weeklyMoods: const <DateTime, EmotionType>{},
            );
          },
        );
  }

  void _emitWeekState() {
    final normalizedSelected = _normalizeDate(state.selectedDate);
    final selectedEntries = List<TimelineEntry>.unmodifiable(
      _cachedWeekEntries[normalizedSelected] ?? const <TimelineEntry>[],
    );

    final moods = <DateTime, EmotionType>{};
    _cachedWeekEntries.forEach((date, entries) {
      if (entries.isEmpty) return;
      moods[date] = entries.last.emotion;
    });

    state = state.copyWith(
      entries: AsyncData(selectedEntries),
      weeklyMoods: moods,
    );
  }

  //타임라인 메서드
  Map<DateTime, List<TimelineEntry>> _groupEntriesByDate(
    List<TimelineEntry> entries,
  ) {
    final map = <DateTime, List<TimelineEntry>>{};
    for (final entry in entries) {
      final key = _normalizeDate(entry.timestamp);
      final list = map.putIfAbsent(key, () => <TimelineEntry>[]);
      list.add(entry);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    return map;
  }

  String _requireUserId() {
    final userId = _userId;
    if (userId == null) {
      throw StateError('로그인된 사용자가 없습니다.');
    }
    return userId;
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static List<DateTime> _computeWeekDates(DateTime anchor) {
    final weekdayIndex =
        anchor.weekday % DateTime.daysPerWeek; // 1(Mon)..7(Sun)
    final sundayStart = anchor.subtract(Duration(days: (weekdayIndex) % 7));
    return List<DateTime>.generate(
      DateTime.daysPerWeek,
      (index) => DateTime(
        sundayStart.year,
        sundayStart.month,
        sundayStart.day + index,
      ),
    );
  }

  @override
  void dispose() {
    _weekEntriesSubscription?.cancel();
    super.dispose();
  }
}
