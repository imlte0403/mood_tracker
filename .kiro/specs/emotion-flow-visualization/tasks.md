# Implementation Plan

이 문서는 "감정 흐름 시각화 및 인사이트 시스템" 기능의 구현 작업 목록입니다. 각 작업은 점진적으로 기능을 추가하며, 이전 작업의 결과물을 기반으로 합니다.

## 작업 목록

- [ ] 1. 데이터 모델 확장 및 마이그레이션
  - 기존 `TimelineEntry`를 `EnhancedEmotionEntry`로 확장
  - 신체 증상, 트리거, 활동 태그 모델 추가
  - 감정 점수 계산 로직 구현
  - _Requirements: 1.4, 4.1, 6.1_

- [ ] 1.1 EnhancedEmotionEntry 모델 생성
  - `lib/core/models/enhanced_emotion_entry.dart` 생성
  - 기존 필드 + symptoms, triggers, activities, source, emotionScore 추가
  - Firestore 직렬화/역직렬화 메서드 구현
  - _Requirements: 1.4_

- [ ] 1.2 PhysicalSymptom 모델 생성
  - `lib/core/models/physical_symptom.dart` 생성
  - SymptomType enum (headache, nausea, dizziness 등 10가지)
  - severity (1-5), customName 필드 추가
  - _Requirements: 6.1_

- [ ] 1.3 TriggerEvent 및 ActivityTag 모델 생성
  - `lib/core/models/trigger_event.dart` 생성
  - `lib/core/models/activity_tag.dart` 생성
  - TriggerCategory enum (work, social, exercise 등)
  - _Requirements: 4.7_

- [ ] 1.4 EmotionScoreMapper 구현
  - `lib/core/utils/emotion_score_mapper.dart` 생성
  - 슬라이더 값(0.0~7.0) → 감정 점수(-100~+100) 변환
  - 기존 MoodShapeEngine 활용
  - _Requirements: 1.4_

- [ ]* 1.5 데이터 모델 단위 테스트 작성
  - 직렬화/역직렬화 테스트
  - 감정 점수 계산 테스트
  - _Requirements: 1.4_

- [ ] 2. Repository 확장 및 로컬 캐시 구현
  - MoodRepository를 EmotionRepository로 확장
  - Drift를 사용한 로컬 데이터베이스 구현
  - 오프라인 지원 및 동기화 로직
  - _Requirements: 7.2, 8.2_

- [ ] 2.1 Drift 데이터베이스 스키마 정의
  - `lib/core/data/local/database.dart` 생성
  - EmotionEntries 테이블 정의
  - 날짜 인덱스 추가
  - _Requirements: 8.2_

- [ ] 2.2 EmotionRepository 생성
  - `lib/features/emotion/data/emotion_repository.dart` 생성
  - createEntry, updateEntry, deleteEntry 메서드
  - 증상, 트리거, 활동 포함한 저장 로직
  - _Requirements: 4.2, 6.4_

- [ ] 2.3 로컬-클라우드 동기화 서비스 구현
  - `lib/core/services/sync_service.dart` 생성
  - 로컬 우선 저장 (200ms 이내)
  - 백그라운드 Firestore 동기화 (5초 이내)
  - _Requirements: 8.2_

- [ ]* 2.4 Repository 단위 테스트 작성
  - CRUD 작업 테스트
  - 동기화 로직 테스트
  - _Requirements: 4.2_

- [ ] 3. Quick Entry UI 구현
  - 하단 시트 형태의 간편 기록 인터페이스
  - 기존 MoodShapeDisplay, MoodSlider 재사용
  - 100자 메모, 활동 태그, 증상 추가 버튼
  - _Requirements: 4.1, 4.2_

- [ ] 3.1 QuickEntryBottomSheet 위젯 생성
  - `lib/features/emotion/widgets/quick_entry_bottom_sheet.dart` 생성
  - 작은 MoodShapeDisplay (120x120)
  - 기존 MoodSlider 재사용
  - 짧은 메모 필드 (100자 제한)
  - _Requirements: 4.1_

- [ ] 3.2 ActivityTagSelector 위젯 생성
  - `lib/features/emotion/widgets/activity_tag_selector.dart` 생성
  - 다중 선택 가능한 칩 UI
  - 미리 정의된 카테고리 (업무, 휴식, 운동, 식사 등)
  - _Requirements: 4.7_

- [ ] 3.3 QuickEntryViewModel 생성
  - `lib/features/emotion/quick_entry_viewmodel.dart` 생성
  - 기존 MoodEntryFormNotifier 확장
  - 증상, 활동 태그 상태 관리
  - _Requirements: 4.2_

- [ ] 3.4 홈 화면에 Quick Entry 진입점 추가
  - FAB 탭 시 QuickEntryBottomSheet 표시
  - "더 자세히" 버튼으로 전체 화면 이동
  - _Requirements: 4.1_

- [ ]* 3.5 Quick Entry UI 테스트 작성
  - 위젯 테스트
  - 사용자 플로우 테스트
  - _Requirements: 4.1_

- [ ] 4. 신체 증상 기반 감정 인식 시스템
  - 증상 선택 UI
  - 증상 → 감정 추천 알고리즘
  - 개인화된 학습 시스템
  - _Requirements: 6.1, 6.2, 6.5_

- [ ] 4.1 SymptomSelector 위젯 생성
  - `lib/features/emotion/widgets/symptom_selector.dart` 생성
  - 10가지 일반 증상 + 커스텀 증상 입력
  - 다중 선택 체크박스 UI
  - _Requirements: 6.1_

- [ ] 4.2 SomaticMarkerLearner 구현
  - `lib/features/emotion/services/somatic_marker_learner.dart` 생성
  - 베이지안 업데이트로 증상-감정 상관관계 학습
  - 20개 이상 데이터 시 개인화 시작
  - _Requirements: 6.5_

- [ ] 4.3 EmotionSuggestionEngine 구현
  - `lib/features/emotion/services/emotion_suggestion_engine.dart` 생성
  - 선택된 증상 기반 감정 추천
  - 신뢰도 계산 및 정렬
  - _Requirements: 6.2, 6.3_

- [ ] 4.4 SymptomBasedEntryFlow 구현
  - 증상 선택 → 감정 추천 → 확인/수정 플로우
  - "맞아요/아니에요" 피드백으로 학습
  - _Requirements: 6.2, 6.3, 6.4_

- [ ]* 4.5 증상 기반 인식 Property 테스트 작성
  - **Property 25: Symptom-based emotion suggestion**
  - **Property 28: Somatic marker learning**
  - **Validates: Requirements 6.2, 6.5**

- [ ] 5. Flow Graph 시각화 구현
  - 시간(Y축) × 감정 점수(X축) 그래프
  - 부드러운 곡선 연결
  - 감정별 색상 그라데이션
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 5.1 FlowGraphPainter 구현
  - `lib/features/emotion/widgets/flow_graph_painter.dart` 생성
  - CustomPainter로 Y축(시간), X축(감정 점수) 그리기
  - Catmull-Rom spline으로 부드러운 곡선
  - _Requirements: 1.1, 1.2_

- [ ] 5.2 FlowGraphWidget 구현
  - `lib/features/emotion/widgets/flow_graph_widget.dart` 생성
  - GestureDetector로 탭 인터랙션
  - 포인트 탭 시 상세 정보 표시
  - _Requirements: 1.3_

- [ ] 5.3 감정별 색상 그라데이션 적용
  - 기존 MoodShapeEngine.colorForEmotion() 활용
  - 곡선 세그먼트마다 색상 변화
  - _Requirements: 1.7_

- [ ] 5.4 FlowGraphScreen 생성
  - `lib/features/emotion/flow_graph_screen.dart` 생성
  - 날짜 선택 및 좌우 스와이프 네비게이션
  - 빈 상태 처리
  - _Requirements: 1.5, 1.6_

- [ ]* 5.5 Flow Graph Property 테스트 작성
  - **Property 2: Flow graph point plotting completeness**
  - **Property 3: Graph interaction detail display**
  - **Property 35: Graph rendering performance**
  - **Validates: Requirements 1.2, 1.3, 8.1**

- [ ] 6. 패턴 분석 엔진 구현
  - 시간대별 반복 패턴 감지
  - 트리거-감정 상관관계 분석
  - 따뜻한 인사이트 메시지 생성
  - _Requirements: 2.1, 2.2, 2.4_

- [ ] 6.1 TimeBasedPatternDetector 구현
  - `lib/features/emotion/services/time_based_pattern_detector.dart` 생성
  - 시간대별, 요일별 그룹핑
  - 70% 이상 반복 시 패턴으로 인식
  - _Requirements: 2.1, 2.2_

- [ ] 6.2 TriggerCorrelationEngine 구현
  - `lib/features/emotion/services/trigger_correlation_engine.dart` 생성
  - 활동-감정 점수 상관관계 계산
  - 긍정/부정 영향 분류
  - _Requirements: 2.4_

- [ ] 6.3 InsightMessageGenerator 구현
  - `lib/features/emotion/services/insight_message_generator.dart` 생성
  - 공감적, 비임상적 언어 사용
  - "함께", "우리" 등 동반자 느낌의 표현
  - _Requirements: 2.2, 2.3_

- [ ] 6.4 PatternInsightsScreen 생성
  - `lib/features/emotion/pattern_insights_screen.dart` 생성
  - 감지된 패턴 카드 리스트
  - 탭 시 상세 뷰로 이동
  - _Requirements: 2.3, 2.5_

- [ ]* 6.5 패턴 분석 Property 테스트 작성
  - **Property 6: Pattern detection minimum data requirement**
  - **Property 8: Trigger correlation computation**
  - **Property 37: Pattern analysis performance**
  - **Validates: Requirements 2.1, 2.4, 8.3**

- [ ] 7. 감정 예측 시스템 구현
  - 14일 데이터 기반 예측 모델
  - 부정 감정 예측 시 프로액티브 알림
  - 사용자 피드백으로 정확도 개선
  - _Requirements: 3.1, 3.2, 3.4_

- [ ] 7.1 EmotionPredictionEngine 구현
  - `lib/features/emotion/services/emotion_prediction_engine.dart` 생성
  - 시간대/요일 기반 평균 점수 계산
  - 신뢰도 계산 (샘플 크기 기반)
  - _Requirements: 3.1_

- [ ] 7.2 PredictionNotificationService 구현
  - `lib/features/emotion/services/prediction_notification_service.dart` 생성
  - flutter_local_notifications 사용
  - 점수 -30 이하, 2시간 이내 예측 시 알림
  - _Requirements: 3.2_

- [ ] 7.3 사용자 설정 및 알림 권한 처리
  - 설정 화면에 예측 알림 토글 추가
  - 알림 시간대, 빈도 설정
  - _Requirements: 3.3_

- [ ] 7.4 예측 피드백 수집 및 모델 개선
  - 알림 액션 (dismiss, act) 기록
  - 정확도 60% 미만 시 일시 중지
  - _Requirements: 3.5, 3.6_

- [ ]* 7.5 예측 시스템 Property 테스트 작성
  - **Property 10: Prediction model construction**
  - **Property 11: Negative emotion notification trigger**
  - **Property 14: Prediction feedback recording**
  - **Validates: Requirements 3.1, 3.2, 3.5**

- [ ] 8. 감정 날씨 리포트 구현
  - 날씨 은유로 감정 표현
  - 애니메이션 날씨 아이콘
  - 주간/월간 날씨 캘린더
  - _Requirements: 5.1, 5.2, 5.4_

- [ ] 8.1 EmotionWeatherGenerator 구현
  - `lib/features/emotion/services/emotion_weather_generator.dart` 생성
  - 평균 점수 기반 날씨 분류 (sunny, cloudy, rainy 등)
  - 시간대별 변화 감지 및 전환 문구 생성
  - _Requirements: 5.1, 5.3, 5.5_

- [ ] 8.2 WeatherIconWidget 생성
  - `lib/features/emotion/widgets/weather_icon_widget.dart` 생성
  - Lottie 또는 커스텀 애니메이션
  - 5가지 날씨 타입별 아이콘
  - _Requirements: 5.2_

- [ ] 8.3 WeatherCalendarWidget 생성
  - `lib/features/emotion/widgets/weather_calendar_widget.dart` 생성
  - 주간/월간 뷰
  - 각 날짜에 날씨 아이콘 표시
  - _Requirements: 5.4_

- [ ] 8.4 WeatherScreen 생성
  - `lib/features/emotion/weather_screen.dart` 생성
  - 오늘의 날씨 + 요약 + 통계
  - 공유 기능 (이미지 생성)
  - _Requirements: 5.2, 5.6_

- [ ]* 8.5 날씨 시스템 Property 테스트 작성
  - **Property 20: Weather classification accuracy**
  - **Property 23: Weather transition detection**
  - **Validates: Requirements 5.3, 5.5**

- [ ] 9. 홈 위젯 및 빠른 접근 구현
  - 홈 화면 위젯으로 원탭 기록
  - 3D Touch / Long Press 메뉴
  - 알림 액션 버튼
  - _Requirements: 9.6_

- [ ] 9.1 home_widget 패키지 통합
  - `pubspec.yaml`에 home_widget 추가
  - Android/iOS 네이티브 설정
  - _Requirements: 9.6_

- [ ] 9.2 HomeWidgetService 구현
  - `lib/core/services/home_widget_service.dart` 생성
  - 위젯 데이터 업데이트
  - 위젯 탭 시 앱 열기 및 Quick Entry 표시
  - _Requirements: 9.6_

- [ ] 9.3 3D Touch / Long Press 메뉴 추가
  - iOS: Quick Actions
  - Android: App Shortcuts
  - "빠른 기록" 액션
  - _Requirements: 9.6_

- [ ]* 9.4 위젯 통합 테스트 작성
  - 위젯 데이터 업데이트 테스트
  - 딥링크 테스트
  - _Requirements: 9.6_

- [ ] 10. 접근성 및 사용성 개선
  - 스크린 리더 지원
  - 고대비 모드
  - 동적 폰트 크기
  - _Requirements: 9.1, 9.2, 9.3, 9.7_

- [ ] 10.1 Flow Graph 접근성 개선
  - Semantics 위젯으로 그래프 설명 추가
  - "오늘 N개 기록, 평균 점수 X, 추세: Y" 형식
  - _Requirements: 9.1, 9.2_

- [ ] 10.2 고대비 모드 구현
  - HighContrastTheme 생성
  - 감정별 고대비 색상 매핑
  - 패턴 기반 구분 추가 (색상 외)
  - _Requirements: 9.3_

- [ ] 10.3 동적 폰트 크기 지원
  - MediaQuery.textScaleFactor 반영
  - 80% ~ 150% 범위 지원
  - _Requirements: 9.7_

- [ ] 10.4 Reduced Motion 지원
  - 애니메이션 비활성화 옵션
  - 즉시 전환으로 대체
  - _Requirements: 9.4_

- [ ]* 10.5 접근성 테스트 작성
  - **Property 39: Accessibility alt text provision**
  - **Validates: Requirements 9.2**

- [ ] 11. 데이터 마이그레이션 및 배포 준비
  - 기존 데이터 마이그레이션
  - Feature Flags 설정
  - 에러 추적 및 분석
  - _Requirements: 7.1, 7.4_

- [ ] 11.1 DataMigrationService 구현
  - `lib/core/services/data_migration_service.dart` 생성
  - TimelineEntry → EnhancedEmotionEntry 변환
  - 기본값 설정 (intensity: 70, symptoms: [], 등)
  - _Requirements: 7.4_

- [ ] 11.2 Feature Flags 설정
  - `lib/core/config/feature_flags.dart` 생성
  - flowGraphEnabled, symptomBasedEntryEnabled 등
  - 14일 이상 데이터 있는 사용자만 예측 활성화
  - _Requirements: 3.1_

- [ ] 11.3 Firebase Analytics 통합
  - 기능 사용 추적
  - 에러 로깅 (Crashlytics)
  - 성능 모니터링 (Performance)
  - _Requirements: 8.1, 8.3_

- [ ] 11.4 마이그레이션 실행 및 검증
  - 앱 시작 시 마이그레이션 체크
  - 진행 상태 표시
  - 롤백 메커니즘
  - _Requirements: 7.4_

- [ ]* 11.5 마이그레이션 테스트 작성
  - 다양한 데이터 시나리오 테스트
  - 롤백 테스트
  - _Requirements: 7.4_

- [ ] 12. 최종 통합 및 성능 최적화
  - 전체 플로우 통합 테스트
  - 성능 벤치마크
  - 메모리 누수 확인
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [ ] 12.1 전체 사용자 플로우 통합 테스트
  - Quick Entry → Flow Graph → Pattern Insights → Weather
  - 증상 기반 기록 → 학습 → 추천
  - 예측 → 알림 → 피드백
  - _Requirements: 모든 요구사항_

- [ ] 12.2 성능 벤치마크 실행
  - Flow Graph 렌더링: 500ms 이내 (50 포인트)
  - 패턴 분석: 2초 이내 (30일 데이터)
  - 로컬 저장: 200ms 이내
  - _Requirements: 8.1, 8.2, 8.3_

- [ ] 12.3 메모리 프로파일링
  - 메모리 누수 확인
  - 페이지네이션 검증 (7일 단위)
  - 이미지/애니메이션 최적화
  - _Requirements: 8.5_

- [ ] 12.4 60 FPS 애니메이션 검증
  - Flow Graph 스크롤/줌
  - MoodShape morphing
  - 화면 전환
  - _Requirements: 8.4_

- [ ]* 12.5 성능 Property 테스트 작성
  - **Property 35: Graph rendering performance**
  - **Property 36: Entry save performance**
  - **Property 37: Pattern analysis performance**
  - **Property 38: Animation smoothness**
  - **Validates: Requirements 8.1, 8.2, 8.3, 8.4**

- [ ] 13. 최종 점검 - 모든 테스트 통과 확인
  - 모든 단위 테스트 실행
  - 모든 Property 테스트 실행
  - 통합 테스트 실행
  - 사용자 수락 테스트
