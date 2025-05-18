import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';

/// 앱 설정 관리 서비스
class AppPreferenceService with ChangeNotifier {
  // 싱글톤 패턴 구현
  static final AppPreferenceService _instance = AppPreferenceService._internal();
  
  factory AppPreferenceService() {
    return _instance;
  }
  
  AppPreferenceService._internal();
  
  // SharedPreferences 키 정의
  static const String _notificationEnabledKey = 'notification_enabled';
  static const String _notificationsConfigKey = 'notifications_config';
  static const String _temperatureUnitKey = 'temperature_unit';
  static const String _useCelsiusKey = 'use_celsius';
  static const String _useCurrentLocationKey = 'use_current_location';
  static const String _defaultLocationKey = 'default_location';
  static const String _defaultCityKey = 'default_city';
  static const String _recentLocationsKey = 'recent_locations';
  static const String _maxRecentLocationsKey = 'max_recent_locations';
  static const String _recentSearchTermsKey = 'recent_search_terms';
  static const String _notificationTimeRangeKey = 'notification_time_range';
  static const String _dustAlertThresholdKey = 'dust_alert_threshold';
  static const String _pressureUnitKey = 'pressure_unit';
  static const String _windSpeedUnitKey = 'wind_speed_unit';
  static const String _precipitationUnitKey = 'precipitation_unit';
  
  // 기본 값
  static const int _defaultMaxRecentLocations = 5;
  
  // 설정 값
  bool _notificationEnabled = true;
  Map<String, bool> _notificationsConfig = {
    'weather': true,
    'air': true,
    'rain': true,
    'uv': true,
    'calendar': true,
  };
  bool _useCelsius = true;
  bool _useCurrentLocation = true;
  Map<String, dynamic>? _defaultLocation;
  String? _defaultCity;
  Map<String, int> _notificationTimeRange = {
    'start': 8, // 오전 8시
    'end': 22, // 오후 10시
  };
  
  int _dustAlertThreshold = 81; // 미세먼지 경보 기준 (나쁨 이상)
  String _pressureUnit = 'hPa'; // 기압 단위 (hPa, inHg)
  String _windSpeedUnit = 'm/s'; // 풍속 단위 (m/s, km/h, mph, knots)
  String _precipitationUnit = 'mm'; // 강수량 단위 (mm, in)
  
  List<LocationData> _recentLocations = [];
  List<String> _recentSearchTerms = [];
  int _maxRecentLocations = _defaultMaxRecentLocations;
  
  // 게터
  bool get notificationEnabled => _notificationEnabled;
  Map<String, bool> get notificationsConfig => _notificationsConfig;
  bool get useCelsius => _useCelsius;
  bool get useCurrentLocation => _useCurrentLocation;
  Map<String, dynamic>? get defaultLocation => _defaultLocation;
  Map<String, int> get notificationTimeRange => _notificationTimeRange;
  int get dustAlertThreshold => _dustAlertThreshold;
  String get pressureUnit => _pressureUnit;
  String get windSpeedUnit => _windSpeedUnit;
  String get precipitationUnit => _precipitationUnit;
  String? get defaultCity => _defaultCity;
  List<LocationData> get recentLocations => _recentLocations;
  int get maxRecentLocations => _maxRecentLocations;
  List<String> get recentSearchTerms => _recentSearchTerms;
  
  // 화씨 온도 사용 여부 확인 (유틸리티 함수)
  bool usesFahrenheit() => !_useCelsius;
  
  /// 설정 값 로드
  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 알림 설정 로드
      _notificationEnabled = prefs.getBool(_notificationEnabledKey) ?? _notificationEnabled;
      
      final notificationsConfigJson = prefs.getString(_notificationsConfigKey);
      if (notificationsConfigJson != null) {
        final Map<String, dynamic> configMap = jsonDecode(notificationsConfigJson);
        _notificationsConfig = Map<String, bool>.from(configMap);
      }
      
      // 온도 단위 로드
      _useCelsius = prefs.getBool(_useCelsiusKey) ?? _useCelsius;
      
      // 위치 설정 로드
      _useCurrentLocation = prefs.getBool(_useCurrentLocationKey) ?? _useCurrentLocation;
      _defaultCity = prefs.getString(_defaultCityKey);
      
      final defaultLocationJson = prefs.getString(_defaultLocationKey);
      if (defaultLocationJson != null) {
        _defaultLocation = jsonDecode(defaultLocationJson);
      }
      
      // 알림 시간 범위 로드
      final timeRangeJson = prefs.getString(_notificationTimeRangeKey);
      if (timeRangeJson != null) {
        final Map<String, dynamic> timeRangeMap = jsonDecode(timeRangeJson);
        _notificationTimeRange = Map<String, int>.from(timeRangeMap);
      }
      
      // 기타 설정 로드
      _dustAlertThreshold = prefs.getInt(_dustAlertThresholdKey) ?? _dustAlertThreshold;
      
      _pressureUnit = prefs.getString(_pressureUnitKey) ?? _pressureUnit;
      _windSpeedUnit = prefs.getString(_windSpeedUnitKey) ?? _windSpeedUnit;
      _precipitationUnit = prefs.getString(_precipitationUnitKey) ?? _precipitationUnit;
      
      // 최근 위치 로드
      final recentLocationsJson = prefs.getStringList(_recentLocationsKey);
      if (recentLocationsJson != null) {
        _recentLocations = recentLocationsJson
            .map((json) => LocationData.fromJson(jsonDecode(json)))
            .toList();
      }
      
      // 최대 최근 위치 개수 로드
      _maxRecentLocations = prefs.getInt(_maxRecentLocationsKey) ?? _defaultMaxRecentLocations;
      
      // 최근 검색어 로드
      _recentSearchTerms = prefs.getStringList(_recentSearchTermsKey) ?? [];
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('설정 로드 중 오류 발생: $e');
      }
    }
  }
  
  /// 알림 설정 업데이트
  Future<void> updateNotificationEnabled(bool enabled) async {
    _notificationEnabled = enabled;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
    
    notifyListeners();
  }
  
  /// 개별 알림 설정 업데이트
  Future<void> updateNotificationConfig(String key, bool value) async {
    _notificationsConfig[key] = value;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationsConfigKey, jsonEncode(_notificationsConfig));
    
    notifyListeners();
  }
  
  /// 온도 단위 설정 (섭씨/화씨)
  Future<void> setTemperatureUnit(bool useCelsius) async {
    _useCelsius = useCelsius;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useCelsiusKey, useCelsius);
    
    notifyListeners();
  }
  
  /// 현재 위치 사용 설정
  Future<void> setUseCurrentLocation(bool useCurrentLocation) async {
    _useCurrentLocation = useCurrentLocation;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useCurrentLocationKey, useCurrentLocation);
    
    notifyListeners();
  }
  
  /// 기본 위치 설정
  Future<void> setDefaultLocation(Map<String, dynamic> location) async {
    _defaultLocation = location;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultLocationKey, jsonEncode(location));
    
    notifyListeners();
  }
  
  /// 알림 시간 범위 설정
  Future<void> setNotificationTimeRange(int startHour, int endHour) async {
    _notificationTimeRange = {
      'start': startHour,
      'end': endHour,
    };
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationTimeRangeKey, jsonEncode(_notificationTimeRange));
    
    notifyListeners();
  }
  
  /// 미세먼지 경보 기준 설정
  Future<void> setDustAlertThreshold(int threshold) async {
    _dustAlertThreshold = threshold;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dustAlertThresholdKey, threshold);
    
    notifyListeners();
  }
  
  /// 기압 단위 설정
  Future<void> setPressureUnit(String unit) async {
    if (unit != 'hPa' && unit != 'inHg') {
      throw ArgumentError('지원하지 않는 기압 단위입니다: $unit');
    }
    
    _pressureUnit = unit;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pressureUnitKey, unit);
    
    notifyListeners();
  }
  
  /// 풍속 단위 설정
  Future<void> setWindSpeedUnit(String unit) async {
    if (!['m/s', 'km/h', 'mph', 'knots'].contains(unit)) {
      throw ArgumentError('지원하지 않는 풍속 단위입니다: $unit');
    }
    
    _windSpeedUnit = unit;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_windSpeedUnitKey, unit);
    
    notifyListeners();
  }
  
  /// 강수량 단위 설정
  Future<void> setPrecipitationUnit(String unit) async {
    if (unit != 'mm' && unit != 'in') {
      throw ArgumentError('지원하지 않는 강수량 단위입니다: $unit');
    }
    
    _precipitationUnit = unit;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_precipitationUnitKey, unit);
    
    notifyListeners();
  }
  
  /// 기본 도시 설정
  Future<void> setDefaultCity(String? city) async {
    _defaultCity = city;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultCityKey, city ?? '');
    
    notifyListeners();
  }
  
  /// 모든 설정 초기화
  Future<void> resetAllSettings() async {
    _notificationEnabled = true;
    _notificationsConfig = {
      'weather': true,
      'air': true,
      'rain': true,
      'uv': true,
      'calendar': true,
    };
    _useCelsius = true;
    _useCurrentLocation = true;
    _defaultLocation = null;
    _notificationTimeRange = {
      'start': 8,
      'end': 22,
    };
    _dustAlertThreshold = 81;
    _pressureUnit = 'hPa';
    _windSpeedUnit = 'm/s';
    _precipitationUnit = 'mm';
    _defaultCity = null;
    _recentLocations = [];
    _recentSearchTerms = [];
    _maxRecentLocations = _defaultMaxRecentLocations;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationEnabledKey);
    await prefs.remove(_notificationsConfigKey);
    await prefs.remove(_temperatureUnitKey);
    await prefs.remove(_useCelsiusKey);
    await prefs.remove(_useCurrentLocationKey);
    await prefs.remove(_defaultLocationKey);
    await prefs.remove(_notificationTimeRangeKey);
    await prefs.remove(_dustAlertThresholdKey);
    await prefs.remove(_pressureUnitKey);
    await prefs.remove(_windSpeedUnitKey);
    await prefs.remove(_precipitationUnitKey);
    await prefs.remove(_defaultCityKey);
    await prefs.remove(_recentLocationsKey);
    await prefs.remove(_maxRecentLocationsKey);
    await prefs.remove(_recentSearchTermsKey);
    
    notifyListeners();
  }
  
  /// 설정 저장 (내부용)
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 알림 설정 저장
      await prefs.setBool(_notificationEnabledKey, _notificationEnabled);
      await prefs.setString(_notificationsConfigKey, jsonEncode(_notificationsConfig));
      
      // 온도 단위 저장
      await prefs.setBool(_useCelsiusKey, _useCelsius);
      
      // 위치 설정 저장
      await prefs.setBool(_useCurrentLocationKey, _useCurrentLocation);
      if (_defaultCity != null) {
        await prefs.setString(_defaultCityKey, _defaultCity!);
      } else {
        await prefs.remove(_defaultCityKey);
      }
      
      // 시간 범위 및 기타 설정 저장
      await prefs.setString(_notificationTimeRangeKey, jsonEncode(_notificationTimeRange));
      await prefs.setInt(_dustAlertThresholdKey, _dustAlertThreshold);
      await prefs.setString(_pressureUnitKey, _pressureUnit);
      await prefs.setString(_windSpeedUnitKey, _windSpeedUnit);
      await prefs.setString(_precipitationUnitKey, _precipitationUnit);
      
      // 최근 위치 저장
      final recentLocationsJson = _recentLocations
          .map((location) => jsonEncode(location.toJson()))
          .toList();
      await prefs.setStringList(_recentLocationsKey, recentLocationsJson);
      
      // 최대 최근 위치 개수 저장
      await prefs.setInt(_maxRecentLocationsKey, _maxRecentLocations);
      
      // 최근 검색어 저장
      await prefs.setStringList(_recentSearchTermsKey, _recentSearchTerms);
    } catch (e) {
      if (kDebugMode) {
        print('설정 저장 중 오류 발생: $e');
      }
    }
  }
  
  /// 최근 위치 추가
  Future<void> addRecentLocation(LocationData location) async {
    // 이미 있는 위치인지 확인
    final existingIndex = _recentLocations.indexWhere((loc) => 
        loc.latitude == location.latitude && 
        loc.longitude == location.longitude);
    
    // 이미 있는 위치면 제거
    if (existingIndex != -1) {
      _recentLocations.removeAt(existingIndex);
    }
    
    // 최상단에 추가
    _recentLocations.insert(0, location);
    
    // 최대 개수 유지
    if (_recentLocations.length > _maxRecentLocations) {
      _recentLocations = _recentLocations.sublist(0, _maxRecentLocations);
    }
    
    await _savePreferences();
    notifyListeners();
  }
  
  /// 최근 위치 제거
  Future<void> removeRecentLocation(int index) async {
    if (index >= 0 && index < _recentLocations.length) {
      _recentLocations.removeAt(index);
      await _savePreferences();
      notifyListeners();
    }
  }
  
  /// 모든 최근 위치 제거
  Future<void> clearRecentLocations() async {
    _recentLocations = [];
    await _savePreferences();
    notifyListeners();
  }
  
  /// 최근 검색어 추가
  Future<void> addRecentSearchTerm(String term) async {
    if (term.trim().isEmpty) return;
    
    // 중복 제거
    _recentSearchTerms.remove(term);
    
    // 최상단에 추가
    _recentSearchTerms.insert(0, term);
    
    // 최대 10개 유지
    if (_recentSearchTerms.length > 10) {
      _recentSearchTerms = _recentSearchTerms.sublist(0, 10);
    }
    
    await _savePreferences();
    notifyListeners();
  }
  
  /// 최근 검색어 제거
  Future<void> removeRecentSearchTerm(String term) async {
    _recentSearchTerms.remove(term);
    await _savePreferences();
    notifyListeners();
  }
  
  /// 모든 최근 검색어 제거
  Future<void> clearRecentSearchTerms() async {
    _recentSearchTerms = [];
    await _savePreferences();
    notifyListeners();
  }
} 