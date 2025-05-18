/// 현재 날씨 데이터 모델
class WeatherData {
  final int id; // 날씨 상태 ID
  final String main; // 메인 날씨 (Clear, Rain, Snow 등)
  final String description; // 날씨 상세 설명
  final String icon; // 날씨 아이콘 코드
  final double temp; // 현재 기온 (섭씨)
  final double feelsLike; // 체감 기온 (섭씨)
  final double tempMin; // 최저 기온 (섭씨)
  final double tempMax; // 최고 기온 (섭씨)
  final int pressure; // 기압 (hPa)
  final int humidity; // 습도 (%)
  final double windSpeed; // 풍속 (m/s)
  final int windDeg; // 풍향 (도)
  final double? windGust; // 돌풍 (m/s)
  final int clouds; // 구름 (%)
  final DateTime dt; // 데이터 시간 (Unix, UTC)
  final String cityName; // 도시 이름
  final int visibility; // 가시거리 (미터)
  final double? rain1h; // 1시간 강수량 (mm)
  final double? snow1h; // 1시간 적설량 (mm)
  final Coord coord; // 좌표
  final Sys sys; // 국가, 일출 일몰 정보

  WeatherData({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    this.windGust,
    required this.clouds,
    required this.dt,
    required this.cityName,
    required this.visibility,
    this.rain1h,
    this.snow1h,
    required this.coord,
    required this.sys,
  });

  /// OpenWeatherMap API JSON 응답에서 WeatherData 객체 생성
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    // 날씨 정보 (첫 번째 항목 사용)
    final List<dynamic> weatherList = json['weather'] ?? [];
    final weatherData = weatherList.isNotEmpty
        ? weatherList[0]
        : {'id': 800, 'main': 'Clear', 'description': '맑음', 'icon': '01d'};

    // 비 데이터 처리
    Map<String, dynamic>? rainData = json['rain'];
    double? rain1h;
    if (rainData != null && rainData.containsKey('1h')) {
      rain1h = (rainData['1h'] as num).toDouble();
    }

    // 눈 데이터 처리
    Map<String, dynamic>? snowData = json['snow'];
    double? snow1h;
    if (snowData != null && snowData.containsKey('1h')) {
      snow1h = (snowData['1h'] as num).toDouble();
    }

    // 메인 날씨 데이터
    final Map<String, dynamic> main = json['main'] ?? {};
    
    // 바람 데이터
    final Map<String, dynamic> wind = json['wind'] ?? {};
    
    return WeatherData(
      id: weatherData['id'] as int,
      main: weatherData['main'] as String,
      description: weatherData['description'] as String,
      icon: weatherData['icon'] as String,
      temp: (main['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      tempMin: (main['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (main['temp_max'] as num?)?.toDouble() ?? 0.0,
      pressure: (main['pressure'] as num?)?.toInt() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      windDeg: (wind['deg'] as num?)?.toInt() ?? 0,
      windGust: (wind['gust'] as num?)?.toDouble(),
      clouds: (json['clouds']?['all'] as num?)?.toInt() ?? 0,
      dt: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      cityName: json['name'] as String? ?? '알 수 없음',
      visibility: (json['visibility'] as num?)?.toInt() ?? 0,
      rain1h: rain1h,
      snow1h: snow1h,
      coord: Coord.fromJson(json['coord'] ?? {}),
      sys: Sys.fromJson(json['sys'] ?? {}),
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'weather': [
        {
          'id': id,
          'main': main,
          'description': description,
          'icon': icon,
        }
      ],
      'main': {
        'temp': temp,
        'feels_like': feelsLike,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'pressure': pressure,
        'humidity': humidity,
      },
      'wind': {
        'speed': windSpeed,
        'deg': windDeg,
        'gust': windGust,
      },
      'clouds': {'all': clouds},
      'dt': dt.millisecondsSinceEpoch ~/ 1000,
      'name': cityName,
      'visibility': visibility,
      'rain': rain1h != null ? {'1h': rain1h} : null,
      'snow': snow1h != null ? {'1h': snow1h} : null,
      'coord': coord.toJson(),
      'sys': sys.toJson(),
    };
  }

  /// 날씨 상태에 따른 아이콘 URL 반환
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  /// 날씨 카테고리 반환 (앱에서 사용)
  String get weatherCategory {
    final mainType = main.toLowerCase();
    if (mainType.contains('thunderstorm')) return '천둥번개';
    if (mainType.contains('drizzle')) return '이슬비';
    if (mainType.contains('rain')) return '비';
    if (mainType.contains('snow')) return '눈';
    if (mainType.contains('mist') || 
        mainType.contains('fog') || 
        mainType.contains('haze')) return '안개';
    if (mainType.contains('dust') || 
        mainType.contains('sand') || 
        mainType.contains('ash')) return '미세먼지';
    if (mainType.contains('clouds')) {
      if (clouds > 70) return '흐림';
      return '구름많음';
    }
    if (mainType.contains('clear')) return '맑음';
    
    return '알 수 없음';
  }

  /// 온도에 따른 카테고리 반환
  String get temperatureCategory {
    if (temp <= 0) return '매우 추움';
    if (temp <= 5) return '추움';
    if (temp <= 10) return '쌀쌀함';
    if (temp <= 15) return '선선함';
    if (temp <= 20) return '적당함';
    if (temp <= 25) return '따뜻함';
    if (temp <= 30) return '더움';
    return '매우 더움';
  }
}

/// 시간별 날씨 예보
class HourlyForecast {
  final DateTime dt; // 예보 시간
  final int weather; // 날씨 상태 ID
  final String main; // 메인 날씨 (Clear, Rain, Snow 등)
  final String description; // 날씨 설명
  final String icon; // 날씨 아이콘 코드
  final double temp; // 기온
  final double feelsLike; // 체감 기온
  final int pressure; // 기압
  final int humidity; // 습도
  final double windSpeed; // 풍속
  final int windDeg; // 풍향
  final double? windGust; // 돌풍
  final int clouds; // 구름
  final double? pop; // 강수 확률 (0-1)
  final double? rain; // 3시간 강수량
  final double? snow; // 3시간 적설량
  final int visibility; // 가시거리

  HourlyForecast({
    required this.dt,
    required this.weather,
    required this.main,
    required this.description,
    required this.icon,
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    this.windGust,
    required this.clouds,
    this.pop,
    this.rain,
    this.snow,
    required this.visibility,
  });

  /// OpenWeatherMap API JSON 응답에서 HourlyForecast 객체 생성
  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    // 날씨 정보 (첫 번째 항목 사용)
    final List<dynamic> weatherList = json['weather'] ?? [];
    final weatherData = weatherList.isNotEmpty
        ? weatherList[0]
        : {'id': 800, 'main': 'Clear', 'description': '맑음', 'icon': '01d'};

    // 비 데이터 처리
    double? rain;
    if (json.containsKey('rain') && json['rain'] is Map) {
      rain = (json['rain']['3h'] as num?)?.toDouble();
    }

    // 눈 데이터 처리
    double? snow;
    if (json.containsKey('snow') && json['snow'] is Map) {
      snow = (json['snow']['3h'] as num?)?.toDouble();
    }

    return HourlyForecast(
      dt: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      weather: weatherData['id'] as int,
      main: weatherData['main'] as String,
      description: weatherData['description'] as String,
      icon: weatherData['icon'] as String,
      temp: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['main']?['feels_like'] as num?)?.toDouble() ?? 0.0,
      pressure: (json['main']?['pressure'] as num?)?.toInt() ?? 0,
      humidity: (json['main']?['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      windDeg: (json['wind']?['deg'] as num?)?.toInt() ?? 0,
      windGust: (json['wind']?['gust'] as num?)?.toDouble(),
      clouds: (json['clouds']?['all'] as num?)?.toInt() ?? 0,
      pop: (json['pop'] as num?)?.toDouble(),
      rain: rain,
      snow: snow,
      visibility: (json['visibility'] as num?)?.toInt() ?? 0,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'dt': dt.millisecondsSinceEpoch ~/ 1000,
      'weather': [
        {
          'id': weather,
          'main': main,
          'description': description,
          'icon': icon,
        }
      ],
      'main': {
        'temp': temp,
        'feels_like': feelsLike,
        'pressure': pressure,
        'humidity': humidity,
      },
      'wind': {
        'speed': windSpeed,
        'deg': windDeg,
        'gust': windGust,
      },
      'clouds': {'all': clouds},
      'pop': pop,
      'rain': rain != null ? {'3h': rain} : null,
      'snow': snow != null ? {'3h': snow} : null,
      'visibility': visibility,
    };
  }

  /// 날씨 상태에 따른 아이콘 URL 반환
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}

/// 일별 날씨 예보
class DailyForecast {
  final DateTime dt; // 예보 날짜
  final DateTime sunrise; // 일출 시간
  final DateTime sunset; // 일몰 시간
  final int weather; // 날씨 상태 ID
  final String main; // 메인 날씨 (Clear, Rain, Snow 등)
  final String description; // 날씨 설명
  final String icon; // 날씨 아이콘 코드
  final Temperature temp; // 온도 정보
  final Temperature feelsLike; // 체감 온도 정보
  final int pressure; // 기압
  final int humidity; // 습도
  final double dewPoint; // 이슬점
  final double windSpeed; // 풍속
  final int windDeg; // 풍향
  final double? windGust; // 돌풍
  final int clouds; // 구름
  final double uvi; // 자외선 지수
  final double pop; // 강수 확률 (0-1)
  final double? rain; // 강수량
  final double? snow; // 적설량

  DailyForecast({
    required this.dt,
    required this.sunrise,
    required this.sunset,
    required this.weather,
    required this.main,
    required this.description,
    required this.icon,
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.dewPoint,
    required this.windSpeed,
    required this.windDeg,
    this.windGust,
    required this.clouds,
    required this.uvi,
    required this.pop,
    this.rain,
    this.snow,
  });

  /// OpenWeatherMap API JSON 응답에서 DailyForecast 객체 생성
  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    // 날씨 정보 (첫 번째 항목 사용)
    final List<dynamic> weatherList = json['weather'] ?? [];
    final weatherData = weatherList.isNotEmpty
        ? weatherList[0]
        : {'id': 800, 'main': 'Clear', 'description': '맑음', 'icon': '01d'};

    return DailyForecast(
      dt: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      sunrise: DateTime.fromMillisecondsSinceEpoch((json['sunrise'] as int) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch((json['sunset'] as int) * 1000),
      weather: weatherData['id'] as int,
      main: weatherData['main'] as String,
      description: weatherData['description'] as String,
      icon: weatherData['icon'] as String,
      temp: Temperature.fromJson(json['temp'] ?? {}),
      feelsLike: Temperature.fromJson(json['feels_like'] ?? {}),
      pressure: (json['pressure'] as num?)?.toInt() ?? 0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      dewPoint: (json['dew_point'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
      windDeg: (json['wind_deg'] as num?)?.toInt() ?? 0,
      windGust: (json['wind_gust'] as num?)?.toDouble(),
      clouds: (json['clouds'] as num?)?.toInt() ?? 0,
      uvi: (json['uvi'] as num?)?.toDouble() ?? 0.0,
      pop: (json['pop'] as num?)?.toDouble() ?? 0.0,
      rain: (json['rain'] as num?)?.toDouble(),
      snow: (json['snow'] as num?)?.toDouble(),
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'dt': dt.millisecondsSinceEpoch ~/ 1000,
      'sunrise': sunrise.millisecondsSinceEpoch ~/ 1000,
      'sunset': sunset.millisecondsSinceEpoch ~/ 1000,
      'weather': [
        {
          'id': weather,
          'main': main,
          'description': description,
          'icon': icon,
        }
      ],
      'temp': temp.toJson(),
      'feels_like': feelsLike.toJson(),
      'pressure': pressure,
      'humidity': humidity,
      'dew_point': dewPoint,
      'wind_speed': windSpeed,
      'wind_deg': windDeg,
      'wind_gust': windGust,
      'clouds': clouds,
      'uvi': uvi,
      'pop': pop,
      'rain': rain,
      'snow': snow,
    };
  }

  /// 날씨 상태에 따른 아이콘 URL 반환
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
  
  /// 강수 확률을 백분율로 표시
  String get popFormatted => '${(pop * 100).toInt()}%';
}

/// 일별 온도 정보 모델
class Temperature {
  final double day; // 낮 온도
  final double night; // 밤 온도
  final double eve; // 저녁 온도
  final double morn; // 아침 온도
  final double min; // 최저 온도
  final double max; // 최고 온도

  Temperature({
    required this.day,
    required this.night,
    required this.eve,
    required this.morn,
    required this.min,
    required this.max,
  });

  /// OpenWeatherMap API JSON 응답에서 Temperature 객체 생성
  factory Temperature.fromJson(Map<String, dynamic> json) {
    return Temperature(
      day: (json['day'] as num?)?.toDouble() ?? 0.0,
      night: (json['night'] as num?)?.toDouble() ?? 0.0,
      eve: (json['eve'] as num?)?.toDouble() ?? 0.0,
      morn: (json['morn'] as num?)?.toDouble() ?? 0.0,
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'night': night,
      'eve': eve,
      'morn': morn,
      'min': min,
      'max': max,
    };
  }
}

/// 대기질 정보 모델
class AirQuality {
  final DateTime dt; // 데이터 시간
  final int aqi; // 대기질 지수 (1: 좋음 ~ 5: 매우 나쁨)
  final double co; // 일산화탄소 (μg/m3)
  final double no; // 일산화질소 (μg/m3)
  final double no2; // 이산화질소 (μg/m3)
  final double o3; // 오존 (μg/m3)
  final double so2; // 이산화황 (μg/m3)
  final double pm2_5; // 초미세먼지 (μg/m3)
  final double pm10; // 미세먼지 (μg/m3)
  final double nh3; // 암모니아 (μg/m3)

  AirQuality({
    required this.dt,
    required this.aqi,
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.nh3,
  });

  /// OpenWeatherMap API JSON 응답에서 AirQuality 객체 생성
  factory AirQuality.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['list'] ?? [];
    
    if (list.isEmpty) {
      // 기본값으로 생성
      return AirQuality(
        dt: DateTime.now(),
        aqi: 1,
        co: 0.0,
        no: 0.0,
        no2: 0.0,
        o3: 0.0,
        so2: 0.0,
        pm2_5: 0.0,
        pm10: 0.0,
        nh3: 0.0,
      );
    }
    
    final Map<String, dynamic> data = list[0];
    final Map<String, dynamic> components = data['components'] ?? {};
    
    return AirQuality(
      dt: DateTime.fromMillisecondsSinceEpoch((data['dt'] as int) * 1000),
      aqi: (data['main']?['aqi'] as num?)?.toInt() ?? 1,
      co: (components['co'] as num?)?.toDouble() ?? 0.0,
      no: (components['no'] as num?)?.toDouble() ?? 0.0,
      no2: (components['no2'] as num?)?.toDouble() ?? 0.0,
      o3: (components['o3'] as num?)?.toDouble() ?? 0.0,
      so2: (components['so2'] as num?)?.toDouble() ?? 0.0,
      pm2_5: (components['pm2_5'] as num?)?.toDouble() ?? 0.0,
      pm10: (components['pm10'] as num?)?.toDouble() ?? 0.0,
      nh3: (components['nh3'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'list': [
        {
          'dt': dt.millisecondsSinceEpoch ~/ 1000,
          'main': {'aqi': aqi},
          'components': {
            'co': co,
            'no': no,
            'no2': no2,
            'o3': o3,
            'so2': so2,
            'pm2_5': pm2_5,
            'pm10': pm10,
            'nh3': nh3,
          },
        }
      ],
    };
  }

  /// 대기질 지수 문자열 반환
  String get aqiText {
    switch (aqi) {
      case 1:
        return '좋음';
      case 2:
        return '보통';
      case 3:
        return '나쁨';
      case 4:
        return '상당히 나쁨';
      case 5:
        return '매우 나쁨';
      default:
        return '정보 없음';
    }
  }

  /// 미세먼지 단계 반환
  String get pm10Level {
    if (pm10 <= 30) return '좋음';
    if (pm10 <= 80) return '보통';
    if (pm10 <= 150) return '나쁨';
    return '매우 나쁨';
  }

  /// 초미세먼지 단계 반환
  String get pm25Level {
    if (pm2_5 <= 15) return '좋음';
    if (pm2_5 <= 35) return '보통';
    if (pm2_5 <= 75) return '나쁨';
    return '매우 나쁨';
  }
}

/// 좌표 정보 모델
class Coord {
  final double lat; // 위도
  final double lon; // 경도

  Coord({
    required this.lat,
    required this.lon,
  });

  /// JSON 데이터에서 좌표 객체 생성
  factory Coord.fromJson(Map<String, dynamic> json) {
    return Coord(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
    };
  }
}

/// 국가, 일출, 일몰 정보 모델
class Sys {
  final String country; // 국가 코드
  final DateTime sunrise; // 일출 시간
  final DateTime sunset; // 일몰 시간

  Sys({
    required this.country,
    required this.sunrise,
    required this.sunset,
  });

  /// JSON 데이터에서 Sys 객체 생성
  factory Sys.fromJson(Map<String, dynamic> json) {
    return Sys(
      country: json['country'] as String? ?? '',
      sunrise: DateTime.fromMillisecondsSinceEpoch(
          ((json['sunrise'] as int?) ?? 0) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(
          ((json['sunset'] as int?) ?? 0) * 1000),
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'sunrise': sunrise.millisecondsSinceEpoch ~/ 1000,
      'sunset': sunset.millisecondsSinceEpoch ~/ 1000,
    };
  }
} 