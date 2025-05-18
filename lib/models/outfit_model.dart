/// 의류 아이템 타입
enum OutfitItemType {
  hat,        // 모자, 비니, 귀마개 등
  outerwear,  // 외투 (코트, 패딩, 자켓 등)
  top,        // 상의 (니트, 맨투맨, 셔츠 등)
  bottom,     // 하의 (바지, 스커트, 치마 등)
  shoes,      // 신발 (운동화, 부츠, 샌들 등)
  accessory,  // 액세서리 (목도리, 장갑, 선글라스 등)
}

/// 특수 상황
enum WeatherSpecialCondition {
  rain,      // 비
  snow,      // 눈
  dusty,     // 미세먼지
  windy,     // 강풍
  humid,     // 습함
  fog,       // 안개
  none,      // 해당 없음
}

/// 의류 아이템 모델
class OutfitItem {
  final String id;
  final String name;
  final String description;
  final OutfitItemType type;
  final String? imageUrl;
  
  OutfitItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.imageUrl,
  });
}

/// 코디 세트 모델
class OutfitSet {
  final String id;
  final String name;
  final String description;
  final int tempRangeIndex; // 온도 범위 인덱스 (0~8)
  final String gender; // '남성', '여성', '공용'
  final List<OutfitItem> items;
  final List<WeatherSpecialCondition> specialConditions;
  final String? imageUrl;
  
  OutfitSet({
    required this.id,
    required this.name,
    required this.description,
    required this.tempRangeIndex,
    required this.gender,
    required this.items,
    this.specialConditions = const [WeatherSpecialCondition.none],
    this.imageUrl,
  });
}

/// 사용자 코디 피드백 모델
class OutfitFeedback {
  final String outfitId;
  final String userId;
  final bool isHelpful;
  final double temperatureRating; // -2(너무 추웠음) ~ 2(너무 더웠음)
  final String? comment;
  final DateTime createdAt;
  
  OutfitFeedback({
    required this.outfitId,
    required this.userId,
    required this.isHelpful,
    required this.temperatureRating,
    this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
} 