import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:device_calendar/device_calendar.dart';
import '../models/calendar_event_model.dart';
import '../services/calendar_service.dart';
import '../services/weather_service.dart';
import '../services/notification_service.dart';

/// 캘린더 Provider - 캘린더 이벤트 상태 관리
class CalendarProvider extends ChangeNotifier {
  final CalendarService _calendarService;
  final WeatherService _weatherService;
  final NotificationService _notificationService;
  
  // 상태
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  // 캘린더 목록
  List<Calendar> _calendars = [];
  
  // 이벤트 목록
  List<CalendarEvent> _events = [];
  
  // 오늘 이벤트
  List<CalendarEvent> _todayEvents = [];
  
  // 향후 이벤트
  List<CalendarEvent> _upcomingEvents = [];
  
  // 게터
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  List<Calendar> get calendars => _calendars;
  List<CalendarEvent> get events => _events;
  List<CalendarEvent> get todayEvents => _todayEvents;
  List<CalendarEvent> get upcomingEvents => _upcomingEvents;
  
  CalendarProvider({
    required CalendarService calendarService,
    required WeatherService weatherService,
    required NotificationService notificationService,
  }) : 
    _calendarService = calendarService,
    _weatherService = weatherService,
    _notificationService = notificationService {
    _initialize();
  }
  
  /// Provider 초기화
  Future<void> _initialize() async {
    await _calendarService.loadSelectedCalendarIds();
    await _notificationService.initialize();
    await loadCalendars();
  }
  
  /// 캘린더 권한 요청
  Future<bool> requestCalendarPermissions() async {
    return _calendarService.requestCalendarPermissions();
  }
  
  /// 캘린더 목록 로드
  Future<void> loadCalendars() async {
    _setLoading(true);
    
    try {
      _calendars = await _calendarService.getCalendars(forceRefresh: true);
      _hasError = false;
      _errorMessage = '';
    } catch (e) {
      _hasError = true;
      _errorMessage = '캘린더 목록을 불러오는 중 오류가 발생했습니다: $e';
      if (kDebugMode) {
        print(_errorMessage);
      }
    } finally {
      _setLoading(false);
    }
  }
  
  /// 캘린더 선택 상태 변경
  Future<void> toggleCalendarSelection(String calendarId, bool selected) async {
    await _calendarService.toggleCalendarSelection(calendarId, selected);
    notifyListeners();
    
    // 이벤트 다시 로드
    await loadAllEvents();
  }
  
  /// 캘린더가 선택되어 있는지 확인
  bool isCalendarSelected(String calendarId) {
    return _calendarService.isCalendarSelected(calendarId);
  }
  
  /// 모든 이벤트 로드 (오늘 + 향후 15일)
  Future<void> loadAllEvents() async {
    _setLoading(true);
    
    try {
      // 오늘 이벤트 로드
      await loadTodayEvents();
      
      // 향후 15일 이벤트 로드
      await loadUpcomingEvents(15);
      
      _hasError = false;
      _errorMessage = '';
    } catch (e) {
      _hasError = true;
      _errorMessage = '이벤트를 불러오는 중 오류가 발생했습니다: $e';
      if (kDebugMode) {
        print(_errorMessage);
      }
    } finally {
      _setLoading(false);
    }
  }
  
  /// 오늘 이벤트 로드
  Future<void> loadTodayEvents() async {
    _setLoading(true);
    
    try {
      _todayEvents = await _calendarService.getTodayEvents();
      
      // 이벤트 위치 정보 추출 및 날씨 정보 가져오기
      await _processEventsWithWeather(_todayEvents);
      
      _hasError = false;
      _errorMessage = '';
    } catch (e) {
      _hasError = true;
      _errorMessage = '오늘 이벤트를 불러오는 중 오류가 발생했습니다: $e';
      if (kDebugMode) {
        print(_errorMessage);
      }
    } finally {
      _setLoading(false);
    }
  }
  
  /// 향후 N일간의 이벤트 로드
  Future<void> loadUpcomingEvents(int days) async {
    _setLoading(true);
    
    try {
      _upcomingEvents = await _calendarService.getUpcomingEvents(days);
      
      // 이벤트 위치 정보 추출 및 날씨 정보 가져오기
      await _processEventsWithWeather(_upcomingEvents);
      
      _hasError = false;
      _errorMessage = '';
    } catch (e) {
      _hasError = true;
      _errorMessage = '향후 이벤트를 불러오는 중 오류가 발생했습니다: $e';
      if (kDebugMode) {
        print(_errorMessage);
      }
    } finally {
      _setLoading(false);
    }
  }
  
  /// 지정 기간의 이벤트 로드
  Future<List<CalendarEvent>> loadEventsForPeriod(
    DateTime start, 
    DateTime end
  ) async {
    _setLoading(true);
    
    try {
      final events = await _calendarService.getEvents(start, end);
      
      // 이벤트 위치 정보 추출 및 날씨 정보 가져오기
      await _processEventsWithWeather(events);
      
      _hasError = false;
      _errorMessage = '';
      return events;
    } catch (e) {
      _hasError = true;
      _errorMessage = '이벤트를 불러오는 중 오류가 발생했습니다: $e';
      if (kDebugMode) {
        print(_errorMessage);
      }
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  /// 이벤트 위치 정보 추출 및 날씨 정보 가져오기
  Future<void> _processEventsWithWeather(List<CalendarEvent> events) async {
    final now = DateTime.now();
    final fifthDay = DateTime.now().add(const Duration(days: 5));
    
    for (int i = 0; i < events.length; i++) {
      final event = events[i];
      
      // 이벤트 시간이 현재 이전이면 날씨 정보를 가져오지 않음
      if (event.startTime.isBefore(now)) continue;
      
      // 이벤트 시간이 5일 이후면 날씨 정보를 가져오지 않음 (API 제한)
      if (event.startTime.isAfter(fifthDay)) continue;
      
      try {
        // 위치 정보 추출
        final locationData = await event.parseLocationCoordinates();
        
        if (locationData != null) {
          // 날씨 정보 가져오기
          final weatherData = await _weatherService.getForecastWeatherByCoordinates(
            latitude: locationData.latitude,
            longitude: locationData.longitude,
            forecastTime: event.startTime,
          );
          
          if (weatherData != null) {
            // 이벤트에 위치 및 날씨 정보 업데이트
            events[i] = event.copyWithLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
              address: locationData.address,
            ).copyWithWeather(
              weatherIcon: weatherData.icon,
              temperature: weatherData.temp,
            );
            
            // 알림 설정
            if (event.hasNotification) {
              await _notificationService.scheduleEventWeatherNotification(events[i]);
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('이벤트 처리 중 오류 발생: ${event.title} - $e');
        }
      }
    }
  }
  
  /// 이벤트 알림 설정 변경
  Future<void> updateEventNotificationSettings(
    String eventId, 
    bool hasNotification, 
    int notificationLeadTime
  ) async {
    // 오늘 이벤트에서 검색
    int index = _todayEvents.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      _todayEvents[index] = _todayEvents[index].copyWithNotificationSettings(
        hasNotification: hasNotification,
        notificationLeadTime: notificationLeadTime,
      );
      
      if (hasNotification) {
        await _notificationService.scheduleEventWeatherNotification(_todayEvents[index]);
      } else {
        await _notificationService.cancelEventNotifications(eventId);
      }
    }
    
    // 향후 이벤트에서 검색
    index = _upcomingEvents.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      _upcomingEvents[index] = _upcomingEvents[index].copyWithNotificationSettings(
        hasNotification: hasNotification,
        notificationLeadTime: notificationLeadTime,
      );
      
      if (hasNotification) {
        await _notificationService.scheduleEventWeatherNotification(_upcomingEvents[index]);
      } else {
        await _notificationService.cancelEventNotifications(eventId);
      }
    }
    
    notifyListeners();
  }
  
  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 