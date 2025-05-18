/// 날씨 아이콘 유틸리티 클래스
class WeatherIcons {
  /// 날씨 아이콘 코드에 해당하는 이미지 경로를 반환합니다.
  static String getIconPath(String iconCode) {
    return 'assets/icons/$iconCode.png';
  }
  
  /// 배경 이미지 경로 반환
  static String getBackgroundPath(String iconCode) {
    // 맑음
    if (iconCode.startsWith('01')) {
      return iconCode.endsWith('d')
          ? 'assets/backgrounds/clear_day.jpg'
          : 'assets/backgrounds/clear_night.jpg';
    }
    
    // 구름 조금
    if (iconCode.startsWith('02')) {
      return iconCode.endsWith('d')
          ? 'assets/backgrounds/few_clouds_day.jpg'
          : 'assets/backgrounds/few_clouds_night.jpg';
    }
    
    // 구름/흐림
    if (iconCode.startsWith('03') || iconCode.startsWith('04')) {
      return 'assets/backgrounds/cloudy.jpg';
    }
    
    // 소나기
    if (iconCode.startsWith('09')) {
      return 'assets/backgrounds/shower_rain.jpg';
    }
    
    // 비
    if (iconCode.startsWith('10')) {
      return iconCode.endsWith('d')
          ? 'assets/backgrounds/rain_day.jpg'
          : 'assets/backgrounds/rain_night.jpg';
    }
    
    // 뇌우
    if (iconCode.startsWith('11')) {
      return 'assets/backgrounds/thunderstorm.jpg';
    }
    
    // 눈
    if (iconCode.startsWith('13')) {
      return 'assets/backgrounds/snow.jpg';
    }
    
    // 안개
    if (iconCode.startsWith('50')) {
      return 'assets/backgrounds/mist.jpg';
    }
    
    // 기본 배경
    return 'assets/backgrounds/default.jpg';
  }
  
  /// 날씨 타입에 따른 배경색 반환
  static List<Map<String, double>> getGradientColors(String iconCode) {
    if (iconCode.startsWith('01')) {
      // 맑음
      return iconCode.endsWith('d')
          ? [
              {'r': 64, 'g': 145, 'b': 247, 'opacity': 1.0}, // 맑은 하늘색
              {'r': 5, 'g': 108, 'b': 248, 'opacity': 1.0}, // 진한 하늘색
            ]
          : [
              {'r': 15, 'g': 32, 'b': 84, 'opacity': 1.0}, // 진한 남색
              {'r': 44, 'g': 55, 'b': 95, 'opacity': 1.0}, // 보라색 톤
            ];
    } else if (iconCode.startsWith('02')) {
      // 구름 조금
      return iconCode.endsWith('d')
          ? [
              {'r': 107, 'g': 155, 'b': 227, 'opacity': 1.0}, // 구름 낀 하늘색
              {'r': 142, 'g': 176, 'b': 223, 'opacity': 1.0},
            ]
          : [
              {'r': 32, 'g': 45, 'b': 85, 'opacity': 1.0},
              {'r': 56, 'g': 63, 'b': 97, 'opacity': 1.0},
            ];
    } else if (iconCode.startsWith('03') || iconCode.startsWith('04')) {
      // 구름/흐림
      return [
        {'r': 134, 'g': 150, 'b': 167, 'opacity': 1.0}, // 회색빛 하늘
        {'r': 86, 'g': 108, 'b': 138, 'opacity': 1.0},
      ];
    } else if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      // 비/소나기
      return [
        {'r': 91, 'g': 104, 'b': 119, 'opacity': 1.0}, // 우중충한 회색
        {'r': 57, 'g': 71, 'b': 89, 'opacity': 1.0},
      ];
    } else if (iconCode.startsWith('11')) {
      // 뇌우
      return [
        {'r': 58, 'g': 59, 'b': 60, 'opacity': 1.0}, // 매우 어두운 회색
        {'r': 28, 'g': 30, 'b': 40, 'opacity': 1.0},
      ];
    } else if (iconCode.startsWith('13')) {
      // 눈
      return [
        {'r': 230, 'g': 237, 'b': 242, 'opacity': 1.0}, // 밝은 하얀색
        {'r': 176, 'g': 209, 'b': 234, 'opacity': 1.0}, // 옅은 하늘색
      ];
    } else if (iconCode.startsWith('50')) {
      // 안개
      return [
        {'r': 190, 'g': 190, 'b': 190, 'opacity': 1.0}, // 안개 낀 회색
        {'r': 139, 'g': 143, 'b': 150, 'opacity': 1.0},
      ];
    }
    
    // 기본 그라데이션
    return [
      {'r': 103, 'g': 160, 'b': 223, 'opacity': 1.0},
      {'r': 67, 'g': 120, 'b': 180, 'opacity': 1.0},
    ];
  }
} 