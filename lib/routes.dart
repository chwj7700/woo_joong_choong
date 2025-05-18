import 'package:flutter/material.dart';
import 'views/splash_screen.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/permission/permission_guide_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/auth/profile_setup_screen.dart';
import 'views/auth/forgot_password_screen.dart';
import 'views/home/home_screen.dart';
import 'views/profile/profile_menu_screen.dart';
import 'views/home/tabs/place_search_screen.dart';
import 'examples/personalized_weather_example.dart';
import 'views/favorites/favorite_list_screen.dart';
import 'views/favorites/add_favorite_screen.dart';
import 'views/favorites/favorite_detail_screen.dart';
// 설정 화면 import
import 'views/settings/settings_screen.dart';
import 'views/settings/user_profile_settings_screen.dart';
import 'views/settings/notification_settings_screen.dart';
import 'views/settings/unit_settings_screen.dart';
import 'views/settings/location_settings_screen.dart';
import 'views/settings/app_info_screen.dart';
import 'views/settings/help_screen.dart';
import 'views/settings/feedback_history_screen.dart';

// 아직 구현되지 않은 화면들은 주석 처리
// import 'views/profile/profile_screen.dart';
// import 'views/profile/profile_edit_screen.dart';
// import 'views/profile/settings_screen.dart';
// import 'views/profile/personalized_weather_example.dart';
import 'views/calendar/calendar_events_screen.dart';
import 'views/calendar/calendar_sync_screen.dart';
import 'views/calendar/calendar_event_detail_screen.dart';
import 'models/calendar_event_model.dart';
import 'models/favorite_location_model.dart';

/// 앱 라우팅 시스템 정의
class AppRoutes {
  // 라우트 이름 정의
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String permissionGuide = '/permission_guide';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot_password';
  static const String profileSetup = '/profile_setup';
  static const String home = '/home';
  static const String profileMenu = '/profile_menu';
  static const String favorites = '/favorites';
  static const String calendar = '/calendar';
  static const String settingsRoute = '/settings';
  static const String feedbackForm = '/feedback_form';
  static const String notificationDetail = '/notification_detail';
  static const String placeDetail = '/place_detail';
  static const String placeSearch = '/place_search';
  static const String weatherDetail = '/weather_detail';
  static const String appointmentDetail = '/appointment_detail';
  static const String personalizedWeatherExample = '/personalized_weather_example';
  static const String addFavorite = '/favorites/add';
  static const String favoriteDetail = '/favorite-detail';
  static const String calendarEvents = '/calendar-events';
  static const String calendarSync = '/calendar-sync';
  static const String calendarEventDetail = '/calendar-event-detail';
  static const String notifications = '/notifications';
  
  // 설정 화면 라우트
  static const String userProfileSettings = '/settings/profile';
  static const String notificationSettings = '/settings/notifications';
  static const String unitSettings = '/settings/units';
  static const String locationSettings = '/settings/location';
  static const String appInfo = '/settings/app-info';
  static const String helpScreen = '/settings/help';
  static const String feedbackHistory = '/settings/feedback-history';
  
  /// 라우트 정의
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    permissionGuide: (context) => const PermissionGuideScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    profileSetup: (context) => const ProfileSetupScreen(),
    home: (context) => const HomeScreen(),
    profileMenu: (context) => const ProfileMenuScreen(),
    favorites: (context) => const FavoriteListScreen(),
    calendar: (context) => const CalendarEventsScreen(),
    settingsRoute: (context) => const SettingsScreen(),
    feedbackForm: (context) => const Placeholder(color: Colors.lightGreen),
    notificationDetail: (context) => const Placeholder(color: Colors.pink),
    placeDetail: (context) => const Placeholder(color: Colors.deepPurple),
    placeSearch: (context) => const PlaceSearchScreen(),
    weatherDetail: (context) => const Placeholder(color: Colors.indigo),
    appointmentDetail: (context) => const Placeholder(color: Colors.blueGrey),
    personalizedWeatherExample: (context) => const PersonalizedWeatherExample(),
    addFavorite: (context) => const AddFavoriteScreen(),
    // favoriteDetail 라우트는 favorite_detail_screen.dart 파일에서 필요한 location 매개변수가 있어 generateRoute에서 처리합니다.
    calendarEvents: (context) => const CalendarEventsScreen(),
    calendarSync: (context) => const CalendarSyncScreen(),
    notifications: (context) => const Placeholder(color: Colors.pink),
    // calendarEventDetail은 필요한 인자가 있어 generateRoute에서 처리합니다
    
    // 설정 화면 라우트
    userProfileSettings: (context) => const UserProfileSettingsScreen(),
    notificationSettings: (context) => const NotificationSettingsScreen(),
    unitSettings: (context) => const UnitSettingsScreen(),
    locationSettings: (context) => const LocationSettingsScreen(),
    appInfo: (context) => const AppInfoScreen(),
    helpScreen: (context) => const HelpScreen(),
    feedbackHistory: (context) => const FeedbackHistoryScreen(),
  };

  /// 라우팅 시스템 생성
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // 라우트 전환 애니메이션 (기본값)
    const transitionDuration = Duration(milliseconds: 300);
    
    // routeName이 null일 수 있으므로 안전하게 처리
    final String? routeName = settings.name;

    // Dart 3.0+ 패턴 매칭을 활용한 switch 문법
    switch (routeName) {
      case splash:
        return _buildRoute(
          settings, 
          const SplashScreen(), 
          transitionDuration,
          fadeIn: true, 
          slideIn: false,
        );
      case onboarding:
        return _buildRoute(settings, const OnboardingScreen(), transitionDuration);
      case permissionGuide:
        return _buildRoute(settings, const PermissionGuideScreen(), transitionDuration);
      case login:
        return _buildRoute(settings, const LoginScreen(), transitionDuration);
      case signup:
        return _buildRoute(settings, const SignupScreen(), transitionDuration);
      case forgotPassword:
        return _buildRoute(settings, const ForgotPasswordScreen(), transitionDuration);
      case profileSetup:
        return _buildRoute(settings, const ProfileSetupScreen(), transitionDuration);
      case home:
        return _buildRoute(settings, const HomeScreen(), transitionDuration);
      case profileMenu:
        return _buildRoute(settings, const ProfileMenuScreen(), transitionDuration);
      case favorites:
        return _buildRoute(settings, const FavoriteListScreen(), transitionDuration);
      case calendar:
        return _buildRoute(settings, const CalendarEventsScreen(), transitionDuration);
      case settingsRoute:
        return _buildRoute(settings, const SettingsScreen(), transitionDuration);
      case feedbackForm:
        return _buildRoute(settings, const Placeholder(color: Colors.lightGreen), transitionDuration);
      case notificationDetail:
        return _buildRoute(settings, const Placeholder(color: Colors.pink), transitionDuration);
      case placeDetail:
        return _buildRoute(settings, const Placeholder(color: Colors.deepPurple), transitionDuration);
      case placeSearch:
        return _buildRoute(settings, const PlaceSearchScreen(), transitionDuration);
      case weatherDetail:
        return _buildRoute(settings, const Placeholder(color: Colors.indigo), transitionDuration);
      case appointmentDetail:
        return _buildRoute(settings, const Placeholder(color: Colors.blueGrey), transitionDuration);
      case personalizedWeatherExample:
        return _buildRoute(settings, const PersonalizedWeatherExample(), transitionDuration);
      case addFavorite:
        return _buildRoute(settings, const AddFavoriteScreen(), transitionDuration);
      case favoriteDetail:
        final location = settings.arguments as FavoriteLocation?;
        if (location == null) return _buildErrorRoute('위치 정보가 없습니다');
        return _buildRoute(settings, FavoriteDetailScreen(location: location), transitionDuration);
      case calendarEvents:
        return _buildRoute(settings, const CalendarEventsScreen(), transitionDuration);
      case calendarSync:
        return _buildRoute(settings, const CalendarSyncScreen(), transitionDuration);
      case calendarEventDetail:
        final args = settings.arguments as CalendarEvent?;
        if (args == null) return _buildErrorRoute('이벤트 정보가 없습니다');
        return _buildRoute(settings, CalendarEventDetailScreen(event: args), transitionDuration);
      case notifications:
        return _buildRoute(settings, const Placeholder(color: Colors.pink), transitionDuration);
      
      // 설정 화면 라우트
      case userProfileSettings:
        return _buildRoute(settings, const UserProfileSettingsScreen(), transitionDuration);
      case notificationSettings:
        return _buildRoute(settings, const NotificationSettingsScreen(), transitionDuration);
      case unitSettings:
        return _buildRoute(settings, const UnitSettingsScreen(), transitionDuration);
      case locationSettings:
        return _buildRoute(settings, const LocationSettingsScreen(), transitionDuration);
      case appInfo:
        return _buildRoute(settings, const AppInfoScreen(), transitionDuration);
      case helpScreen:
        return _buildRoute(settings, const HelpScreen(), transitionDuration);
      case feedbackHistory:
        return _buildRoute(settings, const FeedbackHistoryScreen(), transitionDuration);
        
      default:
        // 잘못된 라우트 처리
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('존재하지 않는 페이지입니다: $routeName'),
            ),
          ),
        );
    }
  }

  /// 페이지 전환 애니메이션과 함께 라우트 생성
  static PageRouteBuilder<dynamic> _buildRoute(
    RouteSettings settings,
    Widget page,
    Duration duration, {
    bool fadeIn = true,
    bool slideIn = true,
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: duration,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return page;
      },
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        if (fadeIn && slideIn) {
          // 페이드 인 + 슬라이드 애니메이션
          var begin = const Offset(0.0, 0.1);
          var end = Offset.zero;
          var curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        } else if (fadeIn) {
          // 페이드 인 애니메이션만
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        } else if (slideIn) {
          // 슬라이드 애니메이션만
          var begin = const Offset(0.0, 0.1);
          var end = Offset.zero;
          var curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        } else {
          // 애니메이션 없음
          return child;
        }
      },
    );
  }

  /// 에러 페이지 생성
  static PageRouteBuilder _buildErrorRoute(String message) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('오류'),
            elevation: 0,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('뒤로 가기'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
} 