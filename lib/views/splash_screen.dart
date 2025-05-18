import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../routes.dart';
import '../utils/colors.dart';

/// 앱 실행 시 표시되는 스플래시 화면
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // 로고 애니메이션
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
    
    // 앱 초기화 및 인증 상태 확인
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 앱 초기화 및 라우팅
  Future<void> _initializeApp() async {
    // UserProvider 초기화 대기 (2초 후 상태 확인)
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // 온보딩 완료 여부 확인
    if (!userProvider.isOnboardingCompleted) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }
    
    // 로그인 상태 확인
    if (userProvider.isLoggedIn) {
      // 프로필 설정 완료 여부 확인
      if (userProvider.isProfileSetupCompleted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
      }
    } else {
      // 로그인되지 않은 경우 로그인 화면으로 이동
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 애니메이션
            ScaleTransition(
              scale: _animation,
              child: Icon(
                Icons.cloud,
                size: 120,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 앱 이름
            FadeTransition(
              opacity: _animation,
              child: const Text(
                '날씨 앱',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // 로딩 인디케이터
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 