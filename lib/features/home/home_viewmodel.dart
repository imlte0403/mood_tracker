import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';
import 'package:mood_tracker/features/home/data/mood_repository.dart';
import 'package:mood_tracker/services/firebase_service.dart';

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  final repository = ref.watch(moodRepositoryProvider);
  final notifier = HomeViewModel(repository: repository);

  ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
    next.when(
      data: notifier.setUser,
      loading: () {},
      error: notifier.setAuthError,
    );
  });

  final initialUser = ref
      .read(authStateChangesProvider)
      .maybeWhen(data: (user) => user, orElse: () => null);
  notifier.setUser(initialUser);

  return notifier;
});

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
          weeklyDemoMoods: _generateDemoWeekData(week),
        );
      }());

  final MoodRepository _repository;
  String? _userId;
  StreamSubscription<List<TimelineEntry>>? _entriesSubscription;

  void setUser(User? user) {
    final userId = user?.uid;
    if (_userId == userId && state.displayName == user?.displayName) {
      return;
    }
    _userId = userId;
    if (userId == null) {
      _entriesSubscription?.cancel();
      state = state.copyWith(
        userId: null,
        displayName: 'Username',
        entries: AsyncData(_buildDemoEntries(state.selectedDate)),
        weeklyDemoMoods: _generateDemoWeekData(state.weekDates),
      );
      return;
    }

    state = state.copyWith(userId: userId, displayName: user?.displayName);
    _listenEntries();
  }

  void setAuthError(Object error, StackTrace stackTrace) {
    _entriesSubscription?.cancel();
    _userId = null;
    state = state.copyWith(
      userId: null,
      displayName: 'Username',
      entries: AsyncData(_buildDemoEntries(state.selectedDate)),
      weeklyDemoMoods: _generateDemoWeekData(state.weekDates),
    );
  }

  void selectDate(DateTime date) {
    final normalized = _normalizeDate(date);
    if (normalized == state.selectedDate) {
      return;
    }
    final week = _computeWeekDates(normalized);
    state = state.copyWith(
      selectedDate: normalized,
      weekDates: week,
      weeklyDemoMoods: _generateDemoWeekData(week),
    );
    _listenEntries();
  }

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

  void _listenEntries() {
    _entriesSubscription?.cancel();
    final userId = _userId;
    if (userId == null) {
      state = state.copyWith(
        entries: AsyncData(_buildDemoEntries(state.selectedDate)),
      );
      return;
    }

    state = state.copyWith(entries: const AsyncLoading());
    final targetDate = state.selectedDate;
    _entriesSubscription = _repository
        .watchEntries(userId: userId, date: targetDate)
        .listen(
          (entries) {
            state = state.copyWith(entries: AsyncData(entries));
          },
          onError: (error, stackTrace) {
            state = state.copyWith(
              entries: AsyncData(_buildDemoEntries(state.selectedDate)),
            );
          },
        );
  }

  String _requireUserId() {
    final userId = _userId;
    if (userId == null) {
      throw StateError('로그인된 사용자가 없습니다.');
    }
    return userId;
  }

  @override
  void dispose() {
    _entriesSubscription?.cancel();
    super.dispose();
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

  static Map<DateTime, EmotionType> _generateDemoWeekData(
    List<DateTime> weekDates,
  ) {
    const emotions = <EmotionType>[
      EmotionType.happy,
      EmotionType.excited,
      EmotionType.normal,
      EmotionType.angry,
      EmotionType.sad,
      EmotionType.lucky,
      EmotionType.depressed,
    ];
    return <DateTime, EmotionType>{
      for (var i = 0; i < weekDates.length; i++)
        weekDates[i]: emotions[i % emotions.length],
    };
  }

  List<TimelineEntry> _buildDemoEntries(DateTime date) {
    final baseDate = DateTime(date.year, date.month, date.day);
    final timestamp = baseDate.add(const Duration(hours: 9));
    return [
      TimelineEntry(
        id: 'demo-0',
        timestamp: timestamp,
        emotion: EmotionType.happy,
        message: '아침 산책 후 상쾌한 기분이었어요.',
        userId: 'demo',
      ),
    ];
  }
}

class HomeState {
  const HomeState({
    required this.selectedDate,
    required this.entries,
    required this.weekDates,
    required this.weeklyDemoMoods,
    this.userId,
    this.displayName,
  });

  final DateTime selectedDate;
  final AsyncValue<List<TimelineEntry>> entries;
  final List<DateTime> weekDates;
  final Map<DateTime, EmotionType> weeklyDemoMoods;
  final String? userId;
  final String? displayName;

  HomeState copyWith({
    DateTime? selectedDate,
    AsyncValue<List<TimelineEntry>>? entries,
    List<DateTime>? weekDates,
    Map<DateTime, EmotionType>? weeklyDemoMoods,
    String? userId,
    String? displayName,
  }) {
    return HomeState(
      selectedDate: selectedDate ?? this.selectedDate,
      entries: entries ?? this.entries,
      weekDates: weekDates ?? this.weekDates,
      weeklyDemoMoods: weeklyDemoMoods ?? this.weeklyDemoMoods,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
    );
  }

  List<TimelineEntry> get entriesValue =>
      entries.valueOrNull ?? const <TimelineEntry>[];
}
