import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../models/user_model.dart';
import '../models/outfit_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/personalized_weather_calculator.dart';
import '../services/outfit_recommendation_service.dart';
import '../utils/constants.dart';
import '../utils/exceptions.dart';

enum WeatherStatus {
  initial, // 초기 상태
  loading, // 로딩 중
  loaded, // 데이터 로드 완료
  error, // 오류 발생
}

/// 날씨 데이터 상태 관리 클래스
class WeatherProvider with ChangeNotifier {
  // 서비스 객체
  final WeatherService _weatherService;
  final LocationService _locationService;
  final PersonalizedWeatherCalculator _weatherCalculator = PersonalizedWeatherCalculator();
  final OutfitRecommendationService _outfitService = OutfitRecommendationService();
  
  // 날씨 데이터
  WeatherData? _currentWeather;
  List<HourlyForecast>? _hourlyForecast;
  List<DailyForecast>? _dailyForecast;
  AirQuality? _airQuality;
  
  // 개인화된 날씨 데이터
  double? _personalizedFeelTemp;
  String? _tempCategory;
  List<OutfitSet>? _recommendedOutfits;
  String? _activityRecommendation;
  
  // 상태 및 오류 메시지
  WeatherStatus _status = WeatherStatus.initial;
  String _errorMessage = '';
  
  // 현재 선택된 위치
  LocationData? _selectedLocation;
  
  // 새로고침 타이머
  Timer? _refreshTimer;
  
  // 생성자
  WeatherProvider({
    required String apiKey,
    required bool autoRefresh,
  }) : _weatherService = WeatherService(apiKey: apiKey),
       _locationService = LocationService(apiKey: apiKey) {
    // 자동 새로고침 활성화
    if (autoRefresh) {
      _startAutoRefresh();
    }
  }
  
  // Getters
  WeatherData? get currentWeather => _currentWeather;
  List<HourlyForecast>? get hourlyForecast => _hourlyForecast;
  List<DailyForecast>? get dailyForecast => _dailyForecast;
  AirQuality? get airQuality => _airQuality;
  WeatherStatus get status => _status;
  String get errorMessage => _errorMessage;
  LocationData? get selectedLocation => _selectedLocation;
  bool get isLoading => _status == WeatherStatus.loading;
  bool get hasError => _status == WeatherStatus.error;
  bool get hasData => _status == WeatherStatus.loaded;
  
  // 개인화된 날씨 데이터 Getters
  double? get personalizedFeelTemp => _personalizedFeelTemp;
  String? get tempCategory => _tempCategory;
  List<OutfitSet>? get recommendedOutfits => _recommendedOutfits;
  String? get activityRecommendation => _activityRecommendation;
  
  /// 현재 위치 기반 날씨 정보 가져오기
  Future<void> fetchWeatherForCurrentLocation() async {
    try {
      _setLoading();
      
      // 현재 위치 정보 가져오기
      final location = await _locationService.getCurrentLocation();
      _selectedLocation = location;
      
      // 위치 기반 날씨 정보 가져오기
      await _fetchWeatherData(location.latitude, location.longitude);
      
      _setLoaded();
    } catch (e) {
      _setError('현재 위치의 날씨 정보를 가져오는 중 오류가 발생했습니다: $e');
      
      // 오류 발생 시 캐시된 데이터나 서울 기본 데이터 사용
      await _useFallbackData();
    }
  }
  
  /// 선택한 위치 기반 날씨 정보 가져오기
  Future<void> fetchWeatherForLocation(LocationData location) async {
    try {
      _setLoading();
      
      _selectedLocation = location;
      
      // 위치 기반 날씨 정보 가져오기
      await _fetchWeatherData(location.latitude, location.longitude);
      
      _setLoaded();
    } catch (e) {
      _setError('선택한 위치의 날씨 정보를 가져오는 중 오류가 발생했습니다: $e');
      
      // 오류 발생 시 캐시된 데이터나 서울 기본 데이터 사용
      await _useFallbackData();
    }
  }
  
  /// 위치 검색
  Future<List<LocationData>> searchLocation(String query) async {
    try {
      return await _locationService.searchLocation(query);
    } catch (e) {
      _setError('위치 검색 중 오류가 발생했습니다: $e');
      return [];
    }
  }
  
  /// 최근 위치에서 날씨 가져오기
  Future<void> fetchWeatherForRecentLocation(LocationData location) async {
    try {
      _setLoading();
      
      _selectedLocation = location;
      
      // 위치 기반 날씨 정보 가져오기
      await _fetchWeatherData(location.latitude, location.longitude);
      
      _setLoaded();
    } catch (e) {
      _setError('선택한 위치의 날씨 정보를 가져오는 중 오류가 발생했습니다: $e');
      
      // 오류 발생 시 캐시된 데이터나 서울 기본 데이터 사용
      await _useFallbackData();
    }
  }
  
  /// 날씨 데이터 다시 로드
  Future<void> refreshWeather() async {
    if (_selectedLocation == null) {
      await fetchWeatherForCurrentLocation();
    } else {
      await fetchWeatherForLocation(_selectedLocation!);
    }
  }
  
  /// 모든 날씨 데이터 캐시 삭제
  Future<void> clearCache() async {
    await _weatherService.clearCache();
    _setError('날씨 데이터 캐시가 삭제되었습니다.');
  }
  
  /// 제공자 소멸 시 타이머 정리
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  // Private methods
  
  /// 날씨 데이터 가져오기
  Future<void> _fetchWeatherData(double lat, double lon) async {
    try {
      // 날씨 정보 병렬 요청
      final results = await Future.wait([
        _weatherService.getCurrentWeather(lat, lon),
        _weatherService.getHourlyForecast(lat, lon),
        _weatherService.getWeeklyForecast(lat, lon),
        _weatherService.getAirQuality(lat, lon),
      ]).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException();
        },
      );
      
      _currentWeather = results[0] as WeatherData;
      _hourlyForecast = results[1] as List<HourlyForecast>;
      _dailyForecast = results[2] as List<DailyForecast>;
      _airQuality = results[3] as AirQuality;
    } on TimeoutException {
      throw Exception('날씨 데이터를 가져오는 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.');
    } catch (e) {
      print('날씨 데이터 로딩 오류: $e');
      throw Exception('날씨 데이터를 가져오는 중 오류가 발생했습니다: $e');
    }
  }
  
  /// 자동 새로고침 시작
  void _startAutoRefresh() {
    // 기존 타이머 취소
    _refreshTimer?.cancel();
    
    // 30분마다 날씨 정보 갱신
    _refreshTimer = Timer.periodic(
      Duration(minutes: AppConstants.weatherRefreshIntervalMinutes), 
      (_) => refreshWeather()
    );
  }
  
  /// 상태를 로딩 중으로 설정
  void _setLoading() {
    _status = WeatherStatus.loading;
    _errorMessage = '';
    notifyListeners();
  }
  
  /// 상태를 로드 완료로 설정
  void _setLoaded() {
    _status = WeatherStatus.loaded;
    _errorMessage = '';
    notifyListeners();
  }
  
  /// 오류 상태 설정
  void _setError(String message) {
    _status = WeatherStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
  
  /// 대체 데이터 사용 (오류 발생 시)
  Future<void> _useFallbackData() async {
    try {
      // 먼저 캐시된 위치 데이터가 있는지 확인
      if (_selectedLocation == null) {
        _selectedLocation = _locationService.getDefaultLocation();
      }
      
      // API 키 인증 실패 시 더미 데이터 사용
      if (_errorMessage.contains('Unauthorized')) {
        _useDummyData();
        return;
      }
      
      // 기본 위치 (서울) 날씨 정보 가져오기
      await _fetchWeatherData(
        _selectedLocation!.latitude, 
        _selectedLocation!.longitude
      );
      
      // 데이터를 가져왔지만 오류 상태 유지
      notifyListeners();
    } catch (e) {
      // 대체 데이터도 실패하면 더미 데이터 사용
      _useDummyData();
    }
  }
  
  /// 테스트용 더미 데이터 생성
  void _useDummyData() {
    _selectedLocation = _locationService.getDefaultLocation();
    final now = DateTime.now();
    
    // 현재 날씨 더미 데이터
    _currentWeather = WeatherData(
      id: 800,
      main: 'Clear',
      description: '맑음',
      icon: '01d',
      temp: 22.5,
      feelsLike: 23.0,
      tempMin: 20.0,
      tempMax: 25.0,
      pressure: 1012,
      humidity: 60,
      windSpeed: 3.2,
      windDeg: 120,
      clouds: 5,
      dt: now,
      cityName: '서울특별시',
      visibility: 10000,
      coord: Coord(lat: 37.5665, lon: 126.9780),
      sys: Sys(
        country: 'KR',
        sunrise: now.subtract(const Duration(hours: 6)),
        sunset: now.add(const Duration(hours: 6)),
      ),
    );
    
    // 시간별 예보 더미 데이터
    _hourlyForecast = List.generate(24, (index) {
      final hour = now.add(Duration(hours: index));
      final isPartlyCloudy = index % 6 == 0;
      
      return HourlyForecast(
        dt: hour,
        weather: isPartlyCloudy ? 801 : 800,
        main: isPartlyCloudy ? 'Clouds' : 'Clear',
        description: isPartlyCloudy ? '구름 조금' : '맑음',
        icon: isPartlyCloudy ? '02d' : '01d',
        temp: 22.0 + (index % 5 - 2),
        feelsLike: 23.0 + (index % 5 - 2),
        pressure: 1012,
        humidity: 60 + (index % 20 - 10),
        windSpeed: 3.0 + (index % 3),
        windDeg: 120,
        clouds: isPartlyCloudy ? 25 : 5,
        pop: 0.1 * (index % 5),
        visibility: 10000,
      );
    });
    
    // 일별 예보 더미 데이터
    _dailyForecast = List.generate(7, (index) {
      final day = now.add(Duration(days: index));
      final weatherCode = index % 3 == 0 ? 803 : (index % 7 == 0 ? 500 : 800);
      final weatherMain = index % 3 == 0 ? 'Clouds' : (index % 7 == 0 ? 'Rain' : 'Clear');
      final weatherDescription = index % 3 == 0 ? '구름 많음' : (index % 7 == 0 ? '가벼운 비' : '맑음');
      final weatherIcon = index % 3 == 0 ? '03d' : (index % 7 == 0 ? '10d' : '01d');
      
      return DailyForecast(
        dt: day,
        weather: weatherCode,
        main: weatherMain,
        description: weatherDescription,
        icon: weatherIcon,
        sunrise: day.add(const Duration(hours: 6)),
        sunset: day.add(const Duration(hours: 18)),
        temp: Temperature(
          day: 22.0 + index % 5,
          min: 18.0 + index % 3,
          max: 26.0 + index % 5,
          night: 17.0 + index % 4,
          eve: 23.0 + index % 3,
          morn: 19.0 + index % 3,
        ),
        feelsLike: Temperature(
          day: 23.0 + index % 5,
          night: 18.0 + index % 4,
          eve: 24.0 + index % 3,
          morn: 20.0 + index % 3,
          min: 17.0,
          max: 25.0,
        ),
        dewPoint: 15.0 + (index % 3),
        uvi: 5.0 + (index % 5),
        pressure: 1012,
        humidity: 60 + (index % 20),
        windSpeed: 3.0 + (index % 4),
        windDeg: 120 + (index * 10) % 360,
        clouds: index % 3 == 0 ? 75 : 10,
        pop: 0.1 * (index % 5),
        rain: index % 7 == 0 ? 2.5 : 0.0,
      );
    });
    
    // 대기질 더미 데이터
    _airQuality = AirQuality(
      dt: now,
      aqi: 2,
      co: 350.47,
      no: 0.16,
      no2: 1.25,
      o3: 91.13,
      so2: 0.75,
      pm2_5: 10.0,
      pm10: 22.0,
      nh3: 2.02,
    );
    
    // 상태 변경
    _status = WeatherStatus.loaded;
    _errorMessage = '';
    
    notifyListeners();
  }
  
  /// 사용자 정보에 기반한 개인화된 날씨 데이터 계산
  void calculatePersonalizedWeather(UserModel user) {
    if (_currentWeather == null) return;
    
    // 개인화된 체감 온도 계산
    _personalizedFeelTemp = _weatherCalculator.calculatePersonalFeelTemp(_currentWeather!, user);
    
    // 온도 범주 설정
    _tempCategory = _weatherCalculator.getTempCategory(_personalizedFeelTemp!);
    
    // 코디 추천
    _recommendedOutfits = _outfitService.getRecommendedOutfits(_currentWeather!, user);
    
    // 활동 추천
    final List<WeatherSpecialCondition> conditions = [];
    if (_currentWeather!.rain1h != null && _currentWeather!.rain1h! > 0) {
      conditions.add(WeatherSpecialCondition.rain);
    }
    if (_currentWeather!.snow1h != null && _currentWeather!.snow1h! > 0) {
      conditions.add(WeatherSpecialCondition.snow);
    }
    _activityRecommendation = _outfitService.getActivityRecommendation(_personalizedFeelTemp!, conditions);
    
    notifyListeners();
  }
  
  /// 날씨 데이터 변경 시 개인화된 날씨 정보도 업데이트
  void updatePersonalizedWeather(UserModel user) {
    if (_status == WeatherStatus.loaded) {
      calculatePersonalizedWeather(user);
    }
  }
  
  /// 코디 추천에 대한 피드백 저장
  Future<void> saveOutfitFeedback(OutfitFeedback feedback) async {
    await _outfitService.saveOutfitFeedback(feedback);
    
    // 피드백 후 추천 다시 계산하는 로직 필요 시 추가
  }
}