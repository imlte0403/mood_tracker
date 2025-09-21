import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';
import 'package:mood_tracker/core/providers/auth_providers.dart';
import 'package:mood_tracker/features/home/data/mood_repository.dart';
import 'package:mood_tracker/core/utils/firebase_error_handler.dart';

// 홈 화면 상태 관리
// 사용자 인증 상태 변화 모니터링, 기분 데이터 로딩 관리
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

  // 현재 선택된 날짜
  final DateTime selectedDate;

  // 선택된 날짜의 타임라인 기록 목록
  final AsyncValue<List<TimelineEntry>> entries;

  // 현재 주의 날짜 목록
  final List<DateTime> weekDates;

  // 각 날짜별 마지막 기분 상태 매핑
  final Map<DateTime, EmotionType> weeklyMoods;

  // 현재 로그인된 사용자 ID
  final String? userId;

  // 사용자 표시 이름
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

  // 기록 null 체크
  List<TimelineEntry> get entriesValue =>
      entries.valueOrNull ?? const <TimelineEntry>[];
}

// CRUD, 주간 뷰 관리, 사용자 인증 상태 처리
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

  // 기분 데이터 rep
  final MoodRepository _repository;

  String? _userId;
  StreamSubscription<List<TimelineEntry>>? _weekEntriesSubscription;

  // 현재 주의 시작 날짜
  DateTime? _currentWeekStart;

  // 날짜별로 그룹화된 기록 캐시
  Map<DateTime, List<TimelineEntry>> _cachedWeekEntries =
      <DateTime, List<TimelineEntry>>{};

  // 사용자 로그인/로그아웃 상태 변화 처리
  // 사용자 변경 시 기존 데이터 초기화, 새로운 데이터 로드
  void setUser(User? user) {
    final userId = user?.uid;
    final displayName = user?.displayName ?? 'User';

    // 동일한 사용자인 경우 무시
    if (_userId == userId && state.displayName == displayName) {
      return;
    }
    _userId = userId;

    // 로그아웃 처리
    if (userId == null) {
      _cleanupUserData();
      _resetStateToDefault();
      return;
    }

    // 새로운 사용자 데이터 로드 시작
    _initializeUserState(userId, displayName);
    _resetCacheAndLoadData();
  }

  // 사용자 데이터 정리
  void _cleanupUserData() {
    _weekEntriesSubscription?.cancel();
    _userId = null;
    _currentWeekStart = null;
    _cachedWeekEntries = <DateTime, List<TimelineEntry>>{};
  }

  // 초기화 (로그아웃 시 호출)
  void _resetStateToDefault() {
    state = state.copyWith(
      userId: null,
      displayName: 'Username',
      entries: AsyncData<List<TimelineEntry>>(<TimelineEntry>[]),
      weeklyMoods: const <DateTime, EmotionType>{},
    );
  }

  // 새로운 사용자 상태 초기화 (로그인 시 호출)
  void _initializeUserState(String userId, String displayName) {
    state = state.copyWith(
      userId: userId,
      displayName: displayName,
      entries: const AsyncLoading(),
      weeklyMoods: const <DateTime, EmotionType>{},
    );
  }

  // 데이터 재로드 (새로운 사용자 로그인 시 호출)
  void _resetCacheAndLoadData() {
    _cachedWeekEntries = <DateTime, List<TimelineEntry>>{};
    _currentWeekStart = null;
    _listenWeekEntries(forceReload: true);
  }

  // 오류 상태 설정
  void setAuthError(Object error, StackTrace stackTrace) {
    _cleanupUserData();

    final message = FirebaseErrorHandler.getErrorMessage(error);
    state = state.copyWith(
      userId: null,
      displayName: 'Username',
      entries: AsyncError<List<TimelineEntry>>(message, stackTrace),
      weeklyMoods: const <DateTime, EmotionType>{},
    );
  }

  // 위클리 캘린더
  // 주가 바뀌면 새로운 데이터 로드
  void selectDate(DateTime date) {
    final normalized = _normalizeDate(date);
    if (normalized == state.selectedDate) {
      return;
    }
    final week = _computeWeekDates(normalized);
    state = state.copyWith(selectedDate: normalized, weekDates: week);

    // 비로그인 상태 처리
    if (_userId == null) {
      _setEmptyState();
      return;
    }

    final weekStart = week.first;

    // 동일한 주 내에서 날짜 변경
    if (_currentWeekStart != null && _currentWeekStart == weekStart) {
      _emitWeekState();
    } else {
      // 새로운 주
      _loadNewWeekData();
    }
  }

  // 비로그인 상태에서 빈 상태 설정
  void _setEmptyState() {
    state = state.copyWith(
      weeklyMoods: const <DateTime, EmotionType>{},
      entries: AsyncData<List<TimelineEntry>>(<TimelineEntry>[]),
    );
  }

  // 새로운 주 데이터 로드 시작
  void _loadNewWeekData() {
    _cachedWeekEntries = <DateTime, List<TimelineEntry>>{};
    _listenWeekEntries(forceReload: true);
  }

  // 기록 생성 (Create)
  /// [timestamp] 기록 시간, [emotion] 감정 타입, [message] 선택적 메시지
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

  /// 기존 기록 업데이트
  Future<void> updateEntry(TimelineEntry entry) {
    return _repository.updateEntry(entry);
  }

  // 삭제 (Delete)
  Future<void> deleteEntry(String entryId) {
    final userId = _requireUserId();
    return _repository.deleteEntry(userId: userId, entryId: entryId);
  }

  // 실시간으로 데이터베이스 변경사항을 수신하여 UI에 반영
  void _listenWeekEntries({bool forceReload = false}) {
    final userId = _userId;
    if (userId == null) {
      _setEmptyState();
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

    _setupNewWeekSubscription(userId, weekStart);
  }

  // Firebase에서 실시간으로 데이터를 받아와 UI에 반영
  void _setupNewWeekSubscription(String userId, DateTime weekStart) {
    _weekEntriesSubscription?.cancel();
    _currentWeekStart = weekStart;
    _cachedWeekEntries = <DateTime, List<TimelineEntry>>{};

    // 로딩 상태 설정
    state = state.copyWith(
      entries: const AsyncLoading(),
      weeklyMoods: const <DateTime, EmotionType>{},
    );

    final weekEnd = weekStart.add(const Duration(days: DateTime.daysPerWeek));
    _weekEntriesSubscription = _repository
        .watchEntriesInRange(userId: userId, start: weekStart, end: weekEnd)
        .listen(
          (entries) {
            // 새로운 데이터를 받으면 캐시에 저장하고 상태 업데이트
            _cachedWeekEntries = _groupEntriesByDate(entries);
            _emitWeekState();
          },
          onError: (error, stackTrace) {
            // 에러 발생 시 메시지 표시
            final message = FirebaseErrorHandler.getErrorMessage(error);
            state = state.copyWith(
              entries: AsyncError<List<TimelineEntry>>(message, stackTrace),
              weeklyMoods: const <DateTime, EmotionType>{},
            );
          },
        );
  }

  // 현재 선택된 날짜의 상태 표시
  // 선택된 날짜의 기록 업데이트
  void _emitWeekState() {
    final normalizedSelected = _normalizeDate(state.selectedDate);
    final selectedEntries = List<TimelineEntry>.unmodifiable(
      _cachedWeekEntries[normalizedSelected] ?? const <TimelineEntry>[],
    );

    // 각 날짜의 마지막 기분을 주간 요약으로 생성
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

  // 감정 기록을 날짜별로 그룹화, 시간순으로 정렬
  Map<DateTime, List<TimelineEntry>> _groupEntriesByDate(
    List<TimelineEntry> entries,
  ) {
    final map = <DateTime, List<TimelineEntry>>{};

    // 날짜별 기록 그룹화
    for (final entry in entries) {
      final key = _normalizeDate(entry.timestamp);
      final list = map.putIfAbsent(key, () => <TimelineEntry>[]);
      list.add(entry);
    }

    // 시간순으로 정렬
    for (final list in map.values) {
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }

    return map;
  }

  // 사용자 인증 상태 검증 및 userId 반환
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

  // 주어진 날짜를 포함하는 주의 위클리 목록 생성 (일요일 시작)
  /// [anchor] 기준 날짜
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

  // StateNotifier 해제 시 정리
  // 메모리 누수 방지
  @override
  void dispose() {
    _weekEntriesSubscription?.cancel();
    super.dispose();
  }
}
