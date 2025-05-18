import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/calendar_event_model.dart';
import '../../models/weather_model.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/weather_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/weather_summary_widget.dart';
import '../../widgets/hourly_forecast_widget.dart';
import '../../widgets/daily_forecast_widget.dart';
import '../../widgets/outfit_recommendation_widget.dart';
import '../../services/location_service.dart';

/// 캘린더 이벤트 상세 화면
class CalendarEventDetailScreen extends StatefulWidget {
  final CalendarEvent event;
  
  const CalendarEventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<CalendarEventDetailScreen> createState() => _CalendarEventDetailScreenState();
}

class _CalendarEventDetailScreenState extends State<CalendarEventDetailScreen> {
  bool _isLoadingWeather = false;
  bool _hasNotification = false;
  int _notificationLeadTime = 1; // 기본값: 1시간 전
  
  @override
  void initState() {
    super.initState();
    _hasNotification = widget.event.hasNotification;
    _notificationLeadTime = widget.event.notificationLeadTime;
    
    // 위치 좌표가 있으면 해당 위치의 날씨 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeatherIfNeeded();
    });
  }
  
  /// 날씨 정보 로드 (필요한 경우)
  Future<void> _loadWeatherIfNeeded() async {
    if (widget.event.latitude == null || 
        widget.event.longitude == null ||
        widget.event.startTime.isBefore(DateTime.now())) {
      return;
    }
    
    setState(() {
      _isLoadingWeather = true;
    });
    
    try {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      // 메서드 이름 변경: 실제 WeatherProvider 클래스의 메서드 이름과 일치시킴
      await weatherProvider.fetchWeatherForLocation(
        LocationData(
          latitude: widget.event.latitude!,
          longitude: widget.event.longitude!,
          name: widget.event.location ?? widget.event.title,
          address: widget.event.address,
        )
      );
    } catch (e) {
      // 날씨 정보 로드 오류 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('날씨 정보를 불러오는 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    }
  }
  
  /// 알림 설정 변경
  Future<void> _updateNotificationSettings() async {
    final calendarProvider = Provider.of<CalendarProvider>(
      context, 
      listen: false,
    );
    
    await calendarProvider.updateEventNotificationSettings(
      widget.event.id,
      _hasNotification,
      _notificationLeadTime,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _hasNotification 
                ? '${_notificationLeadTime}시간 전 알림이 설정되었습니다'
                : '알림이 해제되었습니다',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 날짜 및 시간 형식
    final dateFormat = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR');
    final timeFormat = DateFormat('a h:mm', 'ko_KR');
    
    final dateString = dateFormat.format(widget.event.startTime);
    final startTimeString = timeFormat.format(widget.event.startTime);
    final endTimeString = timeFormat.format(widget.event.endTime);
    
    // 이벤트가 진행 중인지 여부
    final isOngoing = widget.event.isOngoing();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 상세'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이벤트 제목 및 시간
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isOngoing 
                    ? BorderSide(color: AppColors.primary, width: 2) 
                    : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isOngoing)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, 
                          vertical: 4,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '진행 중',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 날짜 및 시간
                    Row(
                      children: [
                        const Icon(
                          Icons.event,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateString,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$startTimeString - $endTimeString',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    
                    // 위치 정보
                    if (widget.event.location != null && 
                        widget.event.location!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.event.address ?? widget.event.location!,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                    // 설명 정보
                    if (widget.event.description != null && 
                        widget.event.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          widget.event.description!,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 알림 설정
            const Text(
              '날씨 알림 설정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('약속 날씨 알림 받기'),
                      subtitle: Text(
                        _hasNotification
                            ? '약속 ${_notificationLeadTime}시간 전에 알림을 받습니다'
                            : '알림을 받지 않습니다',
                      ),
                      value: _hasNotification,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _hasNotification = value;
                        });
                      },
                    ),
                    
                    if (_hasNotification)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '알림 시간',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Slider(
                              value: _notificationLeadTime.toDouble(),
                              min: 1,
                              max: 24,
                              divisions: 23,
                              label: '${_notificationLeadTime}시간 전',
                              activeColor: AppColors.primary,
                              onChanged: (value) {
                                setState(() {
                                  _notificationLeadTime = value.round();
                                });
                              },
                            ),
                            Text(
                              '약속 ${_notificationLeadTime}시간 전에 알림',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateNotificationSettings,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('설정 저장'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 날씨 정보
            if (widget.event.latitude != null && widget.event.longitude != null)
              _buildWeatherSection(),
          ],
        ),
      ),
    );
  }
  
  /// 날씨 정보 섹션
  Widget _buildWeatherSection() {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        // 로딩 중이면 로딩 표시
        if (_isLoadingWeather) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // 위치 좌표가 없거나 과거 이벤트면 표시하지 않음
        if (widget.event.latitude == null || 
            widget.event.longitude == null ||
            widget.event.startTime.isBefore(DateTime.now())) {
          return const SizedBox.shrink();
        }
        
        // 날씨 정보가 없으면 정보 없음 표시
        if (weatherProvider.currentWeather == null) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  '날씨 정보를 불러올 수 없습니다',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        }
        
        // 현재 날씨 정보
        final weather = weatherProvider.currentWeather!;
        final hourlyForecast = weatherProvider.hourlyForecast;
        final dailyForecast = weatherProvider.dailyForecast;
        
        // 체감 온도 계산을 위한 현재 날씨 정보
        final userPrefs = {
          'tempSensitivity': 'normal', // 온도 민감도 (기본값: 보통)
          'gender': 'female', // 성별 (기본값: 여성)
          'age': 30, // 나이 (기본값: 30세)
        };
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '약속 장소 날씨',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // 현재 날씨 요약
            WeatherSummaryWidget(
              weather: weather,
              locationName: widget.event.address ?? widget.event.location ?? '약속 장소',
            ),
            const SizedBox(height: 16),
            
            // 시간별 날씨 예보
            if (hourlyForecast != null && hourlyForecast.isNotEmpty)
              HourlyForecastWidget(
                hourlyForecast: hourlyForecast,
              ),
            const SizedBox(height: 16),
            
            // 일별 날씨 예보
            if (dailyForecast != null && dailyForecast.isNotEmpty)
              DailyForecastWidget(
                dailyForecast: dailyForecast,
              ),
            const SizedBox(height: 24),
            
            // 의상 추천
            const Text(
              '약속에 맞는 의상 추천',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            OutfitRecommendationWidget(
              temperature: weather.temp,
              weatherCondition: weather.description,
              userPreferences: userPrefs,
            ),
          ],
        );
      },
    );
  }
} 