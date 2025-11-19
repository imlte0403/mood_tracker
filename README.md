# 🌈 무드 트래커 (Mood Tracker)

> 하루의 마음과 감정을 잔잔한 시각화로 기록하며 스스로를 돌볼 수 있는 공간

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Academic-blue)](LICENSE)

---

## 📖 목차

- [개요](#-개요)
- [주요 기능](#-주요-기능)
- [기술 스택](#-기술-스택)
- [시작하기](#-시작하기)
- [프로젝트 구조](#-프로젝트-구조)
- [Firebase 설정](#-firebase-설정)
- [스크린샷](#-스크린샷)
- [로드맵](#-로드맵)
- [기여하기](#-기여하기)
- [라이선스](#-라이선스)
- [문의](#-문의)

---

## 🎯 개요

**무드 트래커**는 일상의 감정을 기록하고 시각화하며, 심리학 이론에 기반한 분석과 조언을 제공하는 감정 관리 애플리케이션입니다.

### 핵심 가치
- 🎨 **직관적 시각화**: 8가지 감정을 고유한 색상과 도형으로 표현
- 📊 **데이터 기반 분석**: 감정 패턴을 차트와 통계로 분석
- 💡 **실용적 조언**: 심리학 이론(CBT, 긍정심리학 등)에 기반한 구체적 인사이트 제공
- 🔒 **프라이버시 우선**: 모든 데이터는 개인 계정에 안전하게 저장

### 🎓 프로젝트 정보
- **개발자**: bimong
- **버전**: 1.0.0+1
- **지원 플랫폼**: Android, iOS
- **최소 요구사항**: Android 6.0+ (API 23), iOS 12.0+

---

## ✨ 주요 기능

### 현재 구현된 기능

#### 1️⃣ 감정 기록 및 관리
- **8가지 감정 유형 분류**
  - 긍정 감정: 행운 🍀, 행복 😊, 설렘 🥰
  - 중립 감정: 보통 🙂
  - 부정 감정: 우울 😞, 불안 😰, 분노 😡, 슬픔 😢
- **감정 강도 조절**: 슬라이더를 통한 세밀한 감정 표현 (0-100)
- **시각화**: 감정별 고유 색상과 morphable shape 도형으로 표현
- **메모 작성**: 감정과 함께 하루를 상세히 기록
- **기록 수정/삭제**: 과거 기록을 언제든지 편집하거나 삭제 가능

#### 2️⃣ 타임라인 및 캘린더
- **일별 타임라인**: 하루 동안 기록한 감정들을 시간순으로 확인
- **주별 캘린더**: 한 주의 감정 흐름을 한눈에 파악
- **날짜별 필터링**: 특정 날짜의 감정 기록만 확인

#### 3️⃣ 감정 통계 및 분석 📊 (NEW)
- **스와이프 네비게이션**: 홈 화면에서 오른쪽 스와이프로 통계 화면 접근
- **기간별 통계**
  - 최근 1주일 / 1개월 / 전체 기간 선택 가능
  - 총 기록 수, 가장 많이 느낀 감정, 감정 다양성 점수 표시
- **감정 분포 차트**
  - **파이 차트**: 8가지 감정의 비율을 시각적으로 표현
  - **바 차트**: 일별 감정 변화를 막대 그래프로 표시
  - 터치 인터랙션으로 상세 정보 확인
- **심리학 기반 감정 분석** 💡
  - 5단계 감정 레벨 분류 (매우 긍정 → 긍정 → 균형 → 부정 → 매우 부정)
  - 긍정/부정 감정 비율 자동 계산
  - **심리이론 기반 조언 제공**
    - 긍정심리학 (감사 일지, 강점 기록)
    - 인지행동치료 (CBT - 원인 파악, 대처 전략)
    - 정서조절이론 (규칙적 생활 리듬)
    - 행동활성화 치료 (긍정 경험 늘리기)
    - 위기개입이론 (전문가 도움 권장)
  - 실천 가능한 구체적 행동 지침 제시
  - 필요 시 전문 상담 안내 (정신건강의학과, 위기상담전화)

#### 4️⃣ 사용자 인증
- **이메일 로그인**: 전통적인 이메일/비밀번호 방식
- **Google 로그인**: 간편한 소셜 로그인
- **Apple 로그인**: iOS 사용자를 위한 Apple ID 연동 (Sign in with Apple)
- **자동 로그인**: 한 번 로그인하면 자동으로 세션 유지

#### 5️⃣ 개인화 및 테마
- **다크 모드**: 라이트/다크 테마 지원
- **시스템 테마 연동**: 기기 설정에 따라 자동 전환
- **Pretendard 폰트**: 가독성 높은 한글 폰트 적용 (Regular, SemiBold, Bold)

#### 6️⃣ 설정 및 정보
- **계정 관리**: 프로필 편집, 비밀번호 변경, 계정 삭제
- **개인정보 보호정책**: 투명한 데이터 처리 안내
- **서비스 이용약관**: 명확한 서비스 규정
- **도움말**: 앱 사용 가이드

### 🚀 향후 추가 예정 기능

- [ ] **감정 기록 검색**: 날짜, 감정 유형, 키워드로 검색 (왼쪽 스와이프 예정)
- [ ] **데이터 내보내기**: JSON/CSV 형식으로 백업
- [ ] **푸시 알림**: 일일 감정 기록 리마인더
- [ ] **위젯**: 홈 화면에서 빠른 감정 기록
- [ ] **다국어 지원**: 영어 번역 추가
- [ ] **온보딩 화면**: 신규 사용자를 위한 사용 가이드

---

## 🛠 기술 스택

### Frontend
- **Framework**: Flutter 3.9.2 / Dart 3.9.2
- **상태 관리**: Riverpod 2.6.1 (Provider 패턴)
- **라우팅**: go_router 14.6.2 (선언적 라우팅)
- **아키텍처**: Feature-First + Repository Pattern

### Backend (Firebase)
- **인증**: Firebase Authentication (Email, Google, Apple)
- **데이터베이스**: Cloud Firestore (NoSQL, 실시간 동기화)
- **스토리지**: Firebase Storage (이미지 저장)
- **보안**: User-scoped Security Rules

### 데이터 시각화
- **차트 라이브러리**: fl_chart 0.68.0
  - 파이 차트로 감정 분포 표시
  - 바 차트로 일별 감정 추이 표시
  - 터치 인터랙션 지원
- **도형 시각화**: morphable_shape 2.0.0
  - 감정별 커스텀 도형 생성

### 주요 패키지
```yaml
dependencies:
  # 상태 관리 & 라우팅
  flutter_riverpod: ^2.6.1          # 상태 관리, 의존성 주입
  go_router: ^14.6.2                # 선언적 라우팅

  # Firebase
  firebase_core: ^3.6.0             # Firebase 코어
  firebase_auth: ^5.3.1             # 사용자 인증
  cloud_firestore: ^5.4.3           # NoSQL 데이터베이스
  firebase_storage: ^12.3.2         # 파일 저장소

  # 소셜 로그인
  google_sign_in: ^6.2.1            # Google 로그인
  sign_in_with_apple: ^6.1.0        # Apple 로그인
  crypto: ^3.0.3                    # 암호화

  # UI & 시각화
  morphable_shape: ^2.0.0           # 커스텀 도형 생성
  fl_chart: ^0.68.0                 # 차트 라이브러리

  # 유틸리티
  shared_preferences: ^2.5.3        # 로컬 저장소 (테마 설정 등)
  url_launcher: ^6.3.0              # 외부 링크 열기
  intl: ^0.19.0                     # 날짜/시간 포맷팅
```

### 개발 도구
- **Linting**: flutter_lints 5.0.0
- **버전 관리**: Git
- **CI/CD**: GitHub Actions (예정)

---

## 🚀 시작하기

### 사전 요구사항

- Flutter SDK 3.9.2 이상
- Dart SDK 3.9.2 이상
- Android Studio / Xcode (플랫폼별)
- Firebase 프로젝트 (설정 방법은 아래 참조)

### 설치 및 실행

1. **저장소 클론**
```bash
git clone https://github.com/imlte0403/mood_tracker.git
cd mood_tracker
```

2. **Flutter 버전 확인**
```bash
flutter --version
# Flutter 3.9.2 이상, Dart 3.9.2 이상 필요
```

3. **의존성 설치**
```bash
flutter pub get
```

4. **Firebase 설정** (필수)
   - [Firebase 설정](#-firebase-설정) 섹션의 상세 가이드를 따라주세요
   - `google-services.json` (Android) 및 `GoogleService-Info.plist` (iOS) 파일 필요
   - FlutterFire CLI 사용을 권장합니다

5. **앱 실행**
```bash
# 연결된 기기 확인
flutter devices

# Android 실행
flutter run

# iOS 실행 (macOS에서만 가능)
flutter run -d ios

# 특정 기기 선택
flutter run -d <device_id>
```

6. **빌드**
```bash
# Android APK (테스트용)
flutter build apk --release

# Android App Bundle (Google Play 배포용)
flutter build appbundle --release

# iOS (App Store 배포용)
flutter build ios --release

# iOS 시뮬레이터용
flutter build ios --debug
```

### 문제 해결

#### Firebase 연결 오류
```bash
# Firebase 설정 재생성
flutterfire configure

# iOS의 경우 Pod 재설치
cd ios && pod install && cd ..
```

#### 빌드 오류
```bash
# 캐시 정리
flutter clean
flutter pub get

# iOS 전용: DerivedData 정리
rm -rf ~/Library/Developer/Xcode/DerivedData
```

---

## 📁 프로젝트 구조

```
mood_tracker/
├── lib/
│   ├── core/                    # 핵심 공통 모듈
│   │   ├── constants/           # 상수 (색상, 크기, 텍스트 스타일)
│   │   │   ├── colors.dart      # 감정별 색상 정의
│   │   │   ├── sizes.dart       # UI 크기 상수
│   │   │   └── text_styles.dart # 텍스트 스타일
│   │   ├── models/              # 공통 데이터 모델
│   │   │   ├── emotion_type.dart       # 8가지 감정 enum
│   │   │   └── timeline_entry.dart     # 타임라인 항목
│   │   ├── providers/           # 전역 Provider
│   │   │   ├── auth_provider.dart      # 인증 상태 관리
│   │   │   └── theme_provider.dart     # 테마 상태 관리
│   │   └── utils/               # 유틸리티 함수
│   │       └── auth_utils.dart  # 인증 헬퍼 함수
│   │
│   ├── features/                # 기능별 모듈 (Feature-First)
│   │   ├── analytics/           # 📊 감정 통계 및 분석 (NEW)
│   │   │   ├── analytics_screen.dart          # 통계 화면
│   │   │   ├── analytics_viewmodel.dart       # 상태 관리
│   │   │   ├── models/                         # 분석 모델
│   │   │   │   ├── analytics_period.dart      # 기간 (주/월/전체)
│   │   │   │   ├── mood_statistics.dart       # 감정 통계
│   │   │   │   ├── mood_analysis.dart         # 감정 분석 (5단계)
│   │   │   │   └── daily_mood_distribution.dart
│   │   │   ├── data/                           # 데이터 레이어
│   │   │   │   └── analytics_repository.dart  # Firestore 쿼리
│   │   │   └── widgets/                        # 차트 위젯
│   │   │       ├── statistics_card.dart        # 요약 카드
│   │   │       ├── mood_analysis_card.dart     # 분석 글 카드
│   │   │       ├── emotion_pie_chart.dart      # 파이 차트
│   │   │       ├── daily_bar_chart.dart        # 바 차트
│   │   │       └── empty_analytics.dart        # 빈 상태
│   │   │
│   │   ├── auth/                # 🔐 인증 (로그인, 회원가입)
│   │   │   ├── screen/          # 화면
│   │   │   ├── viewmodel/       # 상태 관리
│   │   │   └── widgets/         # 재사용 위젯
│   │   │
│   │   ├── home/                # 🏠 홈 화면 (타임라인, 캘린더)
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │
│   │   ├── main/                # 📱 메인 탭 뷰 (PageView)
│   │   │   └── main_tab_view.dart  # 스와이프 네비게이션
│   │   │
│   │   ├── post/                # ✍️ 감정 기록 작성/수정
│   │   │   ├── post_screen.dart
│   │   │   └── widgets/
│   │   │
│   │   └── settings/            # ⚙️ 설정 화면
│   │       ├── settings_screen.dart
│   │       └── widgets/
│   │
│   ├── router/                  # 라우팅 설정
│   │   └── app_router.dart      # go_router 설정
│   │
│   └── main.dart                # 앱 진입점
│
├── assets/
│   ├── fonts/                   # Pretendard 폰트
│   │   ├── Pretendard-Regular.ttf
│   │   ├── Pretendard-SemiBold.ttf
│   │   └── Pretendard-Bold.ttf
│   └── images/                  # 이미지 리소스
│       └── hand_drawing.png
│
├── android/                     # Android 네이티브 코드
│   └── app/
│       ├── src/main/AndroidManifest.xml  # 권한 설정
│       └── google-services.json          # Firebase 설정
│
├── ios/                         # iOS 네이티브 코드
│   └── Runner/
│       ├── Info.plist           # 권한 설명
│       └── GoogleService-Info.plist
│
├── docs/                        # 문서
│   ├── privacy_policy.md        # 개인정보 보호정책
│   ├── terms_of_service.md      # 서비스 이용약관
│   └── FEATURE_PLAN.md          # 기능 구현 계획
│
├── firestore.rules              # Firestore 보안 규칙
├── storage.rules                # Firebase Storage 보안 규칙
└── pubspec.yaml                 # 프로젝트 설정 및 의존성
```

### 아키텍처 패턴

본 프로젝트는 **Feature-First + Clean Architecture** 원칙을 따릅니다:

#### 1. Feature-First 구조
```
features/
└── analytics/              # 기능 단위로 캡슐화
    ├── analytics_screen.dart     # Presentation Layer
    ├── analytics_viewmodel.dart  # Business Logic Layer
    ├── models/                   # Domain Layer
    ├── data/                     # Data Layer
    └── widgets/                  # UI Components
```

#### 2. 레이어 분리
- **Presentation Layer**: Screen, Widget (UI)
- **Business Logic Layer**: ViewModel (Riverpod StateNotifier)
- **Domain Layer**: Models, Entities
- **Data Layer**: Repository (Firestore 추상화)

#### 3. 상태 관리
- **Riverpod**: 의존성 주입 및 상태 관리
- **StateNotifier**: 불변 상태 관리
- **Provider**: 전역 상태 공유

#### 4. 데이터 흐름
```
UI → ViewModel → Repository → Firestore
 ↑       ↓           ↓
State  Update    Query/Write
```

---

## 🔥 Firebase 설정

### 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름 입력 (예: mood-tracker)
4. Google Analytics 설정 (선택사항)

### 2. Android 앱 등록

1. Firebase Console에서 Android 앱 추가
2. 패키지 이름 입력: `com.example.mood_tracker` (또는 실제 패키지명)
3. `google-services.json` 다운로드
4. `android/app/` 폴더에 파일 복사

### 3. iOS 앱 등록

1. Firebase Console에서 iOS 앱 추가
2. 번들 ID 입력 (Xcode에서 확인)
3. `GoogleService-Info.plist` 다운로드
4. Xcode에서 `ios/Runner/` 폴더에 파일 추가

### 4. FlutterFire CLI 사용 (권장)

```bash
# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 프로젝트와 연동
flutterfire configure

# 플랫폼 선택 (Android, iOS)
# firebase_options.dart 파일이 자동 생성됩니다
```

### 5. Firebase 서비스 활성화

#### Authentication
1. Firebase Console > Authentication > 시작하기
2. 로그인 방법 탭에서 활성화:
   - 이메일/비밀번호
   - Google
   - Apple (iOS 전용)

#### Firestore Database
1. Firebase Console > Firestore Database > 데이터베이스 만들기
2. **프로덕션 모드**로 시작
3. 리전 선택: `asia-northeast3` (서울)
4. 보안 규칙 배포:

```bash
firebase deploy --only firestore:rules
```

또는 Firebase Console에서 `firestore.rules` 파일 내용 복사

#### Storage
1. Firebase Console > Storage > 시작하기
2. 기본 위치 선택: `asia-northeast3`
3. 보안 규칙 배포:

```bash
firebase deploy --only storage
```

### 6. 보안 규칙 확인

**Firestore** (`firestore.rules`):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /moods/{moodId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

**Storage** (`storage.rules`):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 📸 스크린샷

> 📝 **Note**: 스크린샷은 추후 추가 예정입니다.

**홈 화면**
- 주간 캘린더
- 일일 타임라인

**감정 기록 화면**
- 감정 선택 슬라이더
- 감정 도형 시각화
- 메모 작성

**설정 화면**
- 테마 설정
- 계정 관리
- 개인정보 보호

---

## 🗺 로드맵

### Phase 1: 스토어 배포 준비 ✅ (완료)
- [x] 필수 개선사항 완료
  - [x] Firebase 보안 규칙 설정 (User-scoped)
  - [x] Android/iOS 권한 설정
  - [x] 법적 문서 작성 (개인정보 보호정책, 서비스 이용약관)
  - [x] README 상세 작성
- [x] 핵심 기능 구현
  - [x] 감정 통계 및 분석 차트 (파이/바 차트)
  - [x] 심리학 기반 감정 분석 글 (5단계)
  - [x] 스와이프 네비게이션 (PageView)
  - [x] 감정 기록 삭제 기능
- [ ] 스토어 배포 자료 (후순위)
  - [ ] 앱 아이콘 디자인
  - [ ] 스플래시 스크린 디자인
  - [ ] 스토어 스크린샷 및 프로모션 그래픽

### Phase 2: 검색 및 데이터 관리 (진행 예정)
- [ ] 감정 기록 검색 기능 (왼쪽 스와이프)
  - [ ] 날짜별 검색
  - [ ] 감정 유형별 필터링
  - [ ] 키워드 검색
- [ ] 데이터 내보내기 기능
  - [ ] JSON 형식 백업
  - [ ] CSV 형식 내보내기
- [ ] 데이터 가져오기/복원

### Phase 3: 사용자 경험 개선
- [ ] 온보딩 화면 (스와이프 가이드)
- [ ] 푸시 알림
  - [ ] 일일 감정 기록 리마인더
  - [ ] 주간 통계 요약
- [ ] 홈 화면 위젯 (빠른 기록)
- [ ] 접근성 개선
  - [ ] VoiceOver/TalkBack 지원
  - [ ] 색상 대비 개선
  - [ ] 폰트 크기 조절

### Phase 4: 확장 기능
- [ ] 다국어 지원 (영어)
- [ ] 고급 분석 기능
  - [ ] 월간/연간 트렌드 분석
  - [ ] 감정 상관관계 분석
  - [ ] 예측 모델 (감정 패턴 예측)
- [ ] 소셜 기능 (선택적)
  - [ ] 익명 감정 공유
  - [ ] 커뮤니티 기능
- [ ] AI 기반 조언 (심화)
  - [ ] GPT 연동 맞춤형 조언
  - [ ] 음성/텍스트 감정 분석

### 완료된 주요 마일스톤
- ✅ **2024.11**: 기본 감정 기록 및 타임라인 기능 구현
- ✅ **2024.11**: Firebase 인증 및 데이터베이스 연동
- ✅ **2024.11**: 감정 통계/분석 시스템 구현
- ✅ **2024.11**: 심리학 기반 분석 글 기능 추가

---

## 🤝 기여하기

버그 리포트나 기능 제안은 언제든 환영합니다!

### 버그 리포트
- GitHub Issues에 등록해 주세요
- 재현 방법, 스크린샷, 로그를 포함해 주시면 감사하겠습니다

### 기능 제안
- Discussions 탭에서 아이디어를 공유해 주세요

---

## 📄 라이선스

### 오픈소스 라이선스
본 앱은 다음의 오픈소스 라이브러리를 사용합니다:
- **Flutter**: BSD-3-Clause License
- **Firebase**: Apache-2.0 License
- **Riverpod**: MIT License
- **go_router**: BSD-3-Clause License

자세한 라이선스 정보는 앱 내 "설정 > 앱 소개 > 라이선스"에서 확인할 수 있습니다.

---

## 💡 사용 가이드

### 기본 사용법

#### 1. 감정 기록하기
1. 홈 화면에서 **"감정 기록하기"** 버튼 클릭
2. 현재 느끼는 감정을 8가지 중 선택
3. 슬라이더로 감정 강도 조절 (0-100)
4. 메모 작성 (선택사항)
5. **"저장"** 버튼으로 기록 완료

#### 2. 통계 확인하기
1. 홈 화면에서 **오른쪽으로 스와이프**
2. 기간 선택 (1주일/1개월/전체)
3. 차트 터치로 상세 정보 확인
4. 감정 분석 글에서 맞춤형 조언 확인

#### 3. 과거 기록 관리
- **수정**: 타임라인에서 기록 탭 → 수정
- **삭제**: 타임라인에서 기록 탭 → 삭제

### 감정 분석 이해하기

앱은 당신의 감정 기록을 5단계로 분류합니다:

| 레벨 | 조건 | 제공되는 조언 |
|------|------|---------------|
| 🌸 매우 긍정적 | 긍정 감정 70%+ | 긍정심리학 기반 패턴 유지 전략 |
| ☀️ 긍정적 | 긍정 감정 50-70% | 인지행동치료 기반 대처 전략 |
| 🌗 균형적 | 긍정/부정 비슷 | 정서조절이론 기반 안정화 방법 |
| 🌧️ 부정적 | 부정 감정 50-70% | 행동활성화 치료 기반 개선 방법 |
| 🌑 매우 부정적 | 부정 감정 70%+ | 위기개입이론 기반 전문가 도움 안내 |

### 데이터 보안

- 모든 감정 기록은 **개인 Firebase 계정**에만 저장됩니다
- 다른 사용자는 **절대 접근 불가**능합니다
- Firestore Security Rules로 강력하게 보호됩니다

---

## 📞 문의 및 지원

### 개발자
- **이름**: bimong
- **GitHub**: [@imlte0403](https://github.com/imlte0403)
- **Repository**: [mood_tracker](https://github.com/imlte0403/mood_tracker)

### 문서
- [개인정보 보호정책](docs/privacy_policy.md)
- [서비스 이용약관](docs/terms_of_service.md)
- [기능 구현 계획](docs/FEATURE_PLAN.md)

### 지원
- **버그 신고**: [GitHub Issues](https://github.com/imlte0403/mood_tracker/issues)
- **기능 제안**: [GitHub Discussions](https://github.com/imlte0403/mood_tracker/discussions)

### 위기 상담
앱 사용 중 정신건강에 어려움을 느끼신다면:
- 📞 정신건강위기상담: **1577-0199** (24시간)
- 📞 자살예방상담: **1393** (24시간)
- 🏥 가까운 정신건강복지센터 방문을 권장합니다

---

## 🙏 감사의 말

본 프로젝트를 진행하며 도움을 주신 모든 분들께 감사드립니다.

특히:
- Flutter 커뮤니티의 훌륭한 패키지들
- Firebase의 강력한 백엔드 서비스
- Pretendard 폰트를 제공해 주신 제작자분들

---

<div align="center">

**무드 트래커와 함께 당신의 감정을 돌보세요** 🌈

Made with ❤️ by bimong

</div>
