import 'dart:math' as math;
import '../models/weather_model.dart';
import '../models/user_model.dart';

/// 사용자의 개인 특성을 고려한 체감 온도 계산 알고리즘
class PersonalizedWeatherCalculator {
  /// 개인화된 체감 온도 계산
  /// [weather] 날씨 데이터
  /// [user] 사용자 프로필
  /// 사용자 특성에 따라 보정된 체감 온도를 반환
  double calculatePersonalFeelTemp(WeatherData weather, UserModel user) {
    double baseTemp = weather.temp;
    
    // 사용자 추위/더위 민감도에 따른 보정
    // preferredTemperature: -3(추위에 민감) ~ 3(더위에 민감)
    double temperatureSensitivityFactor = 0.0;
    double userTempPreference = user.preferredTemperature ?? 0.0;
    
    if (baseTemp < 20) {
      // 추운 환경에서는 추위 민감도에 따라 체감 온도가 더 낮게 느껴짐
      temperatureSensitivityFactor = userTempPreference < 0 
          ? userTempPreference * -0.5  // 추위에 민감할수록 더 춥게 느낌 (최대 -1.5도)
          : userTempPreference * 0.3;  // 더위에 민감할수록 덜 춥게 느낌 (최대 +0.9도)
    } else {
      // 더운 환경에서는 더위 민감도에 따라 체감 온도가 더 높게 느껴짐
      temperatureSensitivityFactor = userTempPreference > 0 
          ? userTempPreference * 0.7   // 더위에 민감할수록 더 덥게 느낌 (최대 +2.1도)
          : userTempPreference * 0.2;  // 추위에 민감할수록 덜 덥게 느낌 (최대 -0.6도)
    }
    
    // 습도 요소 반영
    double humidityFactor = calculateHumidityImpact(weather.humidity, user.sweatRate ?? 2.5);
    
    // 풍속 요소 반영
    double windFactor = calculateWindImpact(weather.windSpeed);
    
    // 최종 체감 온도 계산
    double personalFeelTemp = baseTemp;
    if (baseTemp < 20) {
      personalFeelTemp += temperatureSensitivityFactor - windFactor;
    } else {
      personalFeelTemp += temperatureSensitivityFactor + humidityFactor;
    }
    
    return personalFeelTemp;
  }
  
  /// 습도가 체감 온도에 미치는 영향 계산
  /// [humidity] 습도(%)
  /// [sweatLevel] 사용자의 땀 분비 정도 (0-5)
  double calculateHumidityImpact(int humidity, double sweatLevel) {
    // 습도 영향은 60% 이상일 때 유의미하게 증가
    if (humidity < 60) return 0.0;
    
    // 습도가 높을수록, 땀 분비량이 많은 사용자일수록 체감 온도가 더 높아짐
    double humidityFactor = (humidity - 60) / 40.0; // 0.0 ~ 1.0
    double sweatFactor = sweatLevel / 5.0; // 0.0 ~ 1.0
    
    // 최대 3도까지 체감 온도 상승 가능
    return humidityFactor * sweatFactor * 3.0;
  }
  
  /// 풍속이 체감 온도에 미치는 영향 계산
  /// [windSpeed] 풍속(m/s)
  double calculateWindImpact(double windSpeed) {
    // 체감 온도 저하 효과 (풍속 1m/s당 약 0.5도, 최대 3도)
    return math.min(windSpeed * 0.5, 3.0);
  }
  
  /// 체감 온도 범위에 따른 카테고리 분류
  /// [temp] 체감 온도(섭씨)
  String getTempCategory(double temp) {
    if (temp <= 0) return '매우 추움';
    if (temp <= 5) return '추움';
    if (temp <= 10) return '쌀쌀함';
    if (temp <= 15) return '선선함';
    if (temp <= 20) return '적당함';
    if (temp <= 25) return '따뜻함';
    if (temp <= 30) return '더움';
    return '매우 더움';
  }
  
  /// 의류 추천을 위한 온도 범주 반환
  /// [temp] 체감 온도(섭씨)
  int getOutfitTempRange(double temp) {
    if (temp <= 4) return 0;       // 매우 추움 (~4도)
    if (temp <= 8) return 1;       // 추움 (5~8도)
    if (temp <= 11) return 2;      // 쌀쌀함 (9~11도)
    if (temp <= 16) return 3;      // 선선함 (12~16도)
    if (temp <= 19) return 4;      // 조금 선선함 (17~19도)
    if (temp <= 22) return 5;      // 적당함 (20~22도)
    if (temp <= 27) return 6;      // 조금 더움 (23~27도)
    if (temp <= 31) return 7;      // 더움 (28~31도)
    return 8;                      // 매우 더움 (32도~)
  }
} 