# Design Document

## Overview

본 설계 문서는 무드 트래커 앱의 "감정 흐름 시각화 및 인사이트 시스템"의 기술적 구현 방안을 정의합니다. 기존의 단순 감정 기록 방식을 개선하여, 사용자가 하루 동안의 감정 변화를 연속적인 흐름으로 시각화하고, AI 기반 패턴 분석을 통해 개인화된 인사이트를 제공하는 시스템을 구축합니다.

### 핵심 개선사항

**현재 플로우 (AS-IS):**
1. 사용자가 Post 화면 진입
2. 슬라이더로 감정 선택 (8가지 감정 중 하나)
3. 메모 작성 (선택사항, 최대 500자)
4. 저장 → Firestore에 저장
5. 홈 화면에서 타임라인으로 확인

**개선된 플로우 (TO-BE):**
1. **간편 기록 모드**: 홈 위젯/퀵 액션으로 3초 내 기록
2. **다층적 입력**:
   - 감정 선택 (기존)
   - 신체 증상 선택 (신규)
   - 트리거 이벤트/활동 태그 (신규)
   - 짧은 메모 (100자로 축소, 마이크로 저널링)
3. **실시간 시각화**: Flow Graph에 즉시 반영
4. **지능형 제안**: 과거 패턴 기반 자동 완성 및 추천

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
├─────────────────────────────────────────────────────────────┤
│  FlowGraphScreen  │  QuickEntryWidget  │  InsightsScreen    │
│  WeatherScreen    │  SymptomSelector   │  PatternDetailView │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic Layer                      │
├─────────────────────────────────────────────────────────────┤
│  FlowGraphViewModel  │  PatternAnalysisEngine               │
│  PredictionEngine    │  SomaticMarkerLearner                │
│  WeatherGenerator    │  TriggerCorrelationEngine            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                       Domain Layer                           │
├─────────────────────────────────────────────────────────────┤
│  EmotionEntry (enhanced)  │  PhysicalSymptom                │
│  EmotionPattern           │  TriggerEvent                    │
│  EmotionPrediction        │  SomaticMarker                   │
│  EmotionWeather           │  ActivityTag                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
├─────────────────────────────────────────────────────────────┤
│  EmotionRepository (enhanced)  │  PatternRepository          │
│  SymptomRepository             │  PredictionRepository       │
│  LocalCacheService             │  FirestoreService           │
└─────────────────────────────────────────────────────────────┘
```

### 기술 스택 확장

**기존 스택 유지:**
- Flutter 3.9.2 / Dart 3.9.2
- Riverpod 2.6.1 (상태 관리)
- Firebase (Auth, Firestore, Storage)
- fl_chart 0.68.0 (차트)

**신규 추가:**
- **ML/AI**: `tflite_flutter` ^0.10.0 (온디바이스 패턴 학습)
- **자연어 처리**: `dart_nlp` ^0.1.0 (키워드 추출)
- **로컬 DB**: `drift` ^2.14.0 (빠른 쿼리 및 오프라인 지원)
- **알림**: `flutter_local_notifications` ^16.0.0
- **위젯**: `home_widget` ^0.4.0 (홈 화면 위젯)

## Components and Interfaces

### 1. Enhanced Emotion Entry Model

기존 `TimelineEntry`를 확장하여 신체 증상, 트리거, 활동 태그를 포함합니다.

```dart
class EnhancedEmotionEntry {
  final String id;
  final DateTime timestamp;
  final EmotionType emotion;
  final int intensity; // 0-100
  final double emotionScore; // -100 to +100 (calculated)
  
  // 기존 필드
  final String? memo;
  final String userId;
  
  // 신규 필드
  final List<PhysicalSymptom> symptoms;
  final List<TriggerEvent> triggers;
  final List<ActivityTag> activities;
  final EntrySource source; // manual, quick, symptom-based, widget
  
  // 메타데이터
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```


### 2. Physical Symptom Model

```dart
enum SymptomType {
  headache,        // 두통
  nausea,          // 속쓰림
  dizziness,       // 어지러움
  numbness,        // 멍함
  chestTightness,  // 가슴 답답함
  breathingDifficulty, // 호흡곤란
  fatigue,         // 피로
  tension,         // 긴장
  stomachache,     // 복통
  heartPalpitation, // 심계항진
  custom,          // 사용자 정의
}

class PhysicalSymptom {
  final SymptomType type;
  final String? customName; // type이 custom일 때 사용
  final int severity; // 1-5
  final DateTime recordedAt;
}
```

### 3. Trigger Event & Activity Tag Models

```dart
enum TriggerCategory {
  work,      // 업무
  social,    // 사회적 상호작용
  exercise,  // 운동
  rest,      // 휴식
  meal,      // 식사
  sleep,     // 수면
  media,     // 미디어 소비
  hobby,     // 취미
  custom,    // 사용자 정의
}

class TriggerEvent {
  final String id;
  final String description; // "커피 마심", "회의 끝남"
  final TriggerCategory category;
  final DateTime occurredAt;
}

class ActivityTag {
  final TriggerCategory category;
  final String label;
  final bool isPositive; // 긍정적 영향 여부 (학습됨)
}
```

### 4. Emotion Score Calculation

감정을 -100 ~ +100 점수로 변환하는 알고리즘:

```dart
class EmotionScoreCalculator {
  static double calculate(EmotionType emotion, int intensity) {
    // 기본 점수 매핑
    final baseScore = _getBaseScore(emotion);
    
    // 강도 반영 (0-100 → 0.0-1.0)
    final intensityFactor = intensity / 100.0;
    
    // 최종 점수 = 기본 점수 * 강도
    return baseScore * intensityFactor;
  }
  
  static double _getBaseScore(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.lucky:
        return 90.0;
      case EmotionType.happy:
        return 80.0;
      case EmotionType.excited:
        return 85.0;
      case EmotionType.normal:
        return 0.0;
      case EmotionType.depressed:
        return -70.0;
      case EmotionType.anxious:
        return -60.0;
      case EmotionType.angry:
        return -75.0;
      case EmotionType.sad:
        return -65.0;
    }
  }
}
```

### 5. Emotion Score Mapping from Slider

기존 슬라이더 값(0.0~7.0)을 감정 점수(-100~+100)로 변환:

```dart
class EmotionScoreMapper {
  // 슬라이더 값 → 감정 점수 변환
  static double sliderToScore(double sliderValue) {
    // 슬라이더 값에서 현재 감정 추출
    final snapshot = MoodShapeEngine.resolve(sliderValue);
    final emotion = snapshot.displayEmotion;
    
    // 각 감정의 기본 점수
    final baseScore = _getBaseScore(emotion);
    
    // 슬라이더 위치에 따른 강도 계산 (0.0 ~ 1.0)
    // 예: 슬라이더가 2.0(불안 중심)이면 강도 1.0
    //     슬라이더가 2.5(불안-보통 중간)이면 강도 0.5
    final intensity = _calculateIntensity(sliderValue, snapshot);
    
    return baseScore * intensity;
  }
  
  static double _getBaseScore(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.happy:    return 90.0;   // 슬라이더 7
      case EmotionType.excited:  return 85.0;   // 슬라이더 6
      case EmotionType.lucky:    return 80.0;   // 슬라이더 5
      case EmotionType.normal:   return 0.0;    // 슬라이더 3
      case EmotionType.depressed: return -70.0; // 슬라이더 4
      case EmotionType.anxious:  return -60.0;  // 슬라이더 2
      case EmotionType.sad:      return -65.0;  // 슬라이더 1
      case EmotionType.angry:    return -75.0;  // 슬라이더 0
    }
  }
  
  static double _calculateIntensity(double sliderValue, MoodShapeSnapshot snapshot) {
    // 가장 가까운 정수 값(감정 중심점)까지의 거리로 강도 계산
    final nearestInt = sliderValue.round();
    final distance = (sliderValue - nearestInt).abs();
    
    // 중심점에 가까울수록 강도 높음 (1.0)
    // 중간점에 가까울수록 강도 낮음 (0.5)
    return 1.0 - (distance * 0.5);
  }
}
```

### 6. Flow Graph Visualization Component

```dart
class FlowGraphWidget extends ConsumerWidget {
  final DateTime date;
  final List<EnhancedEmotionEntry> entries;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomPaint(
      painter: FlowGraphPainter(
        entries: entries,
        colorScheme: Theme.of(context).colorScheme,
      ),
      child: GestureDetector(
        onTapDown: (details) => _handleTap(details, ref),
      ),
    );
  }
}

class FlowGraphPainter extends CustomPainter {
  // Y축: 00:00 ~ 24:00 (시간)
  // X축: -100 ~ +100 (감정 점수)
  
  @override
  void paint(Canvas canvas, Size size) {
    // 1. 축 그리기
    _drawAxes(canvas, size);
    
    // 2. 데이터 포인트 플롯
    final points = _calculatePoints(entries, size);
    
    // 3. 부드러운 곡선으로 연결 (Catmull-Rom spline)
    final path = _createSmoothPath(points);
    
    // 4. 감정별 색상 그라데이션 적용
    // 기존 MoodShapeEngine.colorForEmotion() 활용
    final gradient = _createEmotionGradient(entries);
    
    // 5. 그리기
    canvas.drawPath(path, Paint()..shader = gradient);
    
    // 6. 데이터 포인트 마커 (작은 도형으로 표시)
    _drawMarkers(canvas, points);
  }
  
  void _drawMarkers(Canvas canvas, List<Offset> points) {
    for (int i = 0; i < points.length; i++) {
      final entry = entries[i];
      final point = points[i];
      
      // 각 포인트를 해당 감정의 색상으로 표시
      final paint = Paint()
        ..color = MoodShapeEngine.colorForEmotion(entry.emotion)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(point, 6.0, paint);
      
      // 외곽선
      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawCircle(point, 6.0, strokePaint);
    }
  }
}
```


## Data Models

### Firestore Schema (Enhanced)

```
users/{userId}/
  ├── emotionEntries/{entryId}
  │   ├── timestamp: Timestamp
  │   ├── emotion: String
  │   ├── intensity: Number
  │   ├── emotionScore: Number
  │   ├── memo: String?
  │   ├── symptoms: Array<Map>
  │   │   ├── type: String
  │   │   ├── customName: String?
  │   │   ├── severity: Number
  │   │   └── recordedAt: Timestamp
  │   ├── triggers: Array<Map>
  │   │   ├── description: String
  │   │   ├── category: String
  │   │   └── occurredAt: Timestamp
  │   ├── activities: Array<String>
  │   ├── source: String
  │   ├── createdAt: Timestamp
  │   └── updatedAt: Timestamp?
  │
  ├── patterns/{patternId}
  │   ├── type: String (time-based, symptom-based, trigger-based)
  │   ├── description: String
  │   ├── confidence: Number (0-1)
  │   ├── frequency: Number
  │   ├── relatedEntryIds: Array<String>
  │   ├── detectedAt: Timestamp
  │   └── isActive: Boolean
  │
  ├── somaticMarkers/{markerId}
  │   ├── symptomType: String
  │   ├── emotionType: String
  │   ├── correlation: Number (0-1)
  │   ├── sampleSize: Number
  │   └── lastUpdated: Timestamp
  │
  └── predictions/{predictionId}
      ├── predictedEmotion: String
      ├── predictedScore: Number
      ├── confidence: Number
      ├── targetTime: Timestamp
      ├── basedOnPatternIds: Array<String>
      ├── createdAt: Timestamp
      └── actualOutcome: Map? (feedback)
```

### Local Database Schema (Drift)

빠른 쿼리와 오프라인 지원을 위한 로컬 캐시:

```dart
@DataClassName('EmotionEntryData')
class EmotionEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get emotion => text()();
  IntColumn get intensity => integer()();
  RealColumn get emotionScore => real()();
  TextColumn get memo => text().nullable()();
  TextColumn get symptomsJson => text()(); // JSON array
  TextColumn get triggersJson => text()(); // JSON array
  TextColumn get activitiesJson => text()(); // JSON array
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

// 빠른 날짜 범위 쿼리를 위한 인덱스
@TableIndex(name: 'timestamp_idx', columns: {#timestamp})
class EmotionEntriesIndex extends EmotionEntries {}
```

## Improved Entry Flow

### 1. Quick Entry Mode (간편 기록)

**진입점:**
- 홈 화면 FAB (기존)
- 홈 위젯 (신규)
- 알림 액션 버튼 (신규)
- 3D Touch / Long Press 메뉴 (신규)

**현재 감정 기록 플로우 (AS-IS):**

```
[PostScreen - 전체 화면]
┌─────────────────────────────────┐
│  [X]                             │  ← AppBar (닫기 버튼)
│                                  │
│  지금 어떤 기분인가요?            │  ← 제목
│                                  │
│         ╱╲                       │
│        ╱  ╲                      │  ← MoodShapeDisplay
│       ╱    ╲                     │     (StarBorder morphing)
│      ╱      ╲                    │     크기: 200x200
│                                  │
│      화가나요                     │  ← 감정 메시지
│      분노                         │  ← 감정 이름 (색상 적용)
│                                  │
│  ● ● ● ● ● ● ● ●                │  ← 8개 색상 인디케이터
│  ^                               │     (현재 감정 강조)
│                                  │
│  ←─────●─────→                  │  ← 슬라이더 (0.0 ~ 7.0)
│  분노 슬픔 불안 보통 우울 행운 설렘 행복 │
│                                  │
│  ┌─────────────────────────┐    │
│  │ 메모를 입력하세요...      │    │  ← TextField (최대 500자)
│  │                          │    │
│  └─────────────────────────┘    │
│                                  │
│                          [Post]  │  ← FAB (저장 버튼)
└─────────────────────────────────┘
```

**슬라이더 동작 방식:**
- 슬라이더 값: 0.0 (분노) ~ 7.0 (행복)
- 각 정수 값(0,1,2...7)이 특정 감정의 중심점
- 중간 값(예: 2.5)에서는 두 감정 사이를 보간
  - 도형: StarBorder의 points, innerRadiusRatio, pointRounding 보간
  - 색상: Color.lerp로 부드러운 그라데이션
- 예: 2.3 → 불안(70%) + 보통(30%) 혼합

**개선된 Quick Entry 플로우 (TO-BE):**

```
[Quick Entry Bottom Sheet - 하단 시트]
┌─────────────────────────────────┐
│  지금 기분이 어떠세요?            │
│                                  │
│         ╱╲                       │  ← 작은 MoodShapeDisplay
│        ╱  ╲                      │     (크기: 120x120)
│       ╱    ╲                     │
│                                  │
│      불안                         │  ← 감정 이름만 표시
│                                  │
│  ←─────●─────→                  │  ← 슬라이더 (기존과 동일)
│                                  │
│  💬 [짧은 메모 (100자)]          │  ← 축소된 메모 필드
│                                  │
│  🏷️ [업무] [휴식] [운동] [식사] │  ← 활동 태그 (신규)
│                                  │
│  🩺 [증상 추가하기]              │  ← 증상 선택 (신규)
│                                  │
│  [저장]  [더 자세히]             │  ← 저장 or 전체 화면으로
└─────────────────────────────────┘
```

**"더 자세히" 선택 시 → 기존 PostScreen으로 이동 + 추가 필드**

**저장 시간:** 3-5초 목표

### 2. Symptom-Based Entry (증상 기반 기록)

**진입점:**
- Quick Entry에서 "증상 추가하기"
- 홈 화면에서 "증상으로 기록하기" 버튼

**UI 플로우:**
```
[Symptom Selector]
┌─────────────────────────────────┐
│  어떤 증상이 있으신가요?          │
├─────────────────────────────────┤
│  ☑️ 두통        ☐ 속쓰림         │
│  ☐ 어지러움     ☑️ 멍함          │
│  ☐ 가슴 답답함  ☐ 호흡곤란       │
│  ☐ 피로        ☐ 긴장           │
│  ☐ 기타 증상 추가...             │
├─────────────────────────────────┤
│  💡 이런 감정일 수 있어요:        │
│  ▲ 불안 (75% 확률)               │  ← 도형 + 색상으로 표현
│  ◆ 우울 (60% 확률)               │
│  ■ 분노 (45% 확률)               │
├─────────────────────────────────┤
│  [맞아요]  [아니에요]  [잘 모르겠어요] │
└─────────────────────────────────┘
```

**학습 메커니즘:**
- 사용자가 "맞아요" 선택 → 해당 증상-감정 연관성 강화
- "아니에요" 선택 → 다른 감정 선택 유도, 연관성 약화
- 20개 이상 데이터 축적 시 개인화된 추천 시작


### 3. Detailed Entry Mode (상세 기록)

Quick Entry에서 "더 자세히" 선택 시 기존 PostScreen으로 이동하되, 추가 필드 포함:

```dart
class EnhancedPostScreen extends ConsumerStatefulWidget {
  // 기존 PostScreen을 확장
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleSubmit,
        child: Text('Post'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 제목
            Text('지금 어떤 기분인가요?'),
            
            // 기존 컴포넌트 (그대로 유지)
            MoodShapeDisplay(size: 200), // StarBorder morphing 도형
            MoodSlider(), // 0.0 ~ 7.0 슬라이더
            MoodTextField(maxLength: 500), // 메모 (500자)
            
            // === 신규 필드 ===
            
            // 신체 증상 선택
            SymptomSelector(
              selectedSymptoms: _symptoms,
              onChanged: (symptoms) => setState(() => _symptoms = symptoms),
            ),
            
            // 활동 태그 선택
            ActivityTagSelector(
              selectedTags: _activities,
              onChanged: (tags) => setState(() => _activities = tags),
            ),
            
            // 트리거 이벤트 입력 (선택사항)
            TriggerEventInput(
              onAdded: (trigger) => setState(() => _triggers.add(trigger)),
            ),
            
            // 시간 조정 (기존에는 자동, 이제 수동 가능)
            TimestampPicker(
              initialTime: DateTime.now(),
              onChanged: (time) => setState(() => _timestamp = time),
            ),
          ],
        ),
      ),
    );
  }
}
```

**기존 컴포넌트 재사용:**
- `MoodShapeDisplay`: 그대로 사용 (StarBorder morphing)
- `MoodSlider`: 그대로 사용 (0.0~7.0 슬라이더)
- `MoodTextField`: 그대로 사용 (500자 메모)
- `MoodShapeEngine`: 색상/도형 계산 로직 재사용

## Pattern Analysis Engine

### 1. Time-Based Pattern Detection

```dart
class TimeBasedPatternDetector {
  Future<List<EmotionPattern>> detectPatterns({
    required List<EnhancedEmotionEntry> entries,
    required int minimumOccurrences,
  }) async {
    final patterns = <EmotionPattern>[];
    
    // 시간대별 그룹핑 (예: 매일 오전 10시)
    final hourlyGroups = _groupByHour(entries);
    
    for (final hour in hourlyGroups.keys) {
      final emotionsAtHour = hourlyGroups[hour]!;
      
      // 특정 감정이 70% 이상 반복되면 패턴으로 인식
      final dominantEmotion = _findDominantEmotion(emotionsAtHour);
      if (dominantEmotion.frequency >= 0.7) {
        patterns.add(EmotionPattern(
          type: PatternType.timeBased,
          description: _generateDescription(hour, dominantEmotion),
          confidence: dominantEmotion.frequency,
          relatedEntries: emotionsAtHour,
        ));
      }
    }
    
    return patterns;
  }
  
  String _generateDescription(int hour, DominantEmotion emotion) {
    final timeStr = _formatHour(hour);
    final emotionStr = emotion.type.displayNameKo;
    
    return "매일 $timeStr쯤 $emotionStr을 느끼시는 것 같아요. "
           "함께 이유를 찾아볼까요?";
  }
}
```

### 2. Symptom-Emotion Correlation

```dart
class SomaticMarkerLearner {
  Future<void> updateCorrelations({
    required String userId,
    required EnhancedEmotionEntry entry,
  }) async {
    for (final symptom in entry.symptoms) {
      final marker = await _getOrCreateMarker(
        userId: userId,
        symptomType: symptom.type,
        emotionType: entry.emotion,
      );
      
      // 베이지안 업데이트
      final updatedCorrelation = _bayesianUpdate(
        prior: marker.correlation,
        likelihood: 1.0, // 사용자가 확인함
        sampleSize: marker.sampleSize,
      );
      
      await _saveMarker(marker.copyWith(
        correlation: updatedCorrelation,
        sampleSize: marker.sampleSize + 1,
      ));
    }
  }
  
  Future<List<EmotionSuggestion>> suggestEmotions({
    required String userId,
    required List<PhysicalSymptom> symptoms,
  }) async {
    final suggestions = <EmotionSuggestion>[];
    
    for (final symptom in symptoms) {
      final markers = await _getMarkersForSymptom(userId, symptom.type);
      
      for (final marker in markers) {
        suggestions.add(EmotionSuggestion(
          emotion: marker.emotionType,
          confidence: marker.correlation,
          reason: "과거에 ${symptom.type.displayName}이 있을 때 "
                  "${marker.emotionType.displayNameKo}을 느끼셨어요",
        ));
      }
    }
    
    // 신뢰도 순으로 정렬
    suggestions.sort((a, b) => b.confidence.compareTo(a.confidence));
    return suggestions.take(3).toList();
  }
}
```

### 3. Trigger-Emotion Correlation

```dart
class TriggerCorrelationEngine {
  Future<Map<String, EmotionImpact>> analyzeActivityImpact({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final entries = await _getEntriesInRange(userId, startDate, endDate);
    final activityImpacts = <String, List<double>>{};
    
    for (final entry in entries) {
      for (final activity in entry.activities) {
        activityImpacts
          .putIfAbsent(activity.label, () => [])
          .add(entry.emotionScore);
      }
    }
    
    return activityImpacts.map((activity, scores) {
      final avgScore = scores.reduce((a, b) => a + b) / scores.length;
      final isPositive = avgScore > 10;
      
      return MapEntry(
        activity,
        EmotionImpact(
          activity: activity,
          averageScore: avgScore,
          frequency: scores.length,
          isPositive: isPositive,
          message: _generateMessage(activity, avgScore, isPositive),
        ),
      );
    });
  }
  
  String _generateMessage(String activity, double score, bool isPositive) {
    if (isPositive) {
      return "$activity을(를) 할 때 기분이 좋아지시는 것 같아요! "
             "앞으로도 자주 해보시는 건 어떨까요?";
    } else {
      return "$activity 후에 힘들어하시는 것 같아요. "
             "다른 방법을 함께 찾아볼까요?";
    }
  }
}
```


## Prediction Engine

```dart
class EmotionPredictionEngine {
  Future<EmotionPrediction?> predictNextEmotion({
    required String userId,
    required DateTime targetTime,
  }) async {
    // 1. 최소 14일 데이터 확인
    final entries = await _getRecentEntries(userId, days: 14);
    if (entries.length < 14) return null;
    
    // 2. 시간대별 패턴 추출
    final hourOfDay = targetTime.hour;
    final dayOfWeek = targetTime.weekday;
    
    final similarTimeEntries = entries.where((e) =>
      e.timestamp.hour == hourOfDay &&
      e.timestamp.weekday == dayOfWeek
    ).toList();
    
    if (similarTimeEntries.isEmpty) return null;
    
    // 3. 평균 감정 점수 계산
    final avgScore = similarTimeEntries
      .map((e) => e.emotionScore)
      .reduce((a, b) => a + b) / similarTimeEntries.length;
    
    // 4. 신뢰도 계산 (샘플 크기 기반)
    final confidence = _calculateConfidence(similarTimeEntries.length);
    
    // 5. 예측 생성
    return EmotionPrediction(
      predictedScore: avgScore,
      predictedEmotion: _scoreToEmotion(avgScore),
      confidence: confidence,
      targetTime: targetTime,
      basedOnSamples: similarTimeEntries.length,
    );
  }
  
  double _calculateConfidence(int sampleSize) {
    // 샘플이 많을수록 신뢰도 증가 (최대 0.95)
    return (1 - (1 / (1 + sampleSize * 0.1))).clamp(0.0, 0.95);
  }
}
```

## Emotion Weather System

```dart
enum WeatherType {
  sunny,        // 맑음 (score > 50)
  partlyCloudy, // 구름 조금 (20~50)
  cloudy,       // 흐림 (-20~20)
  rainy,        // 비 (-50~-20)
  stormy,       // 폭풍 (< -50)
}

class EmotionWeatherGenerator {
  EmotionWeather generate({
    required List<EnhancedEmotionEntry> entries,
    required DateTime date,
  }) {
    if (entries.isEmpty) {
      return EmotionWeather.empty(date);
    }
    
    // 1. 평균 점수 계산
    final avgScore = entries
      .map((e) => e.emotionScore)
      .reduce((a, b) => a + b) / entries.length;
    
    // 2. 날씨 타입 결정
    final weather = _scoreToWeather(avgScore);
    
    // 3. 감정 다양성 계산
    final uniqueEmotions = entries.map((e) => e.emotion).toSet().length;
    final diversity = uniqueEmotions / 8.0; // 8가지 감정 중 몇 개 사용
    
    // 4. 따뜻한 요약 생성
    final summary = _generateSummary(weather, avgScore, entries);
    
    return EmotionWeather(
      date: date,
      type: weather,
      averageScore: avgScore,
      emotionDiversity: diversity,
      entryCount: entries.length,
      summary: summary,
    );
  }
  
  String _generateSummary(
    WeatherType weather,
    double score,
    List<EnhancedEmotionEntry> entries,
  ) {
    // 시간대별 변화 감지
    final morning = entries.where((e) => e.timestamp.hour < 12).toList();
    final afternoon = entries.where((e) => e.timestamp.hour >= 12).toList();
    
    if (morning.isNotEmpty && afternoon.isNotEmpty) {
      final morningAvg = _avgScore(morning);
      final afternoonAvg = _avgScore(afternoon);
      final change = afternoonAvg - morningAvg;
      
      if (change > 30) {
        return "오전에 흐렸다가 오후에 맑아졌어요 ☁️→☀️";
      } else if (change < -30) {
        return "오전에는 괜찮았는데 오후에 힘들어지셨네요";
      }
    }
    
    // 기본 메시지
    switch (weather) {
      case WeatherType.sunny:
        return "오늘은 화창한 하루였어요! ☀️";
      case WeatherType.partlyCloudy:
        return "구름 사이로 햇살이 비쳤어요 ⛅";
      case WeatherType.cloudy:
        return "오늘은 잔잔한 하루였어요 ☁️";
      case WeatherType.rainy:
        return "오늘은 조금 힘든 하루였네요 🌧️";
      case WeatherType.stormy:
        return "많이 힘드셨어요. 잘 버텨주셨어요 ⛈️";
    }
  }
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Emotion score calculation consistency

*For any* emotion type and intensity value (0-100), calculating the emotion score should produce a value within the valid range (-100 to +100), and the same inputs should always produce the same output
**Validates: Requirements 1.4**

### Property 2: Flow graph point plotting completeness

*For any* list of emotion entries for a given day, every entry should appear as a plotted point on the flow graph
**Validates: Requirements 1.2**

### Property 3: Graph interaction detail display

*For any* point on the flow graph, tapping it should display all associated entry details (timestamp, emotion type, score, memo)
**Validates: Requirements 1.3**

### Property 4: Date navigation consistency

*For any* date displayed in the flow graph, swiping left should navigate to the next day and swiping right should navigate to the previous day
**Validates: Requirements 1.6**

### Property 5: Color gradient emotion mapping

*For any* emotion entry displayed on the flow graph, the curve segment should use the color associated with that emotion type
**Validates: Requirements 1.7**

### Property 6: Pattern detection minimum data requirement

*For any* dataset with 7 or more days of emotion entries, the system should attempt pattern detection and either identify patterns or report none found
**Validates: Requirements 2.1**

### Property 7: Pattern insight completeness

*For any* detected emotion pattern, the insight display should include pattern description, frequency, average emotion score, and coping strategies
**Validates: Requirements 2.3**

### Property 8: Trigger correlation computation

*For any* set of emotion entries containing trigger events, the system should compute correlation scores between triggers and emotion changes
**Validates: Requirements 2.4**

### Property 9: Pattern detail navigation

*For any* pattern insight, tapping it should navigate to a view showing all related emotion entries
**Validates: Requirements 2.5**

### Property 10: Prediction model construction

*For any* user with 14 or more days of emotion data, the system should successfully build a prediction model
**Validates: Requirements 3.1**

### Property 11: Negative emotion notification trigger

*For any* prediction with score below -30 and target time within 2 hours, the system should send a proactive notification (if notifications are enabled)
**Validates: Requirements 3.2**

### Property 12: Notification preference compliance

*For any* user-configured notification preferences (times, frequency), the system should respect these settings when sending predictions
**Validates: Requirements 3.3**

### Property 13: Prediction notification content completeness

*For any* prediction notification sent, it should contain predicted emotion, confidence level, and at least one actionable suggestion
**Validates: Requirements 3.4**

### Property 14: Prediction feedback recording

*For any* user action on a prediction notification (dismiss or act), the system should record the response for model improvement
**Validates: Requirements 3.5**

### Property 15: Entry save and graph update

*For any* valid micro journal entry submitted, the entry should be saved with timestamp and the flow graph should update to include it
**Validates: Requirements 4.2**

### Property 16: Keyword extraction from journals

*For any* set of micro journal entries, the system should extract keywords and activities for trigger identification
**Validates: Requirements 4.3**

### Property 17: Activity insight completeness

*For any* user with activity-tagged entries, the activity insights should display ranked activities with frequency and average emotion scores
**Validates: Requirements 4.4**

### Property 18: Auto-suggestion provision

*For any* user input in the memo field, the system should provide auto-suggestions based on previously used keywords
**Validates: Requirements 4.5**

### Property 19: Temporal entry grouping

*For any* set of entries recorded within 30 minutes of each other, they should be visually grouped in the timeline while remaining separate data points
**Validates: Requirements 4.6**

### Property 20: Weather classification accuracy

*For any* average emotion score, the system should classify it into the correct weather type according to the defined ranges
**Validates: Requirements 5.3**

### Property 21: Weather display completeness

*For any* emotion weather report, it should display weather icon, summary, and key statistics (average score, diversity, entry count)
**Validates: Requirements 5.2**

### Property 22: Weather calendar rendering

*For any* date range (weekly or monthly), the weather calendar should display each day's weather icon and allow tapping for details
**Validates: Requirements 5.4**

### Property 23: Weather transition detection

*For any* pair of consecutive days with emotion score change greater than 30 points, the system should highlight the transition with a descriptive phrase
**Validates: Requirements 5.5**

### Property 24: Shareable weather image generation

*For any* emotion weather data, the system should generate a shareable image containing weather visualization, date range, and summary
**Validates: Requirements 5.6**

### Property 25: Symptom-based emotion suggestion

*For any* set of selected physical symptoms, the system should suggest associated emotions with confidence levels
**Validates: Requirements 6.2**

### Property 26: Emotion suggestion interaction

*For any* emotion suggestion from symptoms, the user should be able to confirm, modify, or reject it
**Validates: Requirements 6.3**

### Property 27: Symptom-based entry recording

*For any* confirmed emotion from symptoms, the system should record both symptoms and emotion with a symptom-based flag
**Validates: Requirements 6.4**

### Property 28: Somatic marker learning

*For any* user with 20 or more symptom-based entries, the system should learn personalized correlations between symptoms and emotions
**Validates: Requirements 6.5**

### Property 29: Symptom correlation display

*For any* user with symptom data, the symptom insights should display which symptoms correlate with which emotions
**Validates: Requirements 6.6**

### Property 30: Custom symptom vocabulary addition

*For any* custom symptom entered by the user, it should be added to their personal symptom vocabulary for future use
**Validates: Requirements 6.9**

### Property 31: Severe symptom pattern warning

*For any* detected severe or concerning symptom pattern, the system should recommend consulting a healthcare professional
**Validates: Requirements 6.10**

### Property 32: Symptom visualization on graph

*For any* symptom data recorded over time, it should be visualized alongside the emotion flow graph
**Validates: Requirements 6.11**

### Property 33: Local data processing

*For any* pattern analysis or prediction computation, all processing should occur locally without sending raw emotion data to external servers
**Validates: Requirements 7.2**

### Property 34: Entry deletion completeness

*For any* emotion entry deleted by the user, it should be removed from all databases and caches
**Validates: Requirements 7.4**

### Property 35: Graph rendering performance

*For any* flow graph with up to 50 data points, rendering should complete within 500 milliseconds
**Validates: Requirements 8.1**

### Property 36: Entry save performance

*For any* new emotion entry submitted, it should save to local storage within 200 milliseconds
**Validates: Requirements 8.2**

### Property 37: Pattern analysis performance

*For any* 30-day dataset, pattern analysis should complete within 2 seconds
**Validates: Requirements 8.3**

### Property 38: Animation smoothness

*For any* user interaction with the flow graph (scrolling, zooming), the animation should maintain 60 frames per second
**Validates: Requirements 8.4**

### Property 39: Accessibility alt text provision

*For any* flow graph displayed, alternative text descriptions of emotion trends should be provided for screen readers
**Validates: Requirements 9.2**


## Error Handling

### 1. Data Validation Errors

```dart
class EntryValidationException implements Exception {
  final String message;
  final ValidationErrorType type;
  
  EntryValidationException(this.message, this.type);
}

enum ValidationErrorType {
  invalidIntensity,    // 강도가 0-100 범위 밖
  invalidTimestamp,    // 미래 시간
  emptyEmotion,        // 감정 미선택
  memoTooLong,         // 메모 길이 초과
  invalidSymptom,      // 잘못된 증상 타입
}

// 사용 예시
void validateEntry(EnhancedEmotionEntry entry) {
  if (entry.intensity < 0 || entry.intensity > 100) {
    throw EntryValidationException(
      '감정 강도는 0에서 100 사이여야 해요',
      ValidationErrorType.invalidIntensity,
    );
  }
  
  if (entry.timestamp.isAfter(DateTime.now())) {
    throw EntryValidationException(
      '미래 시간은 선택할 수 없어요',
      ValidationErrorType.invalidTimestamp,
    );
  }
}
```

### 2. Pattern Analysis Errors

```dart
class PatternAnalysisException implements Exception {
  final String message;
  final AnalysisErrorType type;
  
  PatternAnalysisException(this.message, this.type);
}

enum AnalysisErrorType {
  insufficientData,    // 데이터 부족
  corruptedData,       // 손상된 데이터
  analysisTimeout,     // 분석 시간 초과
}

// 사용자 친화적 에러 메시지
String getAnalysisErrorMessage(PatternAnalysisException error) {
  switch (error.type) {
    case AnalysisErrorType.insufficientData:
      return "패턴을 찾기에는 기록이 조금 부족해요. "
             "7일 이상 꾸준히 기록해주시면 더 정확한 인사이트를 드릴 수 있어요!";
    case AnalysisErrorType.corruptedData:
      return "일부 데이터를 읽을 수 없어요. "
             "앱을 다시 시작해보시겠어요?";
    case AnalysisErrorType.analysisTimeout:
      return "분석에 시간이 조금 걸리고 있어요. "
             "잠시 후 다시 시도해주세요.";
  }
}
```

### 3. Network & Sync Errors

```dart
class SyncException implements Exception {
  final String message;
  final SyncErrorType type;
  final bool isRetryable;
  
  SyncException(this.message, this.type, {this.isRetryable = true});
}

enum SyncErrorType {
  networkUnavailable,  // 네트워크 없음
  authenticationFailed, // 인증 실패
  serverError,         // 서버 오류
  quotaExceeded,       // 저장 공간 초과
}

// 재시도 로직
class SyncManager {
  Future<void> syncWithRetry({
    required Function syncOperation,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        await syncOperation();
        return;
      } on SyncException catch (e) {
        if (!e.isRetryable || attempts >= maxRetries - 1) {
          _showUserFriendlyError(e);
          rethrow;
        }
        
        attempts++;
        await Future.delayed(Duration(seconds: 2 * attempts));
      }
    }
  }
  
  void _showUserFriendlyError(SyncException error) {
    final message = switch (error.type) {
      SyncErrorType.networkUnavailable =>
        "인터넷 연결을 확인해주세요. "
        "기록은 안전하게 저장되어 있으니 걱정하지 마세요!",
      SyncErrorType.authenticationFailed =>
        "로그인이 만료되었어요. 다시 로그인해주세요.",
      SyncErrorType.serverError =>
        "서버에 일시적인 문제가 있어요. 잠시 후 다시 시도해주세요.",
      SyncErrorType.quotaExceeded =>
        "저장 공간이 부족해요. 오래된 기록을 정리하거나 "
        "데이터를 내보내기해주세요.",
    };
    
    // Show snackbar or dialog
  }
}
```

### 4. Graceful Degradation

시스템의 일부가 실패해도 핵심 기능은 유지:

```dart
class GracefulFeatureManager {
  // 패턴 분석 실패 시에도 기본 통계는 제공
  Future<AnalyticsData> getAnalytics(String userId) async {
    final entries = await _getEntries(userId);
    
    // 기본 통계 (항상 제공)
    final basicStats = _calculateBasicStats(entries);
    
    // 고급 분석 (실패 시 null)
    PatternAnalysis? patterns;
    try {
      patterns = await _analyzePatterns(entries);
    } catch (e) {
      _logError('Pattern analysis failed', e);
      patterns = null;
    }
    
    // 예측 (실패 시 null)
    EmotionPrediction? prediction;
    try {
      prediction = await _generatePrediction(userId);
    } catch (e) {
      _logError('Prediction failed', e);
      prediction = null;
    }
    
    return AnalyticsData(
      basicStats: basicStats,
      patterns: patterns,
      prediction: prediction,
    );
  }
}
```

## Testing Strategy

### Unit Testing

각 컴포넌트의 핵심 로직을 독립적으로 테스트:

```dart
// 감정 점수 계산 테스트
test('emotion score calculation for positive emotions', () {
  final score = EmotionScoreCalculator.calculate(
    EmotionType.happy,
    80,
  );
  expect(score, closeTo(64.0, 0.1)); // 80 * 0.8 = 64
});

// 날씨 분류 테스트
test('weather classification for sunny day', () {
  final weather = WeatherClassifier.classify(averageScore: 60);
  expect(weather, WeatherType.sunny);
});

// 패턴 감지 테스트
test('time-based pattern detection', () {
  final entries = _generateMockEntries(
    emotion: EmotionType.anxious,
    hour: 10,
    days: 7,
  );
  
  final patterns = PatternDetector.detect(entries);
  expect(patterns, isNotEmpty);
  expect(patterns.first.type, PatternType.timeBased);
});
```

### Property-Based Testing

**Testing Framework**: `dart_check` ^0.5.0

Property-based tests will verify universal properties across randomly generated inputs:

```dart
import 'package:dart_check/dart_check.dart';

// Property 1: Emotion score calculation consistency
test('emotion score is always within valid range', () {
  forAll(
    tuple2(
      Arbitrary.choose(EmotionType.values),
      Arbitrary.intInRange(0, 100),
    ),
    (tuple) {
      final emotion = tuple.item1;
      final intensity = tuple.item2;
      
      final score = EmotionScoreCalculator.calculate(emotion, intensity);
      
      return score >= -100 && score <= 100;
    },
    maxTests: 100,
  );
});

// Property 2: Flow graph point plotting completeness
test('all entries appear on flow graph', () {
  forAll(
    Arbitrary.listOf(
      _arbitraryEmotionEntry(),
      minLength: 1,
      maxLength: 50,
    ),
    (entries) {
      final graph = FlowGraphData.fromEntries(entries);
      
      return graph.points.length == entries.length;
    },
    maxTests: 100,
  );
});

// Property 20: Weather classification accuracy
test('weather classification matches score ranges', () {
  forAll(
    Arbitrary.doubleInRange(-100, 100),
    (score) {
      final weather = WeatherClassifier.classify(averageScore: score);
      
      final isCorrect = switch (weather) {
        WeatherType.sunny => score > 50,
        WeatherType.partlyCloudy => score >= 20 && score <= 50,
        WeatherType.cloudy => score >= -20 && score < 20,
        WeatherType.rainy => score >= -50 && score < -20,
        WeatherType.stormy => score < -50,
      };
      
      return isCorrect;
    },
    maxTests: 100,
  );
});

// Property 28: Somatic marker learning
test('somatic markers learned after 20 entries', () {
  forAll(
    Arbitrary.listOf(
      _arbitrarySymptomBasedEntry(),
      minLength: 20,
      maxLength: 50,
    ),
    (entries) async {
      final learner = SomaticMarkerLearner();
      
      for (final entry in entries) {
        await learner.updateCorrelations(
          userId: 'test-user',
          entry: entry,
        );
      }
      
      final markers = await learner.getMarkers('test-user');
      
      return markers.isNotEmpty;
    },
    maxTests: 50,
  );
});
```

### Integration Testing

전체 플로우를 테스트:

```dart
testWidgets('complete entry flow with symptoms', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // 1. 퀵 엔트리 열기
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  
  // 2. 슬라이더로 감정 선택 (불안 감정 위치로 이동)
  await tester.drag(
    find.byType(Slider),
    Offset(100, 0), // 불안 감정 위치
  );
  await tester.pumpAndSettle();
  
  // 3. 증상 추가
  await tester.tap(find.text('증상 추가하기'));
  await tester.pumpAndSettle();
  
  await tester.tap(find.text('두통'));
  await tester.tap(find.text('멍함'));
  await tester.tap(find.text('확인'));
  await tester.pumpAndSettle();
  
  // 4. 저장
  await tester.tap(find.text('저장'));
  await tester.pumpAndSettle();
  
  // 5. Flow Graph에 반영 확인
  expect(find.byType(FlowGraphWidget), findsOneWidget);
  
  // 6. 데이터 저장 확인
  final entries = await _getEntriesFromDB();
  expect(entries.length, 1);
  expect(entries.first.symptoms.length, 2);
});
```

### Performance Testing

```dart
test('flow graph renders within 500ms for 50 points', () async {
  final entries = _generateMockEntries(count: 50);
  
  final stopwatch = Stopwatch()..start();
  final graph = FlowGraphWidget(entries: entries);
  await tester.pumpWidget(graph);
  await tester.pumpAndSettle();
  stopwatch.stop();
  
  expect(stopwatch.elapsedMilliseconds, lessThan(500));
});

test('pattern analysis completes within 2 seconds for 30 days', () async {
  final entries = _generateMockEntries(days: 30);
  
  final stopwatch = Stopwatch()..start();
  final patterns = await PatternDetector.detect(entries);
  stopwatch.stop();
  
  expect(stopwatch.elapsedMilliseconds, lessThan(2000));
});
```

## Migration Strategy

기존 `TimelineEntry` 데이터를 `EnhancedEmotionEntry`로 마이그레이션:

```dart
class DataMigrationService {
  Future<void> migrateToEnhancedSchema() async {
    final oldEntries = await _getAllOldEntries();
    
    for (final oldEntry in oldEntries) {
      final enhanced = EnhancedEmotionEntry(
        id: oldEntry.id,
        timestamp: oldEntry.timestamp,
        emotion: oldEntry.emotion,
        intensity: 70, // 기본값 (기존에는 강도 없음)
        emotionScore: EmotionScoreCalculator.calculate(
          oldEntry.emotion,
          70,
        ),
        memo: oldEntry.message,
        userId: oldEntry.userId,
        symptoms: [], // 빈 리스트
        triggers: [],
        activities: [],
        source: EntrySource.manual,
        createdAt: oldEntry.timestamp,
        updatedAt: null,
      );
      
      await _saveEnhancedEntry(enhanced);
    }
    
    // 마이그레이션 완료 플래그 설정
    await _setMigrationComplete();
  }
}
```

## Deployment Considerations

### 1. Feature Flags

새 기능을 점진적으로 롤아웃:

```dart
class FeatureFlags {
  static bool get flowGraphEnabled => true;
  static bool get symptomBasedEntryEnabled => true;
  static bool get predictionEnabled => _checkUserEligibility();
  static bool get weatherReportEnabled => true;
  
  static bool _checkUserEligibility() {
    // 14일 이상 데이터가 있는 사용자만 예측 기능 활성화
    final daysSinceFirstEntry = _getDaysSinceFirstEntry();
    return daysSinceFirstEntry >= 14;
  }
}
```

### 2. Analytics & Monitoring

```dart
class AnalyticsService {
  void trackFeatureUsage(String featureName) {
    // Firebase Analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'feature_used',
      parameters: {'feature': featureName},
    );
  }
  
  void trackError(String errorType, String message) {
    // Firebase Crashlytics
    FirebaseCrashlytics.instance.recordError(
      Exception(message),
      StackTrace.current,
      reason: errorType,
    );
  }
  
  void trackPerformance(String operation, Duration duration) {
    // Firebase Performance
    final trace = FirebasePerformance.instance.newTrace(operation);
    trace.start();
    // ... operation ...
    trace.stop();
  }
}
```

### 3. A/B Testing

```dart
class ABTestingService {
  // 두 가지 버전의 감정 추천 알고리즘 테스트
  EmotionSuggestionAlgorithm getAlgorithm() {
    final variant = _getUserVariant();
    
    return variant == 'A'
      ? BayesianSuggestionAlgorithm()
      : FrequencyBasedSuggestionAlgorithm();
  }
  
  void trackConversion(String variant, bool userAccepted) {
    // 사용자가 추천을 수락했는지 추적
    FirebaseAnalytics.instance.logEvent(
      name: 'suggestion_conversion',
      parameters: {
        'variant': variant,
        'accepted': userAccepted,
      },
    );
  }
}
```

## Accessibility Implementation

### 1. Screen Reader Support

```dart
class AccessibleFlowGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _generateGraphDescription(),
      child: FlowGraphWidget(entries: entries),
    );
  }
  
  String _generateGraphDescription() {
    if (entries.isEmpty) {
      return "오늘은 아직 감정 기록이 없습니다";
    }
    
    final avgScore = _calculateAverage(entries);
    final trend = _describeTrend(entries);
    
    return "오늘 ${entries.length}개의 감정을 기록했습니다. "
           "평균 감정 점수는 ${avgScore.toStringAsFixed(0)}점이고, "
           "$trend";
  }
  
  String _describeTrend(List<EnhancedEmotionEntry> entries) {
    if (entries.length < 2) return "추세를 파악하기에는 기록이 부족합니다";
    
    final first = entries.first.emotionScore;
    final last = entries.last.emotionScore;
    final change = last - first;
    
    if (change > 20) return "하루 동안 기분이 좋아지셨습니다";
    if (change < -20) return "하루 동안 기분이 나빠지셨습니다";
    return "하루 동안 비슷한 감정을 유지하셨습니다";
  }
}
```

### 2. High Contrast Mode

```dart
class HighContrastTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.black,
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      // 감정별 고대비 색상
      extensions: [
        EmotionColorScheme(
          happy: Colors.yellow,
          sad: Colors.blue,
          angry: Colors.red,
          anxious: Colors.orange,
          // ...
        ),
      ],
    );
  }
}
```

## Summary

본 설계 문서는 무드 트래커 앱의 핵심 차별화 기능인 "감정 흐름 시각화 및 인사이트 시스템"의 전체 아키텍처와 구현 방안을 정의합니다. 

**핵심 개선사항:**
1. **간편 기록**: 3-5초 내 빠른 감정 기록
2. **다층적 입력**: 감정 + 증상 + 트리거 + 활동 태그
3. **지능형 분석**: 패턴 감지, 예측, 개인화된 인사이트
4. **따뜻한 UX**: 공감적 언어, 동반자 느낌의 인터페이스
5. **시각적 혁신**: Flow Graph로 감정의 연속적 흐름 표현

이 시스템은 기존 감정 일기 앱과 차별화되는 "감정을 정적 스냅샷이 아닌 동적 흐름으로 보는" 접근을 구현합니다.
