import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_preference_service.dart';
import '../../utils/colors.dart';

/// 알림 설정 화면
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
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
        title: const Text('알림 설정'),
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
          // 알림 시간대
          final int startHour = prefService.notificationTimeRange['start'] ?? 8;
          final int endHour = prefService.notificationTimeRange['end'] ?? 22;
          
          return ListView(
            children: [
              // 알림 유형 섹션
              _buildSection(
                title: '알림 유형',
                children: [
                  _buildSwitchItem(
                    icon: Icons.wb_cloudy,
                    title: '날씨 변화 알림',
                    subtitle: '날씨가 크게 변할 때 알림을 받습니다',
                    enabled: prefService.notificationEnabled,
                    value: prefService.notificationsConfig['weather'] ?? false,
                    onChanged: (value) {
                      prefService.updateNotificationConfig('weather', value);
                    },
                  ),
                  _buildSwitchItem(
                    icon: Icons.air,
                    title: '미세먼지 알림',
                    subtitle: '미세먼지 농도가 기준치를 넘으면 알림을 받습니다',
                    enabled: prefService.notificationEnabled,
                    value: prefService.notificationsConfig['air'] ?? false,
                    onChanged: (value) {
                      prefService.updateNotificationConfig('air', value);
                    },
                  ),
                  _buildSwitchItem(
                    icon: Icons.water_drop,
                    title: '강수 알림',
                    subtitle: '비나 눈이 예상될 때 알림을 받습니다',
                    enabled: prefService.notificationEnabled,
                    value: prefService.notificationsConfig['rain'] ?? false,
                    onChanged: (value) {
                      prefService.updateNotificationConfig('rain', value);
                    },
                  ),
                  _buildSwitchItem(
                    icon: Icons.wb_sunny,
                    title: '자외선 알림',
                    subtitle: '자외선 지수가 높을 때 알림을 받습니다',
                    enabled: prefService.notificationEnabled,
                    value: prefService.notificationsConfig['uv'] ?? false,
                    onChanged: (value) {
                      prefService.updateNotificationConfig('uv', value);
                    },
                  ),
                  _buildSwitchItem(
                    icon: Icons.calendar_month,
                    title: '캘린더 일정 알림',
                    subtitle: '캘린더 일정의 날씨 정보 알림을 받습니다',
                    enabled: prefService.notificationEnabled,
                    value: prefService.notificationsConfig['calendar'] ?? false,
                    onChanged: (value) {
                      prefService.updateNotificationConfig('calendar', value);
                    },
                  ),
                ],
              ),
              
              // 알림 시간대 섹션
              _buildSection(
                title: '알림 시간대',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Text('시작 시간: ', style: TextStyle(fontSize: 16)),
                        const Spacer(),
                        DropdownButton<int>(
                          value: startHour,
                          items: List.generate(24, (index) => index).map((hour) {
                            return DropdownMenuItem<int>(
                              value: hour,
                              child: Text('${hour}시'),
                            );
                          }).toList(),
                          onChanged: prefService.notificationEnabled
                              ? (int? newValue) {
                                  if (newValue != null && newValue <= endHour) {
                                    prefService.setNotificationTimeRange(newValue, endHour);
                                  } else if (newValue != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('시작 시간은 종료 시간보다 작아야 합니다')),
                                    );
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Text('종료 시간: ', style: TextStyle(fontSize: 16)),
                        const Spacer(),
                        DropdownButton<int>(
                          value: endHour,
                          items: List.generate(24, (index) => index).map((hour) {
                            return DropdownMenuItem<int>(
                              value: hour,
                              child: Text('${hour}시'),
                            );
                          }).toList(),
                          onChanged: prefService.notificationEnabled
                              ? (int? newValue) {
                                  if (newValue != null && newValue >= startHour) {
                                    prefService.setNotificationTimeRange(startHour, newValue);
                                  } else if (newValue != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('종료 시간은 시작 시간보다 커야 합니다')),
                                    );
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // 미세먼지 알림 설정 섹션
              _buildSection(
                title: '미세먼지 알림 설정',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '미세먼지 알림 기준: ${prefService.dustAlertThreshold}μg/m³',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getDustLevelDescription(prefService.dustAlertThreshold),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getDustLevelColor(prefService.dustAlertThreshold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Slider(
                          value: prefService.dustAlertThreshold.toDouble(),
                          min: 30,
                          max: 150,
                          divisions: 12,
                          label: '${prefService.dustAlertThreshold}μg/m³',
                          onChanged: prefService.notificationEnabled && prefService.notificationsConfig['air'] == true
                              ? (value) {
                                  prefService.setDustAlertThreshold(value.round());
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// 섹션 위젯
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
  
  /// 스위치 아이템 위젯
  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[800]),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }
  
  /// 미세먼지 수준 설명 텍스트
  String _getDustLevelDescription(int value) {
    if (value <= 30) return '좋음';
    if (value <= 80) return '보통';
    if (value <= 120) return '나쁨';
    return '매우 나쁨';
  }
  
  /// 미세먼지 수준 색상
  Color _getDustLevelColor(int value) {
    if (value <= 30) return Colors.blue;
    if (value <= 80) return Colors.green;
    if (value <= 120) return Colors.orange;
    return Colors.red;
  }
} 