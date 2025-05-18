/// 앱 전반에서 사용하는 상수 모음
class AppConstants {
  // API 키 (참고: 실제 프로젝트에서는 환경 변수나 보안 저장소에서 가져오는 것이 좋습니다)
  static const String weatherApiKey = 'e968fc3ab3818889f9d2e36a22ee88a4'; // 실제 API 키로 교체해야 함
  
  // 날씨 관련 상수
  static const int weatherCacheExpirationMinutes = 30; // 날씨 데이터 캐시 만료 시간 (분)
  static const double defaultLatitude = 37.5665; // 서울 위도 (기본값)
  static const double defaultLongitude = 126.9780; // 서울 경도 (기본값)
  
  // 온도 범위 (추천 의상 선택에 사용)
  static const Map<String, Map<String, double>> temperatureRanges = {
    'veryHot': {'min': 30.0, 'max': 50.0},
    'hot': {'min': 25.0, 'max': 30.0},
    'warm': {'min': 20.0, 'max': 25.0},
    'mild': {'min': 15.0, 'max': 20.0},
    'cool': {'min': 10.0, 'max': 15.0},
    'chilly': {'min': 5.0, 'max': 10.0},
    'cold': {'min': 0.0, 'max': 5.0},
    'veryCold': {'min': -20.0, 'max': 0.0},
  };
  
  // 날씨 상태별 아이콘 매핑
  static const Map<String, String> weatherIcons = {
    'sunny': 'assets/icons/weather/sunny.png',
    'partly_cloudy': 'assets/icons/weather/partly_cloudy.png',
    'cloudy': 'assets/icons/weather/cloudy.png',
    'rain': 'assets/icons/weather/rain.png',
    'snow': 'assets/icons/weather/snow.png',
    'storm': 'assets/icons/weather/storm.png',
    'fog': 'assets/icons/weather/fog.png',
    'wind': 'assets/icons/weather/wind.png',
    'night': 'assets/icons/weather/night.png',
  };
  
  // 위치 관련 상수
  static const int locationTimeoutSeconds = 10;
  static const double locationAccuracy = 100.0; // 미터 단위
  
  // 사용자 관련 상수
  static const List<String> genderOptions = ['남성', '여성', '기타'];
  static const List<String> ageGroupOptions = ['10대', '20대', '30대', '40대', '50대', '60대 이상'];
  
  // 날씨 새로고침 간격 (분)
  static const int weatherRefreshIntervalMinutes = 30;
}

/// 날씨 API 관련 상수
class WeatherApiConstants {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String geoUrl = 'https://api.openweathermap.org/geo/1.0';
  
  // 엔드포인트
  static const String currentWeather = '/weather';
  static const String forecast = '/forecast';
  static const String oneCall = '/onecall';
  static const String airPollution = '/air_pollution';
  static const String geocoding = '/direct';
  
  // API 파라미터
  static const String units = 'metric'; // 섭씨 온도
  static const String language = 'kr'; // 한국어
  
  // 캐시 키
  static const String weatherCacheKey = 'weather_cache';
  static const String forecastCacheKey = 'forecast_cache';
  static const String airQualityCacheKey = 'air_quality_cache';
  
  // 에러 메시지
  static const String networkError = '네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인해주세요.';
  static const String apiError = '날씨 데이터를 가져오는 중 오류가 발생했습니다.';
  static const String locationError = '위치 정보를 가져올 수 없습니다.';
} 