import 'package:uuid/uuid.dart';
import '../models/weather_model.dart';
import '../models/user_model.dart';
import '../models/outfit_model.dart';
import '../services/personalized_weather_calculator.dart';

/// 날씨와 사용자 특성에 기반한 코디 추천 서비스
class OutfitRecommendationService {
  final PersonalizedWeatherCalculator _weatherCalculator = PersonalizedWeatherCalculator();
  final List<OutfitSet> _outfitDatabase = [];
  
  OutfitRecommendationService() {
    _initializeOutfitDatabase();
  }
  
  /// 날씨와 사용자 정보에 기반한 코디 추천
  /// [weather] 현재 날씨 데이터
  /// [user] 사용자 모델
  /// [specialConditions] 특별 상황 (옵션)
  List<OutfitSet> getRecommendedOutfits(
    WeatherData weather, 
    UserModel user, 
    {List<WeatherSpecialCondition> specialConditions = const [WeatherSpecialCondition.none]}
  ) {
    // 사용자 특성을 고려한 체감 온도 계산
    final personalizedTemp = _weatherCalculator.calculatePersonalFeelTemp(weather, user);
    
    // 체감 온도에 해당하는 범주 결정
    final tempRangeIndex = _weatherCalculator.getOutfitTempRange(personalizedTemp);
    
    // 성별 정보 (없는 경우 '공용' 반환)
    final gender = user.gender?.toLowerCase() ?? '공용';
    
    // 특수 상황 확인
    List<WeatherSpecialCondition> conditions = _detectSpecialConditions(weather, specialConditions);
    
    // 추천 조건에 맞는 코디 필터링
    final recommendations = _outfitDatabase.where((outfit) {
      // 온도 범위 매칭
      final bool tempMatch = outfit.tempRangeIndex == tempRangeIndex;
      
      // 성별 매칭 (성별 정보가 '공용'이거나 사용자 성별과 일치하는 경우)
      final bool genderMatch = outfit.gender.toLowerCase() == '공용' || 
                               outfit.gender.toLowerCase() == gender;
      
      // 특수 상황 매칭 (outfit의 모든 특수 상황이 현재 상황에 포함되는지)
      bool conditionsMatch = true;
      for (final condition in outfit.specialConditions) {
        if (condition != WeatherSpecialCondition.none && 
            !conditions.contains(condition)) {
          conditionsMatch = false;
          break;
        }
      }
      
      return tempMatch && genderMatch && conditionsMatch;
    }).toList();
    
    // 추천 결과가 없는 경우 온도만 맞는 코디 반환
    if (recommendations.isEmpty) {
      return _outfitDatabase.where((outfit) {
        return outfit.tempRangeIndex == tempRangeIndex &&
               (outfit.gender.toLowerCase() == '공용' || 
                outfit.gender.toLowerCase() == gender);
      }).toList();
    }
    
    return recommendations;
  }
  
  /// 현재 날씨 상태에서 특수 상황 감지
  List<WeatherSpecialCondition> _detectSpecialConditions(
    WeatherData weather,
    List<WeatherSpecialCondition> additionalConditions
  ) {
    final List<WeatherSpecialCondition> conditions = List.from(additionalConditions);
    
    // 비 상황 감지
    if (weather.rain1h != null && weather.rain1h! > 0) {
      conditions.add(WeatherSpecialCondition.rain);
    } else if (weather.main.toLowerCase().contains('rain')) {
      conditions.add(WeatherSpecialCondition.rain);
    }
    
    // 눈 상황 감지
    if (weather.snow1h != null && weather.snow1h! > 0) {
      conditions.add(WeatherSpecialCondition.snow);
    } else if (weather.main.toLowerCase().contains('snow')) {
      conditions.add(WeatherSpecialCondition.snow);
    }
    
    // 미세먼지 상황 감지 (별도 API 데이터 필요)
    
    // 강풍 상황 감지
    if (weather.windSpeed > 8.0) { // 8 m/s 이상을 강풍으로 간주
      conditions.add(WeatherSpecialCondition.windy);
    }
    
    // 습함 상황 감지
    if (weather.humidity > 80) {
      conditions.add(WeatherSpecialCondition.humid);
    }
    
    // 안개 상황 감지
    if (weather.main.toLowerCase().contains('fog') || 
        weather.main.toLowerCase().contains('mist') ||
        weather.visibility < 1000) {
      conditions.add(WeatherSpecialCondition.fog);
    }
    
    // 조건이 없으면 none 추가
    if (conditions.isEmpty || 
        (conditions.length == 1 && conditions.contains(WeatherSpecialCondition.none))) {
      conditions.clear();
      conditions.add(WeatherSpecialCondition.none);
    } else {
      // none 제거
      conditions.removeWhere((condition) => condition == WeatherSpecialCondition.none);
    }
    
    return conditions;
  }
  
  /// 사용자 피드백 저장
  Future<void> saveOutfitFeedback(OutfitFeedback feedback) async {
    // 여기서는 로컬에 저장하는 구현만 제공
    // 피드백 저장 로직 (SharedPreferences나 Firebase 연동)
    
    // 피드백에 기반한 사용자 선호도 조정
    _updateUserPreferences(feedback);
  }
  
  /// 사용자 피드백으로 선호도 업데이트
  void _updateUserPreferences(OutfitFeedback feedback) {
    // 피드백에 기반하여 사용자 preferredTemperature 등 조정
    // 구현은 UserService와 연동 필요
  }
  
  /// 테스트용 코디 데이터베이스 초기화
  void _initializeOutfitDatabase() {
    // 아이템 정의
    final hatBeanie = OutfitItem(
      id: 'hat_beanie',
      name: '비니',
      description: '따뜻한 니트 소재의 비니',
      type: OutfitItemType.hat,
      imageUrl: 'assets/images/outfits/beanie.png',
    );
    
    final hatCap = OutfitItem(
      id: 'hat_cap',
      name: '캡모자',
      description: '캐주얼한 스타일의 캡모자',
      type: OutfitItemType.hat,
      imageUrl: 'assets/images/outfits/cap.png',
    );
    
    final outerwearPadding = OutfitItem(
      id: 'outerwear_padding',
      name: '롱패딩',
      description: '두꺼운 롱패딩',
      type: OutfitItemType.outerwear,
      imageUrl: 'assets/images/outfits/long_padding.png',
    );
    
    final outerwearCoat = OutfitItem(
      id: 'outerwear_coat',
      name: '코트',
      description: '모직 코트',
      type: OutfitItemType.outerwear,
      imageUrl: 'assets/images/outfits/coat.png',
    );
    
    final outerwearJacket = OutfitItem(
      id: 'outerwear_jacket',
      name: '자켓',
      description: '데님 자켓',
      type: OutfitItemType.outerwear,
      imageUrl: 'assets/images/outfits/jacket.png',
    );
    
    final outerwearVest = OutfitItem(
      id: 'outerwear_vest',
      name: '조끼',
      description: '경량 패딩 조끼',
      type: OutfitItemType.outerwear,
      imageUrl: 'assets/images/outfits/vest.png',
    );
    
    final topSweater = OutfitItem(
      id: 'top_sweater',
      name: '니트 스웨터',
      description: '두꺼운 울 소재 니트',
      type: OutfitItemType.top,
      imageUrl: 'assets/images/outfits/sweater.png',
    );
    
    final topHoodie = OutfitItem(
      id: 'top_hoodie',
      name: '후드티',
      description: '두꺼운 기모 후드티',
      type: OutfitItemType.top,
      imageUrl: 'assets/images/outfits/hoodie.png',
    );
    
    final topSweatshirt = OutfitItem(
      id: 'top_sweatshirt',
      name: '맨투맨',
      description: '기모 맨투맨',
      type: OutfitItemType.top,
      imageUrl: 'assets/images/outfits/sweatshirt.png',
    );
    
    final topLongT = OutfitItem(
      id: 'top_long_tshirt',
      name: '긴팔 티셔츠',
      description: '베이직한 긴팔 티셔츠',
      type: OutfitItemType.top,
      imageUrl: 'assets/images/outfits/long_tshirt.png',
    );
    
    final topTshirt = OutfitItem(
      id: 'top_tshirt',
      name: '반팔 티셔츠',
      description: '가벼운 면 티셔츠',
      type: OutfitItemType.top,
      imageUrl: 'assets/images/outfits/tshirt.png',
    );
    
    final bottomJeans = OutfitItem(
      id: 'bottom_jeans',
      name: '청바지',
      description: '일자 데님 청바지',
      type: OutfitItemType.bottom,
      imageUrl: 'assets/images/outfits/jeans.png',
    );
    
    final bottomSlacks = OutfitItem(
      id: 'bottom_slacks',
      name: '슬랙스',
      description: '기본 슬랙스',
      type: OutfitItemType.bottom,
      imageUrl: 'assets/images/outfits/slacks.png',
    );
    
    final bottomShorts = OutfitItem(
      id: 'bottom_shorts',
      name: '반바지',
      description: '여름용 반바지',
      type: OutfitItemType.bottom,
      imageUrl: 'assets/images/outfits/shorts.png',
    );
    
    final shoesBoots = OutfitItem(
      id: 'shoes_boots',
      name: '부츠',
      description: '방한용 부츠',
      type: OutfitItemType.shoes,
      imageUrl: 'assets/images/outfits/boots.png',
    );
    
    final shoesRunning = OutfitItem(
      id: 'shoes_running',
      name: '운동화',
      description: '편안한 운동화',
      type: OutfitItemType.shoes,
      imageUrl: 'assets/images/outfits/running_shoes.png',
    );
    
    final shoesSandals = OutfitItem(
      id: 'shoes_sandals',
      name: '샌들',
      description: '여름용 샌들',
      type: OutfitItemType.shoes,
      imageUrl: 'assets/images/outfits/sandals.png',
    );
    
    final accessoryScarf = OutfitItem(
      id: 'accessory_scarf',
      name: '목도리',
      description: '따뜻한 목도리',
      type: OutfitItemType.accessory,
      imageUrl: 'assets/images/outfits/scarf.png',
    );
    
    final accessoryGloves = OutfitItem(
      id: 'accessory_gloves',
      name: '장갑',
      description: '방한용 장갑',
      type: OutfitItemType.accessory,
      imageUrl: 'assets/images/outfits/gloves.png',
    );
    
    final accessoryUmbrella = OutfitItem(
      id: 'accessory_umbrella',
      name: '우산',
      description: '접이식 우산',
      type: OutfitItemType.accessory,
      imageUrl: 'assets/images/outfits/umbrella.png',
    );
    
    final accessorySunglasses = OutfitItem(
      id: 'accessory_sunglasses',
      name: '선글라스',
      description: 'UV 차단 선글라스',
      type: OutfitItemType.accessory,
      imageUrl: 'assets/images/outfits/sunglasses.png',
    );
    
    // ========= 온도별 코디 세트 구성 =========
    
    // 매우 추운 날씨 (~4도): 두꺼운 패딩, 목도리, 장갑, 기모 바지 등
    _outfitDatabase.add(OutfitSet(
      id: 'outfit_0_1',
      name: '한파 대비 코디',
      description: '매우 추운 날씨에 적합한 따뜻한 코디',
      tempRangeIndex: 0,
      gender: '공용',
      items: [
        hatBeanie,
        outerwearPadding,
        topSweater,
        bottomJeans,
        shoesBoots,
        accessoryScarf,
        accessoryGloves,
      ],
      imageUrl: 'assets/images/outfits/very_cold_outfit.png',
    ));
    
    // 추운 날씨 (5~8도): 코트, 니트, 목도리 등
    _outfitDatabase.add(OutfitSet(
      id: 'outfit_1_1',
      name: '겨울 데일리 코디',
      description: '추운 날씨에 적합한 따뜻한 코디',
      tempRangeIndex: 1,
      gender: '공용',
      items: [
        outerwearCoat,
        topSweater,
        bottomJeans,
        shoesBoots,
        accessoryScarf,
      ],
      imageUrl: 'assets/images/outfits/cold_outfit.png',
    ));
    
    // 쌀쌀한 날씨 (9~11도): 자켓, 맨투맨 등
    _outfitDatabase.add(OutfitSet(
      id: 'outfit_2_1',
      name: '초봄/늦가을 코디',
      description: '쌀쌀한 날씨에 적합한 코디',
      tempRangeIndex: 2,
      gender: '공용',
      items: [
        outerwearJacket,
        topHoodie,
        bottomJeans,
        shoesRunning,
      ],
      imageUrl: 'assets/images/outfits/chilly_outfit.png',
    ));
    
    // 선선한 날씨 (12~16도): 가벼운 자켓, 긴팔 등
    _outfitDatabase.add(OutfitSet(
      id: 'outfit_3_1',
      name: '봄/가을 코디',
      description: '선선한 날씨에 적합한 코디',
      tempRangeIndex: 3,
      gender: '공용',
      items: [
        outerwearVest,
        topSweatshirt,
        bottomSlacks,
        shoesRunning,
      ],
      imageUrl: 'assets/images/outfits/cool_outfit.png',
    ));
    
    // 조금 선선한 날씨 (17~19도): 긴팔 티셔츠, 가디건 등
    _outfitDatabase.add(OutfitSet(
      id: 'outfit_4_1',
      name: '늦봄/초가을 코디',
      description: '조금 선선한 날씨에 적합한 코디',
      tempRangeIndex: 4,
      gender: '공용',
      items: [
        topLongT,
        bottomJeans,
        shoesRunning,
      ],
      imageUrl: 'assets/images/outfits/mild_cool_outfit.png',
    ));
    
    // 적당한 날씨 (20~22도): 긴팔/반팔 티셔츠 등
    _outfitDatabase.add(OutfitSet(
      id: 'outfit_5_1',
      name: '쾌적한 날씨 코디',
      description: '적당한 온도에 쾌적한 코디',
      tempRangeIndex: 5,
      gender: '공용',
      items: [
        topTshirt,
        bottomJeans,
        shoesRunning,
      ],
      imageUrl: 'assets/images/outfits/pleasant_outfit.png',
    ));
    
    // 조금 더운 날씨 (23~27도): 반팔 티셔츠, 얇은 바지 등
    _outfitDatabase.add(OutfitSet(
      id: 'outfit_6_1',
      name: '초여름 코디',
      description: '조금 더운 날씨에 적합한 시원한 코디',
      tempRangeIndex: 6,
      gender: '공용',
      items: [
        topTshirt,
        bottomSlacks,
        shoesRunning,
        accessorySunglasses,
      ],
      imageUrl: 'assets/images/outfits/warm_outfit.png',
    ));
    
    // 더운 날씨 (28~31도): 반팔, 반바지 등
    _outfitDatabase.add(OutfitSet(
      id: 'outfit_7_1',
      name: '여름 코디',
      description: '더운 날씨에 적합한 시원한 코디',
      tempRangeIndex: 7,
      gender: '공용',
      items: [
        hatCap,
        topTshirt,
        bottomShorts,
        shoesSandals,
        accessorySunglasses,
      ],
      imageUrl: 'assets/images/outfits/hot_outfit.png',
    ));
    
    // 매우 더운 날씨 (32도~): 매우 얇은 옷, 자외선 차단 용품 등
    _outfitDatabase.add(OutfitSet(
      id: 'outfit_8_1',
      name: '폭염 대비 코디',
      description: '매우 더운 날씨에 적합한 시원한 코디',
      tempRangeIndex: 8,
      gender: '공용',
      items: [
        hatCap,
        topTshirt,
        bottomShorts,
        shoesSandals,
        accessorySunglasses,
      ],
      imageUrl: 'assets/images/outfits/very_hot_outfit.png',
    ));
    
    // 특수 상황 코디
    
    // 비 오는 날 코디
    _outfitDatabase.add(OutfitSet(
      id: 'outfit_rain_1',
      name: '비 오는 날 코디',
      description: '비에 대비한 방수 코디',
      tempRangeIndex: 3, // 선선한 날씨
      gender: '공용',
      items: [
        outerwearJacket,
        topLongT,
        bottomJeans,
        shoesBoots,
        accessoryUmbrella,
      ],
      specialConditions: [WeatherSpecialCondition.rain],
      imageUrl: 'assets/images/outfits/rainy_outfit.png',
    ));
    
    // 눈 오는 날 코디
    _outfitDatabase.add(OutfitSet(
      id: 'outfit_snow_1',
      name: '눈 오는 날 코디',
      description: '눈과 추위에 대비한 코디',
      tempRangeIndex: 0, // 매우 추운 날씨
      gender: '공용',
      items: [
        hatBeanie,
        outerwearPadding,
        topSweater,
        bottomJeans,
        shoesBoots,
        accessoryScarf,
        accessoryGloves,
      ],
      specialConditions: [WeatherSpecialCondition.snow],
      imageUrl: 'assets/images/outfits/snowy_outfit.png',
    ));
    
    // 미세먼지 있는 날 코디
    _outfitDatabase.add(OutfitSet(
      id: 'outfit_dusty_1',
      name: '미세먼지 대비 코디',
      description: '미세먼지를 막는 코디',
      tempRangeIndex: 4, // 조금 선선한 날씨
      gender: '공용',
      items: [
        hatCap,
        topLongT,
        bottomJeans,
        shoesRunning,
      ],
      specialConditions: [WeatherSpecialCondition.dusty],
      imageUrl: 'assets/images/outfits/dusty_outfit.png',
    ));
  }
  
  /// 활동별 옷차림 추천 텍스트 생성
  String getActivityRecommendation(double temperature, List<WeatherSpecialCondition> conditions) {
    // 체감 온도 범주
    final category = _weatherCalculator.getTempCategory(temperature);
    
    // 기본 활동 추천
    String recommendation = '';
    
    if (temperature <= 5) {
      recommendation = "오늘은 매우 추운 날씨입니다. 실내 활동을 추천합니다. 외출 시에는 두꺼운 옷차림이 필요합니다.";
    } else if (temperature <= 10) {
      recommendation = "쌀쌀한 날씨입니다. 가벼운 야외 활동은 가능하나, 따뜻한 옷차림이 필요합니다.";
    } else if (temperature <= 16) {
      recommendation = "선선한 날씨로 야외 활동하기 좋습니다. 얇은 겉옷을 준비하세요.";
    } else if (temperature <= 22) {
      recommendation = "야외 활동하기 매우 좋은 날씨입니다. 편안한 옷차림으로 충분합니다.";
    } else if (temperature <= 27) {
      recommendation = "조금 더운 날씨입니다. 그늘이 있는 곳에서의 활동을 추천합니다. 수분 섭취를 잊지 마세요.";
    } else {
      recommendation = "매우 더운 날씨입니다. 한낮에는 야외 활동을 피하고, 자외선 차단제를 꼭 챙기세요.";
    }
    
    // 특수 상황에 따른 추가 추천
    if (conditions.contains(WeatherSpecialCondition.rain)) {
      recommendation += " 비가 오니 우산을 꼭 챙기세요. 미끄럼에 주의하세요.";
    }
    
    if (conditions.contains(WeatherSpecialCondition.snow)) {
      recommendation += " 눈이 오니 방한화와 장갑을 챙기고, 미끄럼에 주의하세요.";
    }
    
    if (conditions.contains(WeatherSpecialCondition.dusty)) {
      recommendation += " 미세먼지가 있으니 마스크 착용을 권장하며, 외출 후 세안을 꼭 하세요.";
    }
    
    if (conditions.contains(WeatherSpecialCondition.windy)) {
      recommendation += " 바람이 강하니 날아가기 쉬운 물건에 주의하세요.";
    }
    
    if (conditions.contains(WeatherSpecialCondition.humid) && temperature > 25) {
      recommendation += " 습도가 높아 체감온도가 더 높게 느껴질 수 있습니다. 통풍이 잘 되는 옷을 입으세요.";
    }
    
    return recommendation;
  }
} 