import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';
import '../utils/exceptions.dart';

/// OpenWeatherMap API를 사용하여 날씨 정보를 가져오는 서비스
class WeatherService {
  final String apiKey;
  final http.Client client;
  
  // API 기본 URL
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // 캐시 키
  static const String currentWeatherCacheKey = 'current_weather_cache';
  static const String hourlyForecastCacheKey = 'hourly_forecast_cache';
  static const String dailyForecastCacheKey = 'daily_forecast_cache';
  static const String airQualityCacheKey = 'air_quality_cache';
  
  // 캐시 만료 시간 (분)
  static const int cacheExpirationMinutes = 30;
  
  WeatherService({
    required this.apiKey,
    http.Client? client,
  }) : client = client ?? http.Client();
  
  /// 현재 날씨 정보 가져오기
  /// [lat] 위도, [lon] 경도
  Future<WeatherData> getCurrentWeather(double lat, double lon) async {
    try {
      // 캐시된 데이터 확인
      final cachedData = await _getCachedData(
        currentWeatherCacheKey, 
        {'lat': lat, 'lon': lon}
      );
      
      if (cachedData != null) {
        return WeatherData.fromJson(cachedData);
      }
      
      // API 호출 URL 생성
      final url = Uri.parse(
        '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=kr'
      );
      
      // API 호출 및 응답 처리
      final response = await _makeRequest(url);
      
      // JSON 파싱 및 모델 변환
      final data = jsonDecode(response.body);
      final weatherData = WeatherData.fromJson(data);
      
      // 데이터 캐싱
      await _cacheData(
        currentWeatherCacheKey, 
        {'lat': lat, 'lon': lon}, 
        data
      );
      
      return weatherData;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 시간별 날씨 예보 가져오기
  /// [lat] 위도, [lon] 경도
  Future<List<HourlyForecast>> getHourlyForecast(double lat, double lon) async {
    try {
      // 캐시된 데이터 확인
      final cachedData = await _getCachedData(
        hourlyForecastCacheKey, 
        {'lat': lat, 'lon': lon}
      );
      
      if (cachedData != null) {
        final List<dynamic> hourlyList = cachedData['list'] ?? [];
        return hourlyList.map((item) => HourlyForecast.fromJson(item)).toList();
      }
      
      // API 호출 URL 생성
      final url = Uri.parse(
        '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=kr&cnt=24'
      );
      
      // API 호출 및 응답 처리
      final response = await _makeRequest(url);
      
      // JSON 파싱 및 모델 변환
      final data = jsonDecode(response.body);
      final List<dynamic> hourlyList = data['list'] ?? [];
      final forecasts = hourlyList.map((item) => HourlyForecast.fromJson(item)).toList();
      
      // 데이터 캐싱
      await _cacheData(
        hourlyForecastCacheKey, 
        {'lat': lat, 'lon': lon}, 
        data
      );
      
      return forecasts;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 일별 날씨 예보 가져오기 (5일)
  /// [lat] 위도, [lon] 경도
  Future<List<DailyForecast>> getWeeklyForecast(double lat, double lon) async {
    try {
      // 캐시된 데이터 확인
      final cachedData = await _getCachedData(
        dailyForecastCacheKey, 
        {'lat': lat, 'lon': lon}
      );
      
      if (cachedData != null) {
        final List<dynamic> dailyList = cachedData['daily'] ?? [];
        return dailyList.map((item) => DailyForecast.fromJson(item)).toList();
      }
      
      // API 호출 URL 생성 (onecall API 사용)
      final url = Uri.parse(
        '$baseUrl/onecall?lat=$lat&lon=$lon&exclude=minutely,current,alerts&appid=$apiKey&units=metric&lang=kr'
      );
      
      // API 호출 및 응답 처리
      final response = await _makeRequest(url);
      
      // JSON 파싱 및 모델 변환
      final data = jsonDecode(response.body);
      final List<dynamic> dailyList = data['daily'] ?? [];
      final forecasts = dailyList.map((item) => DailyForecast.fromJson(item)).toList();
      
      // 데이터 캐싱
      await _cacheData(
        dailyForecastCacheKey, 
        {'lat': lat, 'lon': lon}, 
        data
      );
      
      return forecasts;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 대기질 정보 가져오기
  /// [lat] 위도, [lon] 경도
  Future<AirQuality> getAirQuality(double lat, double lon) async {
    try {
      // 캐시된 데이터 확인
      final cachedData = await _getCachedData(
        airQualityCacheKey, 
        {'lat': lat, 'lon': lon}
      );
      
      if (cachedData != null) {
        return AirQuality.fromJson(cachedData);
      }
      
      // API 호출 URL 생성
      final url = Uri.parse(
        '$baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$apiKey'
      );
      
      // API 호출 및 응답 처리
      final response = await _makeRequest(url);
      
      // JSON 파싱 및 모델 변환
      final data = jsonDecode(response.body);
      final airQuality = AirQuality.fromJson(data);
      
      // 데이터 캐싱
      await _cacheData(
        airQualityCacheKey, 
        {'lat': lat, 'lon': lon}, 
        data
      );
      
      return airQuality;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 특정 시간의 예보 날씨 가져오기 (약속 날짜/시간)
  /// [latitude] 위도, [longitude] 경도, [forecastTime] 예보 시간
  Future<WeatherData?> getForecastWeatherByCoordinates({
    required double latitude,
    required double longitude,
    required DateTime forecastTime,
  }) async {
    try {
      // 현재 시간부터 5일(120시간) 이내인지 확인
      final now = DateTime.now();
      final difference = forecastTime.difference(now);
      
      // 과거 시간이거나 5일 이상 미래인 경우 처리할 수 없음
      if (difference.isNegative || difference.inHours > 120) {
        if (kDebugMode) {
          print('예보 가능 범위를 벗어남: ${difference.inHours}시간');
        }
        return null;
      }
      
      // 시간별 예보 가져오기
      final hourlyForecasts = await getHourlyForecast(latitude, longitude);
      
      // 예보 시간과 가장 가까운 시간 찾기
      HourlyForecast? closestForecast;
      int? minDifference;
      
      for (final forecast in hourlyForecasts) {
        final diff = (forecast.dt.difference(forecastTime)).inMinutes.abs();
        
        if (minDifference == null || diff < minDifference) {
          minDifference = diff;
          closestForecast = forecast;
        }
      }
      
      if (closestForecast != null) {
        // HourlyForecast를 WeatherData로 변환
        return WeatherData(
          id: closestForecast.weather,
          temp: closestForecast.temp,
          feelsLike: closestForecast.feelsLike,
          tempMin: closestForecast.temp - 1, // 추정값
          tempMax: closestForecast.temp + 1, // 추정값
          pressure: closestForecast.pressure,
          humidity: closestForecast.humidity,
          windSpeed: closestForecast.windSpeed,
          windDeg: closestForecast.windDeg,
          clouds: closestForecast.clouds,
          visibility: closestForecast.visibility,
          description: closestForecast.description,
          main: closestForecast.main,
          icon: closestForecast.icon,
          dt: closestForecast.dt,
          cityName: "예보 위치",
          coord: Coord(lat: latitude, lon: longitude),
          sys: Sys(
            country: "KR", 
            sunrise: DateTime.fromMillisecondsSinceEpoch(0),
            sunset: DateTime.fromMillisecondsSinceEpoch(0)
          ),
        );
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('예보 날씨 정보 가져오기 실패: $e');
      }
      return null;
    }
  }
  
  /// HTTP 요청 실행 (재시도 로직 포함)
  Future<http.Response> _makeRequest(Uri url, {int retries = 3}) async {
    int attempt = 0;
    
    while (attempt < retries) {
      try {
        final response = await client.get(url).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException(),
        );
        
        if (response.statusCode == 200) {
          return response;
        } else {
          throw ApiException(
            statusCode: response.statusCode,
            message: 'API 요청 실패: ${response.reasonPhrase}',
          );
        }
      } catch (e) {
        attempt++;
        
        if (attempt >= retries) {
          rethrow;
        }
        
        // 대기 후 재시도
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    
    // 이 부분은 도달하지 않지만 컴파일러를 위해 포함
    throw ApiException(
      statusCode: 500,
      message: '최대 재시도 횟수 초과',
    );
  }
  
  /// 캐시에서 데이터 가져오기
  Future<Map<String, dynamic>?> _getCachedData(
    String key, 
    Map<String, dynamic> params
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _generateCacheKey(key, params);
      final jsonData = prefs.getString(cacheKey);
      
      if (jsonData == null) {
        return null;
      }
      
      final cachedData = jsonDecode(jsonData);
      final cachedTime = DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp'] ?? 0);
      final currentTime = DateTime.now();
      
      // 캐시 만료 확인
      if (currentTime.difference(cachedTime).inMinutes > cacheExpirationMinutes) {
        // 만료된 캐시 삭제
        await prefs.remove(cacheKey);
        return null;
      }
      
      return cachedData['data'];
    } catch (e) {
      return null;
    }
  }
  
  /// 데이터 캐싱
  Future<void> _cacheData(
    String key, 
    Map<String, dynamic> params, 
    dynamic data
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _generateCacheKey(key, params);
      
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      };
      
      await prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      // 캐싱 실패 - 무시하고 계속 진행
      print('데이터 캐싱 실패: $e');
    }
  }
  
  /// 캐시 키 생성
  String _generateCacheKey(String baseKey, Map<String, dynamic> params) {
    final paramsString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('_');
    
    return '${baseKey}_$paramsString';
  }
  
  /// 오류 처리
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else if (error is TimeoutException) {
      return ApiException(
        statusCode: 408,
        message: '요청 시간이 초과되었습니다. 네트워크 연결을 확인하세요.',
      );
    } else if (error is http.ClientException) {
      return ApiException(
        statusCode: 400,
        message: '네트워크 요청 오류: ${error.message}',
      );
    } else {
      return ApiException(
        statusCode: 500,
        message: '알 수 없는 오류가 발생했습니다: $error',
      );
    }
  }
  
  /// 모든 캐시 삭제
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final keys = [
        currentWeatherCacheKey,
        hourlyForecastCacheKey,
        dailyForecastCacheKey,
        airQualityCacheKey,
      ];
      
      for (final key in keys) {
        final cacheKeys = prefs.getKeys().where((k) => k.startsWith(key));
        for (final cacheKey in cacheKeys) {
          await prefs.remove(cacheKey);
        }
      }
    } catch (e) {
      print('캐시 삭제 실패: $e');
    }
  }
}

 