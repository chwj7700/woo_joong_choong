import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/app_preference_service.dart';
import '../../utils/colors.dart';
import '../../routes.dart';

/// 앱 설정 화면
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppPreferenceService _prefService = AppPreferenceService();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    await _prefService.loadPreferences();
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSettingsList(),
    );
  }
  
  Widget _buildSettingsList() {
    return ChangeNotifierProvider.value(
      value: _prefService,
      child: Consumer<AppPreferenceService>(
        builder: (context, prefService, child) {
          return ListView(
            children: [
              // 사용자 프로필 섹션
              _buildSection(
                title: '프로필',
                icon: Icons.person_outline,
                children: [
                  _buildMenuItem(
                    icon: Icons.person,
                    title: '프로필 정보 관리',
                    subtitle: '성별, 나이, 온도 민감도 등',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.userProfileSettings);
                    },
                  ),
                ],
              ),
              
              // 알림 설정 섹션
              _buildSection(
                title: '알림 설정',
                icon: Icons.notifications_none,
                children: [
                  _buildSwitchItem(
                    icon: Icons.notifications,
                    title: '알림 사용',
                    subtitle: '날씨 알림 전체 켜기/끄기',
                    value: prefService.notificationEnabled,
                    onChanged: (value) {
                      prefService.updateNotificationEnabled(value);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.tune,
                    title: '알림 세부 설정',
                    subtitle: '날씨 변화, 미세먼지, 강수, 약속 등',
                    enabled: prefService.notificationEnabled,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.notificationSettings);
                    },
                  ),
                ],
              ),
              
              // 단위 및 위치 설정 섹션
              _buildSection(
                title: '단위 및 위치',
                icon: Icons.settings,
                children: [
                  ListTile(
                    leading: const Icon(Icons.thermostat),
                    title: const Text('온도 단위'),
                    subtitle: Text(prefService.usesFahrenheit() ? '화씨 (°F)' : '섭씨 (°C)'),
                    trailing: Switch(
                      value: prefService.useCelsius,
                      onChanged: (value) {
                        prefService.setTemperatureUnit(value);
                      },
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: '위치 설정',
                    subtitle: '현재 위치 사용, 기본 위치 설정',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.locationSettings);
                    },
                  ),
                ],
              ),
              
              // 앱 정보 섹션
              _buildSection(
                title: '정보',
                icon: Icons.info_outline,
                children: [
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: '도움말',
                    subtitle: 'FAQ, 사용 가이드',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.helpScreen);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.rate_review_outlined,
                    title: '피드백 내역',
                    subtitle: '내가 작성한 피드백 내역',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.feedbackHistory);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info,
                    title: '앱 정보',
                    subtitle: '버전, 개발자 정보, 라이선스',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.appInfo);
                    },
                  ),
                ],
              ),
              
              // 데이터 관리 섹션
              _buildSection(
                title: '데이터 관리',
                icon: Icons.storage,
                children: [
                  _buildMenuItem(
                    icon: Icons.refresh,
                    title: '설정 초기화',
                    subtitle: '모든 설정을 기본값으로 되돌리기',
                    onTap: () {
                      _showResetConfirmDialog();
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// 섹션 위젯 - 제목과 아이콘을 가진 설정 그룹
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
  
  /// 메뉴 아이템 위젯 - 터치 가능한 설정 항목
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        enabled: enabled,
        leading: Icon(icon, color: Colors.grey[800]),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: enabled ? onTap : null,
      ),
    );
  }
  
  /// 스위치 아이템 위젯 - ON/OFF 토글 설정 항목
  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[800]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
  
  /// 설정 초기화 확인 다이얼로그
  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('설정 초기화'),
          content: const Text('모든 설정이 기본값으로 되돌아갑니다. 계속하시겠습니까?'),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('초기화', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _prefService.resetAllSettings();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('모든 설정이 초기화되었습니다.')),
                );
              },
            ),
          ],
        );
      },
    );
  }
} 