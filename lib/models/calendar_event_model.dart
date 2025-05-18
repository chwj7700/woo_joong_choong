import 'package:flutter/foundation.dart';
import 'package:device_calendar/device_calendar.dart';
import '../services/location_service.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

/// 캘린더 이벤트 모델
class CalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final String? description;
  final String calendarId;
  final String calendarName;
  
  // 날씨 관련 데이터
  String? weatherIcon;
  double? temperature;
  
  // 위치 데이터 (좌표)
  double? latitude;
  double? longitude;
  String? address;
  
  // 알림 설정
  bool hasNotification;
  int notificationLeadTime; // 알림을 약속 시간 몇 시간 전에 보낼지 (기본값: 1시간)

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.calendarId,
    required this.calendarName,
    this.location,
    this.description,
    this.weatherIcon,
    this.temperature,
    this.latitude,
    this.longitude,
    this.address,
    this.hasNotification = true,
    this.notificationLeadTime = 1,
  });
  
  /// Device Calendar 이벤트에서 CalendarEvent 객체 생성
  factory CalendarEvent.fromDeviceEvent(Event event, String calendarName) {
    return CalendarEvent(
      id: event.eventId ?? '',
      title: event.title ?? '제목 없음',
      startTime: event.start ?? DateTime.now(),
      endTime: event.end ?? DateTime.now().add(const Duration(hours: 1)),
      calendarId: event.calendarId ?? '',
      calendarName: calendarName,
      location: event.location,
      description: event.description,
    );
  }
  
  /// JSON 데이터에서 CalendarEvent 객체 생성
  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      calendarId: json['calendarId'] as String,
      calendarName: json['calendarName'] as String,
      location: json['location'] as String?,
      description: json['description'] as String?,
      weatherIcon: json['weatherIcon'] as String?,
      temperature: json['temperature'] as double?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      address: json['address'] as String?,
      hasNotification: json['hasNotification'] as bool? ?? true,
      notificationLeadTime: json['notificationLeadTime'] as int? ?? 1,
    );
  }
  
  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'calendarId': calendarId,
      'calendarName': calendarName,
      'location': location,
      'description': description,
      'weatherIcon': weatherIcon,
      'temperature': temperature,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'hasNotification': hasNotification,
      'notificationLeadTime': notificationLeadTime,
    };
  }
  
  /// 위치 좌표 정보 있는지 확인
  bool hasLocation() {
    return latitude != null && longitude != null;
  }
  
  /// 이벤트가 진행 중인지 확인
  bool isOngoing() {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
  
  /// 위치 정보에서 좌표 추출 (지오코딩)
  Future<LocationData?> parseLocationCoordinates() async {
    // 이미 좌표가 있는 경우
    if (hasLocation()) {
      return LocationData(
        latitude: latitude!,
        longitude: longitude!,
        name: location ?? title,
        address: address,
      );
    }
    
    // 위치 정보가 없으면 null 반환
    if (location == null || location!.isEmpty) {
      return null;
    }
    
    try {
      // 지오코딩 서비스로 좌표 얻기 (geocoding 패키지 사용)
      final List<geocoding.Location> locations = await geocoding.locationFromAddress(location!);
      
      if (locations.isNotEmpty) {
        final loc = locations.first;
        
        // 역지오코딩으로 주소 정보 가져오기
        final List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
          loc.latitude, 
          loc.longitude
        );
        
        String addressComponents = '';
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          addressComponents = [
            placemark.thoroughfare,
            placemark.subLocality,
            placemark.locality,
            placemark.administrativeArea,
          ].where((element) => element != null && element.isNotEmpty).join(', ');
        }
        
        return LocationData(
          latitude: loc.latitude,
          longitude: loc.longitude,
          name: location!,
          address: addressComponents,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('지오코딩 오류: $e');
      }
    }
    
    return null;
  }
  
  /// 위치 정보 업데이트된 복사본 생성
  CalendarEvent copyWithLocation({
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return CalendarEvent(
      id: id,
      title: title,
      startTime: startTime,
      endTime: endTime,
      location: location,
      description: description,
      calendarId: calendarId,
      calendarName: calendarName,
      weatherIcon: weatherIcon,
      temperature: temperature,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      hasNotification: hasNotification,
      notificationLeadTime: notificationLeadTime,
    );
  }
  
  /// 날씨 정보 업데이트된 복사본 생성
  CalendarEvent copyWithWeather({
    String? weatherIcon,
    double? temperature,
  }) {
    return CalendarEvent(
      id: id,
      title: title,
      startTime: startTime,
      endTime: endTime,
      location: location,
      description: description,
      calendarId: calendarId,
      calendarName: calendarName,
      weatherIcon: weatherIcon ?? this.weatherIcon,
      temperature: temperature ?? this.temperature,
      latitude: latitude,
      longitude: longitude,
      address: address,
      hasNotification: hasNotification,
      notificationLeadTime: notificationLeadTime,
    );
  }
  
  /// 알림 설정 업데이트된 복사본 생성
  CalendarEvent copyWithNotificationSettings({
    bool? hasNotification,
    int? notificationLeadTime,
  }) {
    return CalendarEvent(
      id: id,
      title: title,
      startTime: startTime,
      endTime: endTime,
      location: location,
      description: description,
      calendarId: calendarId,
      calendarName: calendarName,
      weatherIcon: weatherIcon,
      temperature: temperature,
      latitude: latitude,
      longitude: longitude,
      address: address,
      hasNotification: hasNotification ?? this.hasNotification,
      notificationLeadTime: notificationLeadTime ?? this.notificationLeadTime,
    );
  }
} 