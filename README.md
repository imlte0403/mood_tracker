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

**무드 트래커**는 일상의 감정을 기록하고 시각화하여, 나의 마음 흐름을 돌아볼 수 있도록 돕는 모바일 애플리케이션입니다.

감정을 8가지 유형으로 분류하고, 각 감정을 고유한 색상과 도형으로 표현하여 직관적이고 아름다운 감정 일기를 작성할 수 있습니다.

### 🎓 프로젝트 정보
- **유형**: 졸업 과제 (Graduation Assignment)
- **개발자**: bimong
- **버전**: 1.0.0
- **지원 플랫폼**: Android, iOS

---

## ✨ 주요 기능

### 현재 구현된 기능

#### 1️⃣ 감정 기록
- **8가지 감정 유형**: 행운 🍀, 행복 😊, 설렘 🥰, 보통 🙂, 우울 😞, 불안 😰, 분노 😡, 슬픔 😢
- **감정 강도 조절**: 슬라이더를 통한 세밀한 감정 표현
- **시각화**: 감정별 고유 색상과 도형으로 표현
- **메모 작성**: 감정과 함께 하루를 기록

#### 2️⃣ 타임라인
- **일별 타임라인**: 하루 동안 기록한 감정들을 시간순으로 확인
- **주별 캘린더**: 한 주의 감정 흐름을 한눈에 파악
- **감정 기록 수정**: 과거 기록을 언제든지 수정 가능

#### 3️⃣ 사용자 인증
- **이메일 로그인**: 전통적인 이메일/비밀번호 방식
- **Google 로그인**: 간편한 소셜 로그인
- **Apple 로그인**: iOS 사용자를 위한 Apple ID 연동

#### 4️⃣ 개인화
- **다크 모드**: 라이트/다크 테마 지원
- **시스템 테마 연동**: 기기 설정에 따라 자동 전환
- **Pretendard 폰트**: 가독성 높은 한글 폰트 적용

#### 5️⃣ 설정 및 정보
- **계정 관리**: 프로필 편집, 비밀번호 변경, 계정 삭제
- **개인정보 보호정책**: 투명한 데이터 처리 안내
- **도움말**: 앱 사용 가이드

### 🚀 향후 추가 예정 기능

- [ ] **감정 통계 및 분석**: 주간/월간 감정 분포 차트
- [ ] **감정 기록 검색**: 날짜, 감정 유형, 키워드로 검색
- [ ] **감정 기록 삭제**: 개별 또는 일괄 삭제 기능
- [ ] **데이터 내보내기**: JSON/CSV 형식으로 백업
- [ ] **푸시 알림**: 일일 감정 기록 리마인더
- [ ] **위젯**: 홈 화면에서 빠른 감정 기록
- [ ] **다국어 지원**: 영어 번역 추가

---

## 🛠 기술 스택

### Frontend
- **Framework**: Flutter 3.9.2
- **상태 관리**: Riverpod 2.6.1
- **라우팅**: go_router 14.6.2

### Backend
- **인증**: Firebase Authentication
- **데이터베이스**: Cloud Firestore
- **스토리지**: Firebase Storage

### 주요 패키지
```yaml
dependencies:
  flutter_riverpod: ^2.6.1          # 상태 관리
  go_router: ^14.6.2                # 라우팅
  firebase_core: ^3.6.0             # Firebase 코어
  firebase_auth: ^5.3.1             # 인증
  cloud_firestore: ^5.4.3           # NoSQL DB
  firebase_storage: ^12.3.2         # 파일 저장소
  google_sign_in: ^6.2.1            # Google 로그인
  sign_in_with_apple: ^6.1.0        # Apple 로그인
  morphable_shape: ^2.0.0           # 감정 도형 시각화
  shared_preferences: ^2.5.3        # 로컬 저장소
```

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
git clone https://github.com/yourusername/mood_tracker.git
cd mood_tracker
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **Firebase 설정**
   - [Firebase 설정](#-firebase-설정) 섹션 참조

4. **앱 실행**
```bash
# Android
flutter run

# iOS (macOS에서만 가능)
flutter run -d ios

# 특정 기기 선택
flutter devices
flutter run -d <device_id>
```

5. **빌드**
```bash
# Android APK
flutter build apk --release

# Android App Bundle (Google Play 배포용)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 📁 프로젝트 구조

```
mood_tracker/
├── lib/
│   ├── core/                    # 핵심 공통 모듈
│   │   ├── constants/           # 상수 (색상, 크기, 텍스트 스타일)
│   │   ├── models/              # 데이터 모델 (EmotionType, TimelineEntry)
│   │   ├── providers/           # 전역 Provider (인증, 테마)
│   │   └── utils/               # 유틸리티 함수
│   ├── features/                # 기능별 모듈
│   │   ├── auth/                # 인증 (로그인, 회원가입)
│   │   ├── home/                # 홈 화면 (타임라인, 캘린더)
│   │   ├── post/                # 감정 기록 작성/수정
│   │   └── settings/            # 설정 화면
│   ├── router/                  # 라우팅 설정
│   └── main.dart                # 앱 진입점
├── assets/
│   ├── fonts/                   # Pretendard 폰트
│   └── images/                  # 이미지 리소스
├── android/                     # Android 네이티브 코드
├── ios/                         # iOS 네이티브 코드
├── docs/                        # 문서
│   ├── privacy_policy.md        # 개인정보 보호정책
│   └── terms_of_service.md      # 서비스 이용약관
├── firestore.rules              # Firestore 보안 규칙
├── storage.rules                # Firebase Storage 보안 규칙
└── pubspec.yaml                 # 프로젝트 설정
```

### 아키텍처

본 프로젝트는 **Feature-First** 구조를 따릅니다:

- **core/**: 앱 전체에서 공유되는 코드
- **features/**: 기능별로 독립적인 모듈 (화면, 뷰모델, 위젯)
- **Riverpod**: 의존성 주입 및 상태 관리
- **Repository Pattern**: 데이터 레이어 추상화

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

### Phase 1: 스토어 배포 준비 (현재)
- [x] 필수 개선사항 완료
  - [x] Firebase 보안 규칙 설정
  - [x] Android/iOS 권한 설정
  - [x] 법적 문서 작성 (개인정보 보호정책, 서비스 이용약관)
  - [x] README 보강
- [ ] 앱 아이콘 디자인
- [ ] 스플래시 스크린 디자인
- [ ] 스토어 리스팅 자료 준비

### Phase 2: 핵심 기능 추가
- [ ] 감정 통계 및 분석 차트
- [ ] 감정 기록 검색 기능
- [ ] 감정 기록 삭제 기능
- [ ] 데이터 내보내기 기능

### Phase 3: 사용자 경험 개선
- [ ] 온보딩 화면
- [ ] 푸시 알림
- [ ] 위젯 지원
- [ ] 접근성 개선

### Phase 4: 확장
- [ ] 다국어 지원 (영어)
- [ ] 소셜 기능 (공유, 커뮤니티)
- [ ] AI 기반 감정 분석 및 조언

---

## 🤝 기여하기

본 프로젝트는 졸업 과제로 진행되고 있습니다. 버그 리포트나 기능 제안은 환영합니다!

### 버그 리포트
- GitHub Issues에 등록해 주세요
- 재현 방법, 스크린샷, 로그를 포함해 주시면 감사하겠습니다

### 기능 제안
- Discussions 탭에서 아이디어를 공유해 주세요

---

## 📄 라이선스

본 프로젝트는 학술 목적으로 제작되었습니다. 상업적 이용은 제한될 수 있습니다.

### 오픈소스 라이선스
본 앱은 다음의 오픈소스 라이브러리를 사용합니다:
- **Flutter**: BSD-3-Clause License
- **Firebase**: Apache-2.0 License
- **Riverpod**: MIT License
- **go_router**: BSD-3-Clause License

자세한 라이선스 정보는 앱 내 "설정 > 앱 소개 > 라이선스"에서 확인할 수 있습니다.

---

## 📞 문의

### 개발자
- **이름**: bimong
- **이메일**: support@moodtracker.app

### 문서
- [개인정보 보호정책](docs/privacy_policy.md)
- [서비스 이용약관](docs/terms_of_service.md)

### 링크
- GitHub Issues: [이슈 등록](https://github.com/yourusername/mood_tracker/issues)
- Discussions: [토론 참여](https://github.com/yourusername/mood_tracker/discussions)

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
