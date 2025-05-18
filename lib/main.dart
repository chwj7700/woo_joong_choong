import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
// Firebase 패키지 다시 활성화
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';
import 'providers/user_provider.dart';
import 'providers/weather_provider.dart';
import 'routes.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';

// 다국어 지원을 위한 import (Flutter gen-l10n 사용)
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// 즐겨찾기 서비스 및 Provider 추가
import 'services/favorite_location_repository.dart';
import 'providers/favorite_locations_provider.dart';
import 'services/weather_service.dart';

// 캘린더 연동 및 알림 서비스 추가
import 'services/calendar_service.dart';
import 'services/notification_service.dart';
import 'providers/calendar_provider.dart';
import 'package:woo_joong_choong/views/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 즐겨찾기 저장소 초기화 추가
  final favoriteRepository = LocalFavoriteLocationRepository();
  
  // 날씨 서비스 초기화 (공유 인스턴스)
  final weatherService = WeatherService(
    apiKey: AppConstants.weatherApiKey,
  );
  
  // 알림 서비스 초기화
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // 캘린더 서비스 초기화
  final calendarService = CalendarService();
  
  // Firebase 초기화 복원
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // firebase_options.dart에 실제 Firebase 설정이 있는지 확인
    if (DefaultFirebaseOptions.web.apiKey.startsWith('YOUR_')) {
      print('Firebase 설정이 완료되지 않았습니다. 테스트 모드로 실행합니다.');
      firebaseInitialized = false;
    } else {
      firebaseInitialized = true;
      print('Firebase 초기화 성공');
    }
  } catch (e) {
    print('Firebase 초기화 실패: $e');
    // 초기화 실패 시 앱은 제한된 기능으로 계속 실행됩니다.
    firebaseInitialized = false;
  }
  
  // 앱 초기화 (권한 요청, 저장된 설정 불러오기 등)
  // TODO: 필요한 초기화 코드 구현
  
  runApp(
    MultiProvider(
      providers: [
        // UserProvider에 Firebase 초기화 상태 전달
        ChangeNotifierProvider(create: (_) => UserProvider(firebaseEnabled: firebaseInitialized)),
        // 날씨 데이터 Provider 추가
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(
            apiKey: AppConstants.weatherApiKey,
            autoRefresh: true,
          ),
        ),
        // 즐겨찾기 Provider 추가
        ChangeNotifierProvider<FavoriteLocationsProvider>(
          create: (_) => FavoriteLocationsProvider(
            repository: favoriteRepository,
            weatherService: weatherService,
          ),
        ),
        // 캘린더 Provider 추가
        ChangeNotifierProvider<CalendarProvider>(
          create: (_) => CalendarProvider(
            calendarService: calendarService,
            weatherService: weatherService,
            notificationService: notificationService,
          ),
        ),
      ],
      child: MaterialApp(
        title: '우중충',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // utils/theme.dart에 정의된 테마
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.generateRoute, // 애니메이션이 있는 라우트 생성 함수도 유지
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', ''), // 한국어
          Locale('en', ''), // 영어
        ],
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;
  
  const MyApp({super.key, required this.firebaseInitialized});

  @override
  Widget build(BuildContext context) {
    print('Firebase 초기화 상태: $firebaseInitialized');
    
    return MultiProvider(
      providers: [
        // UserProvider에 Firebase 초기화 상태 전달
        ChangeNotifierProvider(create: (_) => UserProvider(firebaseEnabled: firebaseInitialized)),
        // 날씨 데이터 Provider 추가
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(
            apiKey: AppConstants.weatherApiKey,
            autoRefresh: true,
          ),
        ),
        // 즐겨찾기 Provider 추가
        ChangeNotifierProvider<FavoriteLocationsProvider>(
          create: (_) => FavoriteLocationsProvider(
            repository: LocalFavoriteLocationRepository(),
            weatherService: WeatherService(apiKey: AppConstants.weatherApiKey),
          ),
        ),
        // 캘린더 Provider 추가
        ChangeNotifierProvider<CalendarProvider>(
          create: (_) => CalendarProvider(
            calendarService: CalendarService(),
            weatherService: WeatherService(apiKey: AppConstants.weatherApiKey),
            notificationService: NotificationService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: '우중충',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // utils/theme.dart에 정의된 테마
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.generateRoute, // 애니메이션이 있는 라우트 생성 함수도 유지
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', ''), // 한국어
          Locale('en', ''), // 영어
        ],
      ),
    );
  }
}
