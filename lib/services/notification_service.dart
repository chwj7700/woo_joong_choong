import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/calendar_event_model.dart';

/// 알림 서비스 - 약속 날씨 알림 관리
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;
  
  static const String _prefsKey = 'scheduled_notifications';
  
  // 싱글톤 패턴
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal() 
      : _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  /// 알림 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // timezone 초기화
    tz_data.initializeTimeZones();
    
    // 안드로이드 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 설정
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );
    
    // 초기화 설정
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // 알림 초기화
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    
    // 알림 권한 요청 (iOS)
    try {
      if (kIsWeb) {
        // 웹에서는 iOS 권한 요청을 건너뜁니다.
        if (kDebugMode) {
          print('웹 환경에서는 iOS 알림 권한 요청이 지원되지 않습니다.');
        }
      } else if (!kIsWeb && Platform.isIOS) {
        await _requestIOSPermissions();
      }
    } catch (e) {
      // Platform API가 지원되지 않는 환경(예: 웹)에서 예외 처리
      if (kDebugMode) {
        print('플랫폼 확인 중 오류: $e. 알림 권한 요청을 건너뜁니다.');
      }
    }
    
    _isInitialized = true;
  }
  
  /// iOS 알림 권한 요청
  Future<void> _requestIOSPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
  
  /// 알림 수신 처리 (iOS 10 미만)
  void _onDidReceiveLocalNotification(
    int id, 
    String? title, 
    String? body, 
    String? payload
  ) async {
    // iOS 10 미만에서 사용되는 콜백
    if (kDebugMode) {
      print('알림 수신: $title');
    }
  }
  
  /// 알림 응답 처리
  void _onDidReceiveNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      try {
        // 페이로드 파싱 및 탐색 처리는 나중에 구현
        if (kDebugMode) {
          print('알림 응답 데이터: $payload');
        }
      } catch (e) {
        if (kDebugMode) {
          print('알림 데이터 처리 오류: $e');
        }
      }
    }
  }
  
  /// 캘린더 이벤트에 대한 날씨 알림 예약
  Future<bool> scheduleEventWeatherNotification(
    CalendarEvent event, 
    {bool updateIfExists = true}
  ) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // 이벤트에 위치 정보가 없는 경우
    if (event.latitude == null || event.longitude == null) {
      if (kDebugMode) {
        print('위치 정보가 없는 이벤트: ${event.title}');
      }
      return false;
    }
    
    // 이벤트에 날씨 정보가 없는 경우
    if (event.weatherIcon == null || event.temperature == null) {
      if (kDebugMode) {
        print('날씨 정보가 없는 이벤트: ${event.title}');
      }
      return false;
    }
    
    // 알림을 보낼 시간 계산 (약속 시간 N시간 전)
    final notificationTime = event.startTime
        .subtract(Duration(hours: event.notificationLeadTime));
    
    // 이미 지난 시간이면 알림을 보내지 않음
    if (notificationTime.isBefore(DateTime.now())) {
      if (kDebugMode) {
        print('알림 시간이 이미 지났음: ${event.title}');
      }
      return false;
    }
    
    // 알림 ID 생성 (이벤트 ID 해시)
    final notificationId = event.id.hashCode;
    
    // 기존 알림이 있는지 확인
    final existingNotifications = await getScheduledNotifications();
    final existingNotification = existingNotifications
        .where((n) => n.id == notificationId)
        .toList();
    
    // 기존 알림이 있고 업데이트하지 않을 경우
    if (existingNotification.isNotEmpty && !updateIfExists) {
      return true;
    }
    
    // 기존 알림 취소 (업데이트할 경우)
    if (existingNotification.isNotEmpty) {
      await cancelNotification(notificationId);
    }
    
    // 안드로이드 알림 상세 설정
    final androidDetails = AndroidNotificationDetails(
      'calendar_weather_channel',
      '약속 날씨 알림',
      channelDescription: '약속 일정의 날씨 정보를 알려주는 알림',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );
    
    // iOS 알림 상세 설정
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true, 
      presentBadge: true,
      presentSound: true,
    );
    
    // 알림 상세 설정
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // 날씨 아이콘 이모지 선택
    final weatherEmoji = _getWeatherEmoji(event.weatherIcon!);
    
    // 알림 제목 및 내용
    final title = '${event.title} - 날씨 정보';
    final temperature = event.temperature!.round();
    final body = '$weatherEmoji 약속 장소의 예상 온도는 ${temperature}°C입니다.\n'
        '${event.location ?? ""}${event.address != null ? " (${event.address})" : ""}';
    
    // 알림 페이로드 (알림 클릭 시 처리에 사용)
    final payload = jsonEncode({
      'eventId': event.id,
      'type': 'calendar_weather',
    });
    
    try {
      // 특정 시간에 알림 예약
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        _dateTimeToTZDateTime(notificationTime),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      
      // 예약된 알림 저장
      await _saveScheduledNotification(
        ScheduledNotification(
          id: notificationId,
          eventId: event.id,
          title: title,
          body: body,
          scheduledTime: notificationTime,
        ),
      );
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('알림 예약 오류: $e');
      }
      return false;
    }
  }
  
  /// DateTime을 TZDateTime으로 변환
  tz.TZDateTime _dateTimeToTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(
      dateTime,
      getLocalTimeZone(),
    );
  }
  
  /// 현재 로컬 타임존 가져오기
  tz.Location getLocalTimeZone() {
    return tz.getLocation(DateTime.now().timeZoneName);
  }
  
  /// 날씨 아이콘 코드를 이모지로 변환
  String _getWeatherEmoji(String weatherIcon) {
    // 날씨 아이콘 코드에 따른 이모지 매핑
    switch (weatherIcon.substring(0, 2)) {
      case '01': return '☀️'; // 맑음
      case '02': return '⛅'; // 구름 조금
      case '03': return '☁️'; // 구름 많음
      case '04': return '☁️'; // 흐림
      case '09': return '🌧️'; // 소나기
      case '10': return '🌦️'; // 비
      case '11': return '⛈️'; // 천둥번개
      case '13': return '❄️'; // 눈
      case '50': return '🌫️'; // 안개
      default: return '🌈';
    }
  }
  
  /// 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    await _removeScheduledNotification(id);
  }
  
  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    await _clearScheduledNotifications();
  }
  
  /// 이벤트에 대한 알림 취소
  Future<void> cancelEventNotifications(String eventId) async {
    final notifications = await getScheduledNotifications();
    final eventNotifications = notifications
        .where((n) => n.eventId == eventId)
        .toList();
    
    for (final notification in eventNotifications) {
      await cancelNotification(notification.id);
    }
  }
  
  /// 예약된 알림 목록 조회
  Future<List<ScheduledNotification>> getScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsKey) ?? [];
    
    return jsonList
        .map((json) => ScheduledNotification.fromJson(jsonDecode(json)))
        .toList();
  }
  
  /// 예약된 알림 저장
  Future<void> _saveScheduledNotification(
    ScheduledNotification notification
  ) async {
    final notifications = await getScheduledNotifications();
    
    // 이미 있는 알림 제거
    notifications.removeWhere((n) => n.id == notification.id);
    
    // 새 알림 추가
    notifications.add(notification);
    
    // 저장
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notifications
        .map((n) => jsonEncode(n.toJson()))
        .toList();
    
    await prefs.setStringList(_prefsKey, jsonList);
  }
  
  /// 예약된 알림 제거
  Future<void> _removeScheduledNotification(int id) async {
    final notifications = await getScheduledNotifications();
    
    // 해당 ID의 알림 제거
    notifications.removeWhere((n) => n.id == id);
    
    // 저장
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notifications
        .map((n) => jsonEncode(n.toJson()))
        .toList();
    
    await prefs.setStringList(_prefsKey, jsonList);
  }
  
  /// 모든 예약된 알림 정보 삭제
  Future<void> _clearScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}

/// 예약된 알림 정보 모델
class ScheduledNotification {
  final int id;
  final String eventId;
  final String title;
  final String body;
  final DateTime scheduledTime;
  
  ScheduledNotification({
    required this.id,
    required this.eventId,
    required this.title,
    required this.body,
    required this.scheduledTime,
  });
  
  /// JSON에서 변환
  factory ScheduledNotification.fromJson(Map<String, dynamic> json) {
    return ScheduledNotification(
      id: json['id'] as int,
      eventId: json['eventId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
    );
  }
  
  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.toIso8601String(),
    };
  }
} 