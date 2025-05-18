import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calendar_event_model.dart';

/// 캘린더 서비스 - 기기 캘린더 API와 연동
class CalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin;
  
  // 캐시된 캘린더 목록
  List<Calendar>? _calendars;
  
  // 접근이 허용된 캘린더 ID 목록 (사용자가 선택한 캘린더)
  Set<String> _selectedCalendarIds = {};
  
  static const String _prefsKey = 'selected_calendar_ids';
  
  CalendarService() : _deviceCalendarPlugin = DeviceCalendarPlugin();
  
  /// 캘린더 접근 권한 확인 및 요청
  Future<bool> requestCalendarPermissions() async {
    final permissionsStatus = await _deviceCalendarPlugin.hasPermissions();
    
    if (permissionsStatus.isSuccess && 
        permissionsStatus.data == true) {
      return true;
    }
    
    // 권한 요청
    final requestResult = await _deviceCalendarPlugin.requestPermissions();
    return requestResult.isSuccess && 
           requestResult.data == true;
  }
  
  /// 사용 가능한 캘린더 목록 조회
  Future<List<Calendar>> getCalendars({bool forceRefresh = false}) async {
    if (_calendars == null || forceRefresh) {
      final permissionGranted = await requestCalendarPermissions();
      
      if (!permissionGranted) {
        return [];
      }
      
      final result = await _deviceCalendarPlugin.retrieveCalendars();
      if (result.isSuccess) {
        _calendars = result.data ?? [];
      } else {
        if (kDebugMode) {
          print('캘린더 목록 조회 오류: ${result.errors}');
        }
        return [];
      }
    }
    
    return _calendars ?? [];
  }
  
  /// 선택된 캘린더 ID 목록 로드
  Future<void> loadSelectedCalendarIds() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedIds = prefs.getStringList(_prefsKey) ?? [];
    _selectedCalendarIds = Set<String>.from(selectedIds);
  }
  
  /// 선택된 캘린더 ID 목록 저장
  Future<void> saveSelectedCalendarIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _selectedCalendarIds.toList());
  }
  
  /// 캘린더 선택 상태 변경
  Future<void> toggleCalendarSelection(String calendarId, bool selected) async {
    if (selected) {
      _selectedCalendarIds.add(calendarId);
    } else {
      _selectedCalendarIds.remove(calendarId);
    }
    
    await saveSelectedCalendarIds();
  }
  
  /// 캘린더가 선택되어 있는지 확인
  bool isCalendarSelected(String calendarId) {
    return _selectedCalendarIds.contains(calendarId);
  }
  
  /// 선택된 캘린더 목록 반환
  Future<List<Calendar>> getSelectedCalendars() async {
    final allCalendars = await getCalendars();
    return allCalendars.where(
      (cal) => _selectedCalendarIds.contains(cal.id)
    ).toList();
  }
  
  /// 특정 기간 내의 이벤트 조회
  Future<List<CalendarEvent>> getEvents(DateTime start, DateTime end) async {
    final events = <CalendarEvent>[];
    final selectedCalendars = await getSelectedCalendars();
    
    for (final calendar in selectedCalendars) {
      if (calendar.id == null) continue;
      
      final result = await _deviceCalendarPlugin.retrieveEvents(
        calendar.id,
        RetrieveEventsParams(
          startDate: start,
          endDate: end,
        ),
      );
      
      if (result.isSuccess && result.data != null) {
        for (final event in result.data!) {
          if (event.eventId != null) {
            events.add(CalendarEvent.fromDeviceEvent(
              event, 
              calendar.name ?? '알 수 없는 캘린더'
            ));
          }
        }
      }
    }
    
    // 시작 시간 순으로 정렬
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    return events;
  }
  
  /// 오늘 이벤트 조회
  Future<List<CalendarEvent>> getTodayEvents() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    
    return getEvents(start, end);
  }
  
  /// 이번 주 이벤트 조회
  Future<List<CalendarEvent>> getWeekEvents() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 7));
    
    return getEvents(start, end);
  }
  
  /// 향후 N일간의 이벤트 조회
  Future<List<CalendarEvent>> getUpcomingEvents(int days) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(Duration(days: days));
    
    return getEvents(start, end);
  }
  
  /// 특정 캘린더의 이벤트 조회
  Future<List<CalendarEvent>> getCalendarEvents(
    String calendarId, 
    DateTime start, 
    DateTime end
  ) async {
    final events = <CalendarEvent>[];
    final calendars = await getCalendars();
    final calendar = calendars.firstWhere(
      (cal) => cal.id == calendarId,
      orElse: () => Calendar(id: calendarId, name: '알 수 없는 캘린더'),
    );
    
    final result = await _deviceCalendarPlugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(
        startDate: start,
        endDate: end,
      ),
    );
    
    if (result.isSuccess && result.data != null) {
      for (final event in result.data!) {
        if (event.eventId != null) {
          events.add(CalendarEvent.fromDeviceEvent(
            event, 
            calendar.name ?? '알 수 없는 캘린더'
          ));
        }
      }
    }
    
    // 시작 시간 순으로 정렬
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    return events;
  }
} 