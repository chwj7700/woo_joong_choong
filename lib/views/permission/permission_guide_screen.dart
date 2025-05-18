import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/colors.dart';
import '../../routes.dart';
import 'permission_item.dart';

/// 앱에서 필요한 권한 안내 및 요청 화면
class PermissionGuideScreen extends StatefulWidget {
  const PermissionGuideScreen({super.key});

  @override
  State<PermissionGuideScreen> createState() => _PermissionGuideScreenState();
}

class _PermissionGuideScreenState extends State<PermissionGuideScreen> {
  // 권한 상태 관리
  bool _isLocationGranted = false;
  bool _isNotificationGranted = false;
  bool _isCalendarGranted = false;
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  
  /// 현재 권한 상태 확인
  Future<void> _checkPermissions() async {
    // 웹에서는 일부 권한이 지원되지 않으므로 플랫폼 체크
    if (kIsWeb) {
      // 웹에서는 모든 권한을 미허용 상태로 표시
      setState(() {
        _isLocationGranted = false;
        _isNotificationGranted = false;
        _isCalendarGranted = false;
      });
      return;
    }
    
    // 네이티브 플랫폼에서 권한 상태 확인
    final locationStatus = await Permission.location.status;
    final notificationStatus = await Permission.notification.status;
    final calendarStatus = await Permission.calendar.status;
    
    setState(() {
      _isLocationGranted = locationStatus.isGranted;
      _isNotificationGranted = notificationStatus.isGranted;
      _isCalendarGranted = calendarStatus.isGranted;
    });
  }
  
  /// 위치 권한 요청
  Future<void> _requestLocationPermission() async {
    if (kIsWeb) {
      _showWebPermissionMessage('위치');
      return;
    }
    
    final status = await Permission.location.request();
    setState(() {
      _isLocationGranted = status.isGranted;
    });
  }
  
  /// 알림 권한 요청
  Future<void> _requestNotificationPermission() async {
    if (kIsWeb) {
      _showWebPermissionMessage('알림');
      return;
    }
    
    final status = await Permission.notification.request();
    setState(() {
      _isNotificationGranted = status.isGranted;
    });
  }
  
  /// 캘린더 권한 요청
  Future<void> _requestCalendarPermission() async {
    if (kIsWeb) {
      _showWebPermissionMessage('캘린더');
      return;
    }
    
    final status = await Permission.calendar.request();
    setState(() {
      _isCalendarGranted = status.isGranted;
    });
  }
  
  /// 모든 권한 한 번에 요청
  Future<void> _requestAllPermissions() async {
    if (kIsWeb) {
      _showWebPermissionMessage('모든');
      return;
    }
    
    await _requestLocationPermission();
    await _requestNotificationPermission();
    await _requestCalendarPermission();
  }
  
  /// 웹에서 권한 요청 시 스낵바 표시
  void _showWebPermissionMessage(String permissionType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('웹 환경에서는 $permissionType 권한 요청이 지원되지 않습니다.'),
        duration: const Duration(seconds: 3),
        backgroundColor: AppColors.warning,
      ),
    );
  }
  
  /// 다음 화면으로 이동
  void _navigateToNextScreen() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('권한 안내'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 헤더 텍스트
              const Text(
                '앱 사용을 위한 권한이 필요합니다',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // 설명 텍스트
              const Text(
                '앱의 모든 기능을 이용하기 위해서는 다음 권한들이 필요합니다. 권한을 허용하지 않으면 일부 기능이 제한될 수 있습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // 권한 항목들
              Expanded(
                child: ListView(
                  children: [
                    // 위치 권한
                    PermissionItem(
                      title: '위치 권한',
                      description: '현재 위치의 날씨 정보를 제공하고 주변 장소를 검색하기 위해 필요합니다.',
                      icon: Icons.location_on,
                      isGranted: _isLocationGranted,
                      onRequestPressed: _requestLocationPermission,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 알림 권한
                    PermissionItem(
                      title: '알림 권한',
                      description: '날씨 알림 및 일정 알림을 제공하기 위해 필요합니다.',
                      icon: Icons.notifications,
                      isGranted: _isNotificationGranted,
                      onRequestPressed: _requestNotificationPermission,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 캘린더 권한
                    PermissionItem(
                      title: '캘린더 권한',
                      description: '일정을 캘린더에 추가하고 관리하기 위해 필요합니다.',
                      icon: Icons.calendar_today,
                      isGranted: _isCalendarGranted,
                      onRequestPressed: _requestCalendarPermission,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 모든 권한 요청 버튼
              ElevatedButton(
                onPressed: _requestAllPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '모든 권한 요청',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // 다음 단계로 이동 버튼
              TextButton(
                onPressed: _navigateToNextScreen,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  '다음 단계로 이동',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 