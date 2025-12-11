# Requirements Document

## Introduction

본 문서는 무드 트래커 앱의 핵심 차별화 기능인 "감정 흐름 시각화 및 인사이트 시스템"에 대한 요구사항을 정의합니다. 기존의 정적인 감정 기록 방식에서 벗어나, 하루 동안의 감정 변화를 연속적인 흐름으로 시각화하고, 패턴 분석을 통해 사용자에게 실질적인 인사이트를 제공하는 것을 목표로 합니다.

## Glossary

- **System**: 무드 트래커 애플리케이션
- **User**: 앱을 사용하여 감정을 기록하고 분석하는 사용자
- **Emotion Entry**: 특정 시간에 기록된 감정 데이터 (감정 유형, 강도, 시간, 메모)
- **Emotion Score**: 감정을 수치화한 값 (-100: 매우 부정 ~ 0: 중립 ~ +100: 매우 긍정)
- **Flow Graph**: 시간축(Y)과 감정 점수축(X)으로 구성된 연속적 감정 변화 그래프
- **Emotion Pattern**: 특정 시간대, 요일, 상황에서 반복적으로 나타나는 감정 경향
- **Trigger Event**: 감정 변화를 유발하는 활동이나 상황
- **Micro Journal**: 짧은 메모와 함께 기록하는 간단한 감정 기록
- **Emotion Weather**: 하루 또는 기간의 감정 상태를 날씨 은유로 표현한 것
- **Prediction Model**: 과거 패턴을 기반으로 미래 감정 상태를 예측하는 알고리즘
- **Physical Symptom**: 감정과 연관된 신체적 증상 (두통, 속쓰림, 멍함, 어지러움 등)
- **Somatic Marker**: 신체 증상과 감정 상태 간의 학습된 연관성

## Requirements

### Requirement 1: 시간-감정 연속성 시각화

**User Story:** 사용자로서, 하루 동안 내 감정이 어떻게 변화했는지 시각적으로 확인하고 싶습니다. 그래야 감정의 흐름과 패턴을 직관적으로 이해할 수 있습니다.

#### Acceptance Criteria

1. WHEN the User views the home screen THEN the System SHALL display a flow graph with time on the Y-axis (00:00 to 24:00) and emotion score on the X-axis (-100 to +100)

2. WHEN the User has multiple emotion entries for a day THEN the System SHALL plot each entry as a point on the flow graph and connect consecutive points with smooth curves

3. WHEN the User taps on a point in the flow graph THEN the System SHALL display detailed information including timestamp, emotion type, emotion score, and associated memo

4. WHEN the System calculates emotion score THEN the System SHALL convert emotion type and intensity to a numeric score where positive emotions (lucky, happy, excited) map to positive scores, negative emotions (depressed, anxious, angry, sad) map to negative scores, and normal maps to zero

5. WHEN the User has no emotion entries for a day THEN the System SHALL display an empty state message encouraging the User to record emotions

6. WHEN the User swipes horizontally on the flow graph THEN the System SHALL navigate to previous or next day's flow graph

7. WHEN the flow graph displays emotion changes THEN the System SHALL use color gradients matching emotion types to visualize the curve segments

### Requirement 2: 감정 트리거 패턴 분석

**User Story:** 사용자로서, 특정 시간대나 상황에서 반복되는 감정 패턴을 발견하고 싶습니다. 그래야 내 감정을 유발하는 요인을 이해하고 대응할 수 있습니다.

#### Acceptance Criteria

1. WHEN the System analyzes emotion entries over a minimum period of 7 days THEN the System SHALL identify recurring patterns based on time of day, day of week, and emotion type using warm, conversational language

2. WHEN the System detects a time-based pattern (e.g., anxiety every morning at 10 AM) THEN the System SHALL generate an insight card with empathetic phrasing such as "매일 오전 10시쯤 불안을 느끼시는 것 같아요. 함께 이유를 찾아볼까요?"

3. WHEN the User views pattern insights THEN the System SHALL display the pattern description, frequency of occurrence, average emotion score, and suggested coping strategies in supportive, non-clinical language

4. WHEN the System identifies trigger events from micro journal entries THEN the System SHALL correlate specific activities or keywords with emotion changes

5. WHEN the User taps on a pattern insight THEN the System SHALL navigate to a detailed view showing all related emotion entries on a timeline

6. WHEN the System has insufficient data (less than 7 days or fewer than 10 entries) THEN the System SHALL display a message indicating more data is needed for pattern analysis

### Requirement 3: 감정 예측 및 프로액티브 알림

**User Story:** 사용자로서, 과거 패턴을 기반으로 감정 변화를 예측하고 미리 대응할 수 있는 알림을 받고 싶습니다. 그래야 부정적 감정을 예방하거나 완화할 수 있습니다.

#### Acceptance Criteria

1. WHEN the System has at least 14 days of emotion data THEN the System SHALL build a prediction model based on time-of-day and day-of-week patterns

2. WHEN the prediction model forecasts a negative emotion period (score below -30) within the next 2 hours THEN the System SHALL send a proactive notification with a personalized coping suggestion

3. WHEN the User enables prediction notifications in settings THEN the System SHALL respect the User's preferred notification times and frequency limits

4. WHEN the System sends a prediction notification THEN the System SHALL include the predicted emotion, confidence level, and at least one actionable suggestion based on past successful coping strategies

5. WHEN the User dismisses or acts on a prediction notification THEN the System SHALL record the User's response to improve future prediction accuracy

6. WHEN the prediction model accuracy falls below 60% THEN the System SHALL temporarily disable predictions and notify the User that more consistent data is needed

### Requirement 4: 마이크로 저널링 시스템

**User Story:** 사용자로서, 긴 일기 대신 짧은 메모와 함께 감정을 빠르게 여러 번 기록하고 싶습니다. 그래야 일상의 작은 순간들이 내 감정에 미치는 영향을 파악할 수 있습니다.

#### Acceptance Criteria

1. WHEN the User opens the quick entry interface THEN the System SHALL provide a streamlined form with emotion selector, intensity slider, and optional short memo field (maximum 100 characters)

2. WHEN the User submits a micro journal entry THEN the System SHALL save the entry with timestamp and update the flow graph in real-time

3. WHEN the System analyzes micro journal entries THEN the System SHALL extract keywords and activities to identify trigger events

4. WHEN the User views activity insights THEN the System SHALL display a ranked list of activities correlated with positive and negative emotions, including frequency and average emotion score

5. WHEN the User types in the memo field THEN the System SHALL provide auto-suggestions based on previously used keywords and common activities

6. WHEN the User records multiple entries within a short time period (less than 30 minutes) THEN the System SHALL group them visually in the timeline while maintaining individual data points

7. WHEN the User wants to add context to an entry THEN the System SHALL allow tagging with predefined categories (work, social, exercise, rest, etc.)

### Requirement 5: 감정 날씨 리포트

**User Story:** 사용자로서, 내 감정 상태를 날씨 은유로 쉽게 이해하고 공유하고 싶습니다. 그래야 복잡한 감정 데이터를 직관적으로 파악할 수 있습니다.

#### Acceptance Criteria

1. WHEN the System generates a daily emotion weather report THEN the System SHALL classify the day into weather types (sunny, partly cloudy, cloudy, rainy, stormy) based on overall emotion score distribution and present it with warm, poetic language

2. WHEN the User views the emotion weather THEN the System SHALL display an animated weather icon, a compassionate one-sentence summary (e.g., "오늘은 구름 사이로 햇살이 비쳤어요"), and key statistics

3. WHEN the System determines weather type THEN the System SHALL use the following mapping: sunny (average score > 50), partly cloudy (20 to 50), cloudy (-20 to 20), rainy (-50 to -20), stormy (< -50)

4. WHEN the User views weekly or monthly weather THEN the System SHALL display a weather calendar showing each day's weather icon and allow tapping for detailed daily view

5. WHEN the System detects significant weather changes between consecutive days THEN the System SHALL highlight the transition with a descriptive, validating phrase (e.g., "어제는 힘들었지만 오늘은 조금 나아지셨네요")

6. WHEN the User wants to share their emotion weather THEN the System SHALL generate a shareable image with weather visualization, date range, and privacy-safe summary text

7. WHEN the System creates weather summaries THEN the System SHALL use natural, empathetic language that validates the User's emotional experience and acknowledges their effort in self-care

### Requirement 6: 신체 증상 기반 감정 인식

**User Story:** 사용자로서, 내 감정을 명확히 인식하기 어려울 때 신체 증상을 통해 감정을 파악하고 기록하고 싶습니다. 그래야 감정 인식 능력이 부족해도 내 상태를 추적할 수 있습니다.

#### Acceptance Criteria

1. WHEN the User selects the symptom-based entry mode THEN the System SHALL display a list of common physical symptoms including headache, nausea, dizziness, numbness, tightness in chest, difficulty breathing, fatigue, and tension

2. WHEN the User selects one or more physical symptoms THEN the System SHALL suggest likely associated emotions based on psychological research and the User's personal history

3. WHEN the System suggests emotions from symptoms THEN the System SHALL display confidence levels and allow the User to confirm, modify, or reject the suggestions

4. WHEN the User confirms an emotion based on symptoms THEN the System SHALL record both the physical symptoms and the emotion with a flag indicating symptom-based entry

5. WHEN the System has at least 20 symptom-based entries THEN the System SHALL learn personalized somatic markers by correlating the User's specific symptoms with confirmed emotions and provide insights in warm, supportive language

6. WHEN the User views symptom insights THEN the System SHALL display which physical symptoms most frequently correlate with specific emotions for that User with empathetic explanations such as "두통이 올 때 불안을 느끼시는 경향이 있어요. 이건 자연스러운 반응이에요"

7. WHEN the User experiences a symptom pattern THEN the System SHALL provide educational content explaining the mind-body connection and validation that physical symptoms are real manifestations of emotional states using compassionate, non-judgmental language

8. WHEN the System detects improvement in symptom-emotion awareness THEN the System SHALL celebrate the User's progress with encouraging messages such as "이제 신체 신호를 더 잘 알아차리고 계시네요"

9. WHEN the User adds a custom symptom not in the predefined list THEN the System SHALL allow free-text entry and add it to the User's personal symptom vocabulary

10. WHEN the System detects severe or concerning symptom patterns (e.g., frequent chest pain, persistent breathing difficulties) THEN the System SHALL recommend consulting a healthcare professional with caring language such as "최근 이런 증상이 자주 나타나고 있어요. 전문가와 상담해보시는 건 어떨까요?"

11. WHEN the User records symptoms over time THEN the System SHALL visualize symptom frequency alongside the emotion flow graph to show correlations

12. WHEN the System provides symptom-emotion insights THEN the System SHALL use first-person supportive language (e.g., "함께 패턴을 찾아봤어요", "당신의 몸이 보내는 신호를 이해하고 있어요") to create a sense of companionship

### Requirement 7: 데이터 프라이버시 및 보안

**User Story:** 사용자로서, 내 감정 데이터와 민감한 신체 증상 정보가 안전하게 보호되고 내가 완전히 통제할 수 있기를 원합니다. 그래야 안심하고 솔직하게 감정을 기록할 수 있습니다.

#### Acceptance Criteria

1. WHEN the System stores emotion data THEN the System SHALL encrypt all data at rest using AES-256 encryption

2. WHEN the System performs pattern analysis or predictions THEN the System SHALL process all data locally on the device without sending raw emotion data to external servers

3. WHEN the User wants to export data THEN the System SHALL provide options to export in JSON or CSV format with password protection

4. WHEN the User deletes an emotion entry THEN the System SHALL permanently remove the entry from all databases and caches within 24 hours

5. WHEN the User requests account deletion THEN the System SHALL delete all associated emotion data within 30 days and provide confirmation

### Requirement 8: 성능 및 응답성

**User Story:** 사용자로서, 앱이 빠르고 부드럽게 작동하기를 원합니다. 그래야 감정을 기록하고 싶을 때 즉시 사용할 수 있습니다.

#### Acceptance Criteria

1. WHEN the User opens the flow graph screen THEN the System SHALL render the graph within 500 milliseconds for up to 50 data points

2. WHEN the User submits a new emotion entry THEN the System SHALL save to local storage within 200 milliseconds and sync to cloud within 5 seconds when network is available

3. WHEN the System performs pattern analysis THEN the System SHALL complete analysis for 30 days of data within 2 seconds

4. WHEN the User scrolls or interacts with the flow graph THEN the System SHALL maintain 60 frames per second animation smoothness

5. WHEN the System loads historical data THEN the System SHALL implement pagination to load data in chunks of 7 days to optimize memory usage

### Requirement 9: 접근성 및 사용성

**User Story:** 사용자로서, 다양한 상황과 능력에서도 앱을 편리하게 사용하고 싶습니다. 그래야 언제 어디서나 내 감정을 기록할 수 있습니다.

#### Acceptance Criteria

1. WHEN the User enables screen reader mode THEN the System SHALL provide descriptive labels for all interactive elements including emotion scores and graph data points

2. WHEN the User views the flow graph THEN the System SHALL provide alternative text descriptions of emotion trends for accessibility

3. WHEN the User has color vision deficiency THEN the System SHALL support high contrast mode and pattern-based differentiation in addition to color coding

4. WHEN the User prefers reduced motion THEN the System SHALL disable animations and use instant transitions while maintaining functionality

5. WHEN the User interacts with the app in bright sunlight or dark environments THEN the System SHALL automatically adjust contrast and brightness based on ambient light sensors

6. WHEN the User wants to quickly record emotions THEN the System SHALL provide a home screen widget for one-tap emotion entry

7. WHEN the System displays text content THEN the System SHALL support dynamic font sizing from 80% to 150% of default size
