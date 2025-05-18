# 우중충 (Woo Joong Choong)

개인 맞춤형 날씨 및 코디 추천 서비스

## 프로젝트 소개

'우중충'은 사용자의 위치 기반 날씨 정보를 제공하고, 날씨에 적합한 옷차림을 추천하는 모바일 애플리케이션입니다. 일기 예보와 함께 개인 맞춤형 코디 추천, 캘린더 일정 관리, 위치 즐겨찾기 등 다양한 기능을 제공합니다.

## 주요 기능

- **실시간 날씨 정보**: 현재 위치 및 검색된 위치의 실시간 날씨 정보 제공
- **날씨 예보**: 시간별, 일별 날씨 예보 제공
- **코디 추천**: 현재 날씨에 맞는 옷차림 추천
- **위치 관리**: 자주 확인하는 위치 저장 및 관리
- **즐겨찾기**: 자주 찾는 위치 즐겨찾기 기능
- **캘린더 연동**: 일정과 날씨 정보 통합 관리
- **사용자 프로필**: 개인화된 서비스 제공을 위한 프로필 관리
- **알림 설정**: 날씨 변화 및 일정에 대한 알림 설정
- **다국어 지원**: 다양한 언어 지원 (한국어, 영어 등)

## 설치 방법

1. Flutter SDK 설치 (3.7.0 이상)

```bash
# Flutter SDK 설치 후
flutter pub get
flutter run
```

## 프로젝트 구조

```
lib/
├── main.dart              # 앱 시작점
├── routes.dart            # 라우트 정의
├── firebase/              # Firebase 설정 및 관련 코드
├── l10n/                  # 다국어 지원 파일
├── models/                # 데이터 모델
│   ├── weather_model.dart         # 날씨 관련 모델
│   ├── outfit_model.dart          # 옷차림 추천 모델
│   ├── calendar_event_model.dart  # 캘린더 이벤트 모델
│   ├── favorite_location_model.dart  # 즐겨찾기 위치 모델
│   └── user_model.dart            # 사용자 모델
├── providers/             # 상태 관리
│   ├── weather_provider.dart      # 날씨 상태 관리
│   ├── calendar_provider.dart     # 캘린더 상태 관리
│   ├── favorite_locations_provider.dart  # 즐겨찾기 상태 관리
│   └── user_provider.dart         # 사용자 상태 관리
├── services/              # 비즈니스 로직 및 API 호출
│   ├── weather_service.dart       # 날씨 API 서비스
│   ├── location_service.dart      # 위치 관련 서비스
│   ├── outfit_recommendation_service.dart  # 옷차림 추천 서비스
│   ├── notification_service.dart  # 알림 서비스
│   ├── app_preference_service.dart  # 앱 설정 서비스
│   ├── calendar_service.dart      # 캘린더 서비스
│   └── auth_service.dart          # 인증 서비스
├── utils/                # 유틸리티 함수 및 상수
│   ├── constants.dart           # 상수 정의
│   ├── colors.dart              # 색상 정의
│   ├── theme.dart               # 테마 정의
│   └── weather_icons.dart       # 날씨 아이콘 매핑
├── views/                # UI 화면
│   ├── splash/                 # 스플래시 화면
│   ├── onboarding/             # 온보딩 화면
│   ├── auth/                   # 인증 관련 화면
│   ├── home/                   # 홈 화면
│   │   ├── home_screen.dart       # 메인 홈 화면
│   │   └── tabs/                  # 탭 화면
│   │       ├── weather_tab.dart     # 날씨 탭
│   │       └── places_tab.dart      # 장소 탭
│   ├── calendar/               # 캘린더 화면
│   ├── settings/               # 설정 화면
│   ├── profile/                # 프로필 화면
│   └── favorites/              # 즐겨찾기 화면
└── widgets/              # 재사용 가능한 위젯
    ├── weather_icon.dart         # 날씨 아이콘 위젯
    ├── weather_summary_widget.dart  # 날씨 요약 위젯
    ├── outfit_recommendation_widget.dart  # 옷차림 추천 위젯
    ├── hourly_forecast_widget.dart  # 시간별 예보 위젯
    └── daily_forecast_widget.dart  # 일별 예보 위젯
```

## 사용 기술 및 라이브러리

- **Flutter & Dart**: UI 개발 및 로직 구현
- **Provider**: 상태 관리
- **HTTP**: API 통신
- **Geolocator & Geocoding**: 위치 서비스
- **SharedPreferences**: 로컬 데이터 저장
- **Firebase**: 인증 및 데이터베이스
- **Flutter Local Notifications**: 푸시 알림
- **Intl**: 다국어 및 날짜 포맷팅
- **Device Calendar**: 캘린더 통합

## API

- **OpenWeatherMap API**: 날씨 데이터 제공
- **Google Maps API**: 위치 검색 및 지오코딩

## 개발 환경 설정

1. Flutter SDK 3.7.0 이상 설치
2. OpenWeatherMap API 키 발급
   - `lib/utils/constants.dart` 파일에 API 키 추가
3. Firebase 프로젝트 설정
   - Firebase 콘솔에서 프로젝트 생성
   - `google-services.json` (Android) 및 `GoogleService-Info.plist` (iOS) 파일 추가

## 빌드 및 배포

### Android 빌드

```bash
flutter build apk --release
# 또는
flutter build appbundle --release
```

### iOS 빌드

```bash
flutter build ios --release
# Xcode에서 추가 설정 후 App Store Connect에 업로드
```
