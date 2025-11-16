# 기능 구현 계획

본 문서는 무드 트래커 앱의 핵심 기능 추가를 위한 상세 구현 계획을 담고 있습니다.

---

## 📊 기능 1: 감정 통계 및 분석 차트

### 개요
사용자가 자신의 감정 패턴을 시각적으로 파악할 수 있도록 주간/월간 감정 통계를 차트로 제공합니다.

### 목표
- 시간대별 감정 분포 확인
- 가장 자주 느끼는 감정 파악
- 감정 변화 추세 분석
- 데이터 기반 자기 이해 증진

---

### 구현 단계

#### Phase 1: 패키지 선정 및 설치
**예상 소요 시간**: 1시간

**작업 내용**:
1. **차트 라이브러리 선택**
   - 옵션 1: `fl_chart` ^0.68.0 (권장)
     - 장점: Flutter 네이티브, 커스터마이징 용이, 성능 우수
     - 단점: 학습 곡선 존재
   - 옵션 2: `syncfusion_flutter_charts` ^27.2.3
     - 장점: 다양한 차트 유형, 풍부한 기능
     - 단점: 용량 큼, 일부 기능 유료

2. **pubspec.yaml 수정**
```yaml
dependencies:
  fl_chart: ^0.68.0
  intl: ^0.19.0  # 날짜 포맷팅용
```

3. **패키지 설치**
```bash
flutter pub get
```

**결과물**: 차트 패키지 설치 완료

---

#### Phase 2: 데이터 모델 및 Repository 확장
**예상 소요 시간**: 2-3시간

**작업 내용**:

1. **통계 데이터 모델 생성** (`lib/features/analytics/models/mood_statistics.dart`)
```dart
class MoodStatistics {
  final Map<EmotionType, int> emotionCounts;      // 감정별 횟수
  final Map<EmotionType, double> emotionPercentages; // 감정별 비율
  final EmotionType mostFrequent;                 // 가장 많은 감정
  final DateTime startDate;
  final DateTime endDate;
  final int totalEntries;                         // 총 기록 수

  MoodStatistics({
    required this.emotionCounts,
    required this.emotionPercentages,
    required this.mostFrequent,
    required this.startDate,
    required this.endDate,
    required this.totalEntries,
  });
}
```

2. **일별 감정 분포 모델** (`lib/features/analytics/models/daily_mood_distribution.dart`)
```dart
class DailyMoodDistribution {
  final DateTime date;
  final Map<EmotionType, int> emotionCounts;
  final EmotionType? dominantEmotion;

  DailyMoodDistribution({
    required this.date,
    required this.emotionCounts,
    this.dominantEmotion,
  });
}
```

3. **Analytics Repository 생성** (`lib/features/analytics/data/analytics_repository.dart`)
```dart
class AnalyticsRepository {
  final FirebaseFirestore _firestore;

  // 주간 통계 가져오기
  Future<MoodStatistics> getWeeklyStatistics(String userId, DateTime startDate);

  // 월간 통계 가져오기
  Future<MoodStatistics> getMonthlyStatistics(String userId, DateTime month);

  // 일별 분포 가져오기 (지난 7일/30일)
  Future<List<DailyMoodDistribution>> getDailyDistribution(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  // 시간대별 감정 분포
  Future<Map<int, Map<EmotionType, int>>> getHourlyDistribution(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}
```

**결과물**: 통계 데이터 모델 및 Repository 완성

---

#### Phase 3: UI 컴포넌트 개발
**예상 소요 시간**: 4-5시간

**작업 내용**:

1. **Analytics 화면 생성** (`lib/features/analytics/analytics_screen.dart`)
   - 탭 구조: 주간 / 월간 / 전체
   - AppBar with 제목 "감정 분석"

2. **차트 위젯 개발**

   **a) 파이 차트** (`lib/features/analytics/widgets/emotion_pie_chart.dart`)
   - 감정별 비율을 파이 차트로 표시
   - 각 섹션에 감정 이모지 + 퍼센트 표시
   - 터치 시 해당 감정의 상세 정보 표시

   **b) 막대 차트** (`lib/features/analytics/widgets/emotion_bar_chart.dart`)
   - 일별 감정 분포를 막대 차트로 표시
   - X축: 날짜 (예: 11/10, 11/11, ...)
   - Y축: 기록 횟수
   - 막대 색상: 해당 날짜의 지배적 감정 색상

   **c) 라인 차트** (`lib/features/analytics/widgets/emotion_trend_chart.dart`)
   - 긍정/부정 감정 추세 라인 차트
   - 긍정: 행운, 행복, 설렘
   - 부정: 우울, 불안, 분노, 슬픔
   - 보통: 중립

3. **통계 카드 위젯** (`lib/features/analytics/widgets/statistics_card.dart`)
```dart
// 주요 통계를 카드 형태로 표시
- 총 기록 수
- 가장 많은 감정
- 감정 다양성 점수 (8가지 중 몇 개를 사용했는지)
- 평균 하루 기록 횟수
```

4. **빈 상태 위젯** (`lib/features/analytics/widgets/empty_analytics.dart`)
   - 통계 데이터가 없을 때 표시
   - "아직 충분한 기록이 없어요" 메시지
   - 감정 기록 버튼

**결과물**: 분석 화면 및 차트 위젯 완성

---

#### Phase 4: ViewModel 및 상태 관리
**예상 소요 시간**: 2-3시간

**작업 내용**:

1. **Analytics State 정의** (`lib/features/analytics/analytics_state.dart`)
```dart
@freezed
class AnalyticsState with _$AnalyticsState {
  const factory AnalyticsState({
    @Default(AnalyticsPeriod.week) AnalyticsPeriod period,
    @Default(AsyncValue.loading()) AsyncValue<MoodStatistics> statistics,
    @Default(AsyncValue.loading()) AsyncValue<List<DailyMoodDistribution>> dailyData,
  }) = _AnalyticsState;
}

enum AnalyticsPeriod { week, month, all }
```

2. **Analytics ViewModel** (`lib/features/analytics/analytics_viewmodel.dart`)
```dart
@riverpod
class AnalyticsViewModel extends _$AnalyticsViewModel {
  @override
  AnalyticsState build() {
    loadWeeklyData();
    return const AnalyticsState();
  }

  Future<void> loadWeeklyData();
  Future<void> loadMonthlyData();
  Future<void> loadAllData();
  void changePeriod(AnalyticsPeriod period);
}
```

**결과물**: 상태 관리 및 ViewModel 완성

---

#### Phase 5: 화면 연결 및 네비게이션
**예상 소요 시간**: 1시간

**작업 내용**:

1. **라우터에 Analytics 화면 추가** (`lib/router/app_router.dart`)
```dart
GoRoute(
  path: '/analytics',
  name: 'analytics',
  builder: (context, state) => const AnalyticsScreen(),
),
```

2. **홈 화면에 진입점 추가** (`lib/features/home/home_screen.dart`)
   - AppBar에 차트 아이콘 버튼 추가
   - 또는 하단 탭에 "분석" 탭 추가

3. **설정 화면에 메뉴 추가** (`lib/features/settings/settings_screen.dart`)
   - "감정 분석 보기" 메뉴 항목

**결과물**: 네비게이션 완성

---

#### Phase 6: 테스트 및 최적화
**예상 소요 시간**: 2시간

**작업 내용**:
1. 다양한 데이터 시나리오 테스트
   - 기록이 없는 경우
   - 기록이 1-2개인 경우
   - 한 가지 감정만 있는 경우
   - 모든 감정이 골고루 있는 경우

2. 성능 최적화
   - Firestore 쿼리 최적화 (인덱스 추가)
   - 캐싱 적용
   - 메모리 누수 확인

3. UI/UX 개선
   - 로딩 상태 표시
   - 에러 처리
   - 애니메이션 추가

**결과물**: 안정적이고 최적화된 분석 기능

---

### 총 예상 소요 시간: **12-15시간**

### 필요한 기술
- Dart/Flutter
- Riverpod (상태 관리)
- fl_chart (차트 라이브러리)
- Firestore 쿼리
- 날짜 계산 (DateTime)

---

## 🔍 기능 2: 감정 기록 검색

### 개요
사용자가 과거 감정 기록을 날짜, 감정 유형, 키워드로 검색할 수 있는 기능을 제공합니다.

### 목표
- 특정 날짜 범위의 기록 찾기
- 특정 감정의 기록만 필터링
- 메모 내용으로 검색
- 검색 결과를 시간순/감정별로 정렬

---

### 구현 단계

#### Phase 1: UI 디자인 및 검색 화면 생성
**예상 소요 시간**: 2-3시간

**작업 내용**:

1. **검색 화면 생성** (`lib/features/search/search_screen.dart`)
   - 검색창 (TextField with search icon)
   - 필터 버튼 (날짜 범위, 감정 유형)
   - 검색 결과 리스트

2. **검색 필터 위젯** (`lib/features/search/widgets/search_filters.dart`)
```dart
// 필터 옵션:
- 날짜 범위 선택 (시작일 ~ 종료일)
- 감정 유형 다중 선택 (체크박스)
- 정렬 옵션 (최신순, 오래된순, 감정별)
```

3. **검색 결과 아이템** (`lib/features/search/widgets/search_result_item.dart`)
   - 타임라인 엔트리와 유사한 디자인
   - 감정 도형, 날짜, 메모 미리보기
   - 탭 시 상세보기/편집 화면으로 이동

4. **빈 상태 위젯**
   - 검색 전: "검색어를 입력하거나 필터를 선택하세요"
   - 검색 후 결과 없음: "검색 결과가 없습니다"

**결과물**: 검색 화면 UI 완성

---

#### Phase 2: 검색 로직 구현
**예상 소요 시간**: 3-4시간

**작업 내용**:

1. **검색 모델 정의** (`lib/features/search/models/search_query.dart`)
```dart
class SearchQuery {
  final String? keyword;                    // 키워드 검색
  final DateTime? startDate;                // 시작 날짜
  final DateTime? endDate;                  // 종료 날짜
  final Set<EmotionType>? emotionTypes;     // 감정 필터
  final SearchSortOption sortOption;        // 정렬 옵션

  SearchQuery({
    this.keyword,
    this.startDate,
    this.endDate,
    this.emotionTypes,
    this.sortOption = SearchSortOption.newest,
  });
}

enum SearchSortOption {
  newest,      // 최신순
  oldest,      // 오래된순
  emotionType, // 감정별
}
```

2. **Search Repository** (`lib/features/search/data/search_repository.dart`)
```dart
class SearchRepository {
  final FirebaseFirestore _firestore;

  // 복합 검색 (키워드 + 날짜 + 감정)
  Future<List<TimelineEntry>> searchEntries({
    required String userId,
    required SearchQuery query,
  });

  // 키워드로 검색 (Firestore의 제한으로 클라이언트 필터링)
  Future<List<TimelineEntry>> searchByKeyword(String userId, String keyword);

  // 날짜 범위로 검색
  Future<List<TimelineEntry>> searchByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  // 감정 유형으로 검색
  Future<List<TimelineEntry>> searchByEmotions(
    String userId,
    Set<EmotionType> emotions,
  );
}
```

3. **검색 알고리즘 최적화**
   - Firestore는 full-text search를 지원하지 않으므로:
     - 옵션 1: 클라이언트 사이드 필터링 (소규모 데이터)
     - 옵션 2: Algolia 연동 (대규모 데이터, 추후 고려)
   - 현재는 옵션 1로 구현:
     1. 날짜/감정으로 먼저 Firestore 쿼리
     2. 결과를 클라이언트에서 키워드로 필터링

**결과물**: 검색 Repository 및 로직 완성

---

#### Phase 3: ViewModel 및 상태 관리
**예상 소요 시간**: 2시간

**작업 내용**:

1. **Search State** (`lib/features/search/search_state.dart`)
```dart
@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String keyword,
    DateTime? startDate,
    DateTime? endDate,
    @Default({}) Set<EmotionType> selectedEmotions,
    @Default(SearchSortOption.newest) SearchSortOption sortOption,
    @Default(AsyncValue.data([])) AsyncValue<List<TimelineEntry>> results,
    @Default(false) bool isFilterVisible,
  }) = _SearchState;
}
```

2. **Search ViewModel** (`lib/features/search/search_viewmodel.dart`)
```dart
@riverpod
class SearchViewModel extends _$SearchViewModel {
  @override
  SearchState build() => const SearchState();

  void updateKeyword(String keyword);
  void setDateRange(DateTime? start, DateTime? end);
  void toggleEmotion(EmotionType emotion);
  void changeSortOption(SearchSortOption option);
  void toggleFilterVisibility();
  Future<void> performSearch();
  void clearFilters();
}
```

**결과물**: 검색 상태 관리 완성

---

#### Phase 4: 네비게이션 및 통합
**예상 소요 시간**: 1-2시간

**작업 내용**:

1. **라우터에 검색 화면 추가**
```dart
GoRoute(
  path: '/search',
  name: 'search',
  builder: (context, state) => const SearchScreen(),
),
```

2. **홈 화면에 검색 아이콘 추가**
   - AppBar에 검색 아이콘 버튼
   - 탭 시 검색 화면으로 이동

3. **검색 결과에서 상세보기 연동**
   - 검색 결과 아이템 탭 시 `PostEditScreen`으로 이동
   - 편집 후 다시 검색 화면으로 돌아오기

**결과물**: 검색 기능 통합 완료

---

#### Phase 5: 테스트 및 UX 개선
**예상 소요 시간**: 2시간

**작업 내용**:
1. 다양한 검색 시나리오 테스트
2. 검색 성능 측정 및 최적화
3. 검색 히스토리 저장 (SharedPreferences)
4. 디바운싱 적용 (검색어 입력 후 500ms 대기)
5. 로딩 상태 및 에러 처리

**결과물**: 안정적인 검색 기능

---

### 총 예상 소요 시간: **10-13시간**

### 필요한 기술
- Firestore 쿼리 (where, orderBy)
- 텍스트 검색 알고리즘
- 날짜 계산
- Debouncing (RxDart 또는 Timer 사용)

---

## 🗑️ 기능 3: 감정 기록 삭제

### 개요
사용자가 개별 감정 기록 또는 여러 기록을 선택하여 삭제할 수 있는 기능을 제공합니다.

### 목표
- 단일 기록 삭제
- 다중 선택 및 일괄 삭제
- 삭제 전 확인 다이얼로그
- 실수 방지를 위한 "실행 취소" 기능 (선택사항)

---

### 구현 단계

#### Phase 1: UI 업데이트
**예상 소요 시간**: 2시간

**작업 내용**:

1. **타임라인 아이템에 삭제 옵션 추가** (`lib/features/home/widget/daily_timeline.dart`)
   - 옵션 1: 스와이프로 삭제 (Dismissible 위젯)
   - 옵션 2: 길게 눌러 메뉴 표시 (ContextMenu)
   - 옵션 3: 편집 모드 진입 (상단 "편집" 버튼)

2. **삭제 확인 다이얼로그** (`lib/features/home/widgets/delete_confirmation_dialog.dart`)
```dart
// 단일 삭제 다이얼로그
"이 감정 기록을 삭제하시겠습니까?"
- 날짜/시간 표시
- 감정 유형 표시
- [취소] [삭제] 버튼

// 다중 삭제 다이얼로그
"선택한 {count}개의 기록을 삭제하시겠습니까?"
- [취소] [삭제] 버튼
```

3. **다중 선택 모드 UI**
   - AppBar 변경: "N개 선택됨"
   - 체크박스 표시
   - 하단에 삭제 버튼

4. **스낵바로 실행 취소** (선택사항)
```dart
"감정 기록이 삭제되었습니다"
[실행 취소] 버튼 (5초간 표시)
```

**결과물**: 삭제 기능 UI 완성

---

#### Phase 2: Repository 메서드 추가
**예상 소요 시간**: 1-2시간

**작업 내용**:

1. **MoodRepository에 삭제 메서드 추가** (`lib/features/home/data/mood_repository.dart`)
```dart
class MoodRepository {
  // 단일 기록 삭제
  Future<void> deleteEntry(String userId, String entryId);

  // 다중 기록 삭제
  Future<void> deleteMultipleEntries(String userId, List<String> entryIds);

  // 날짜 범위로 삭제 (위험: 신중하게 사용)
  Future<void> deleteEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}
```

2. **Firestore 삭제 로직**
```dart
Future<void> deleteEntry(String userId, String entryId) async {
  try {
    await _firestore
      .collection('users')
      .doc(userId)
      .collection('timeline')
      .doc(entryId)
      .delete();
  } catch (e) {
    throw Exception('감정 기록 삭제에 실패했습니다: $e');
  }
}

// 배치 삭제 (효율적)
Future<void> deleteMultipleEntries(String userId, List<String> entryIds) async {
  final batch = _firestore.batch();

  for (final entryId in entryIds) {
    final docRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('timeline')
      .doc(entryId);
    batch.delete(docRef);
  }

  await batch.commit();
}
```

**결과물**: 삭제 Repository 메서드 완성

---

#### Phase 3: ViewModel 업데이트
**예상 소요 시간**: 2시간

**작업 내용**:

1. **HomeViewModel에 삭제 메서드 추가** (`lib/features/home/home_viewmodel.dart`)
```dart
class HomeViewModel extends _$HomeViewModel {
  // 단일 삭제
  Future<bool> deleteEntry(String entryId) async {
    try {
      final userId = ref.read(authStateProvider).value?.uid;
      if (userId == null) return false;

      await ref.read(moodRepositoryProvider).deleteEntry(userId, entryId);

      // 로컬 상태 업데이트
      state = state.copyWith(
        entries: state.entries.where((e) => e.id != entryId).toList(),
      );

      return true;
    } catch (e) {
      debugPrint('삭제 실패: $e');
      return false;
    }
  }

  // 다중 삭제
  Future<bool> deleteMultipleEntries(List<String> entryIds) async {
    // 유사한 로직
  }
}
```

2. **삭제 모드 상태 추가** (`lib/features/home/home_state.dart`)
```dart
@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    // ... 기존 필드
    @Default(false) bool isDeleteMode,                // 삭제 모드 활성화 여부
    @Default({}) Set<String> selectedEntryIds,        // 선택된 항목 ID
  }) = _HomeState;
}
```

3. **다중 선택 관련 메서드**
```dart
void enterDeleteMode();
void exitDeleteMode();
void toggleEntrySelection(String entryId);
void selectAll();
void deselectAll();
Future<void> deleteSelectedEntries();
```

**결과물**: 삭제 기능 로직 완성

---

#### Phase 4: 실행 취소 기능 (선택사항)
**예상 소요 시간**: 2-3시간

**작업 내용**:

1. **임시 삭제 상태 관리**
```dart
// 삭제된 항목을 5초간 메모리에 보관
class DeletedEntryCache {
  TimelineEntry entry;
  DateTime deletedAt;
  Timer undoTimer;

  DeletedEntryCache(this.entry, this.deletedAt, this.undoTimer);
}
```

2. **삭제 로직 수정**
```dart
Future<void> deleteEntry(String entryId) async {
  // 1. UI에서 즉시 제거
  final entry = state.entries.firstWhere((e) => e.id == entryId);
  state = state.copyWith(
    entries: state.entries.where((e) => e.id != entryId).toList(),
  );

  // 2. 5초 타이머 시작
  final timer = Timer(Duration(seconds: 5), () {
    // 5초 후 Firestore에서 실제 삭제
    _actuallyDeleteEntry(entryId);
  });

  // 3. 캐시에 보관
  _deletedCache[entryId] = DeletedEntryCache(entry, DateTime.now(), timer);

  // 4. 스낵바 표시
  showUndoSnackbar();
}

Future<void> undoDelete(String entryId) async {
  final cached = _deletedCache[entryId];
  if (cached != null) {
    // 타이머 취소
    cached.undoTimer.cancel();

    // UI에 복원
    state = state.copyWith(
      entries: [...state.entries, cached.entry]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );

    // 캐시에서 제거
    _deletedCache.remove(entryId);
  }
}
```

**결과물**: 실행 취소 기능 완성 (선택사항)

---

#### Phase 5: PostEditScreen에 삭제 버튼 추가
**예상 소요 시간**: 1시간

**작업 내용**:

1. **편집 화면 AppBar에 삭제 아이콘 추가** (`lib/features/post/post_screen.dart`)
```dart
AppBar(
  actions: [
    if (isEditing)  // 편집 모드일 때만 표시
      IconButton(
        icon: Icon(Icons.delete_outline),
        onPressed: _showDeleteDialog,
      ),
  ],
)
```

2. **삭제 확인 다이얼로그 표시**
```dart
void _showDeleteDialog() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => DeleteConfirmationDialog(entry: widget.entry),
  );

  if (confirmed == true) {
    await ref.read(homeViewModelProvider.notifier).deleteEntry(widget.entry.id);
    if (context.mounted) {
      context.pop();  // 삭제 후 이전 화면으로
    }
  }
}
```

**결과물**: 편집 화면에서 삭제 가능

---

#### Phase 6: 테스트 및 최종 점검
**예상 소요 시간**: 1-2시간

**작업 내용**:
1. 다양한 삭제 시나리오 테스트
   - 단일 삭제
   - 다중 삭제
   - 실행 취소 (구현 시)
   - 네트워크 오류 시 처리
2. 동시성 이슈 확인
3. UI/UX 최종 점검

**결과물**: 안정적인 삭제 기능

---

### 총 예상 소요 시간: **9-12시간** (실행 취소 포함 시 +2-3시간)

### 필요한 기술
- Firestore 삭제 (delete, batch write)
- 다이얼로그 처리
- 타이머 관리 (실행 취소용)
- 스낵바/토스트 메시지

---

## 📅 전체 일정 요약

| 기능 | 예상 시간 | 우선순위 | 비고 |
|------|-----------|----------|------|
| 감정 통계 및 분석 차트 | 12-15시간 | 중 | 사용자 가치 높음 |
| 감정 기록 검색 | 10-13시간 | 중 | UX 개선에 필수 |
| 감정 기록 삭제 | 9-12시간 | 높음 | 기본 CRUD 완성 |

**총 예상 소요 시간**: **31-40시간** (약 4-5일, 하루 8시간 기준)

---

## 🎯 구현 순서 제안

### 추천 순서 1: CRUD 우선 완성
1. **감정 기록 삭제** → 기본 CRUD 완성
2. **감정 기록 검색** → 사용성 향상
3. **감정 통계 및 분석** → 부가가치 제공

### 추천 순서 2: 사용자 가치 우선
1. **감정 통계 및 분석** → 핵심 차별화 기능
2. **감정 기록 삭제** → 필수 기능
3. **감정 기록 검색** → 편의 기능

---

## 📝 체크리스트

각 기능 완료 시 아래 항목을 확인하세요:

- [ ] 기능이 정상 작동하는가?
- [ ] 로딩 상태가 적절히 표시되는가?
- [ ] 에러가 사용자에게 명확히 전달되는가?
- [ ] 빈 상태가 적절히 처리되는가?
- [ ] 다크 모드에서도 잘 보이는가?
- [ ] 다양한 화면 크기에서 테스트했는가?
- [ ] 성능 이슈가 없는가?
- [ ] 코드가 충분히 문서화되어 있는가?
- [ ] Git 커밋 메시지가 명확한가?

---

**작성일**: 2025년 11월 16일
**버전**: 1.0
