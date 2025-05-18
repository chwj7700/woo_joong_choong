import 'package:flutter/material.dart';
import '../models/outfit_model.dart';

/// 옷차림 추천 위젯
class OutfitRecommendationWidget extends StatelessWidget {
  final double temperature; // 온도
  final String weatherCondition; // 날씨 상태 (맑음, 비, 눈 등)
  final Map<String, dynamic> userPreferences; // 사용자 설정 (성별, 나이, 온도 민감도 등)
  
  const OutfitRecommendationWidget({
    Key? key,
    required this.temperature,
    required this.weatherCondition,
    required this.userPreferences,
  }) : super(key: key);
  
  // 온도와 날씨 조건에 따른 코디 추천
  List<OutfitSet> _getRecommendedOutfits() {
    // 실제 구현에서는 DB나 API에서 가져온 실제 데이터를 사용
    // 여기서는 더미 데이터로 대체
    
    final gender = userPreferences['gender'] as String? ?? 'female';
    
    // 온도 범위 결정 (0: 매우 추움 ~ 8: 매우 더움)
    int tempIndex = 4; // 기본값: 보통
    
    if (temperature <= -5) tempIndex = 0;      // 영하 5도 이하: 매우 추움
    else if (temperature <= 0) tempIndex = 1;  // 영하 0도 이하: 추움
    else if (temperature <= 5) tempIndex = 2;  // 5도 이하: 쌀쌀함
    else if (temperature <= 10) tempIndex = 3; // 10도 이하: 선선함
    else if (temperature <= 16) tempIndex = 4; // 16도 이하: 선선함~보통
    else if (temperature <= 20) tempIndex = 5; // 20도 이하: 보통~따뜻함
    else if (temperature <= 25) tempIndex = 6; // 25도 이하: 따뜻함
    else if (temperature <= 28) tempIndex = 7; // 28도 이하: 더움
    else tempIndex = 8;                        // 28도 초과: 매우 더움
    
    // 특수 날씨 조건 판단
    List<WeatherSpecialCondition> specialConditions = [WeatherSpecialCondition.none];
    
    if (weatherCondition.contains('비') || weatherCondition.contains('소나기')) {
      specialConditions = [WeatherSpecialCondition.rain];
    } else if (weatherCondition.contains('눈')) {
      specialConditions = [WeatherSpecialCondition.snow];
    } else if (weatherCondition.contains('미세먼지') || weatherCondition.contains('황사')) {
      specialConditions = [WeatherSpecialCondition.dusty];
    } else if (weatherCondition.contains('안개')) {
      specialConditions = [WeatherSpecialCondition.fog];
    } else if (weatherCondition.contains('바람') || weatherCondition.contains('강풍')) {
      specialConditions = [WeatherSpecialCondition.windy];
    }
    
    // 예시 더미 데이터
    return _getDummyOutfits(tempIndex, gender, specialConditions);
  }
  
  // 온도와 성별에 따른 더미 코디 데이터 생성
  List<OutfitSet> _getDummyOutfits(int tempIndex, String gender, List<WeatherSpecialCondition> conditions) {
    // 더미 데이터 (실제 구현에서는 DB에서 불러옴)
    final coats = [
      OutfitItem(id: 'o1', name: '롱패딩', description: '겨울용 롱패딩', type: OutfitItemType.outerwear),
      OutfitItem(id: 'o2', name: '숏패딩', description: '겨울용 숏패딩', type: OutfitItemType.outerwear),
      OutfitItem(id: 'o3', name: '코트', description: '겨울~봄/가을용 코트', type: OutfitItemType.outerwear),
      OutfitItem(id: 'o4', name: '가디건', description: '봄/가을용 가디건', type: OutfitItemType.outerwear),
      OutfitItem(id: 'o5', name: '바람막이', description: '가벼운 바람막이', type: OutfitItemType.outerwear),
    ];
    
    final tops = [
      OutfitItem(id: 't1', name: '두꺼운 니트', description: '겨울용 두꺼운 니트', type: OutfitItemType.top),
      OutfitItem(id: 't2', name: '기모 맨투맨', description: '겨울용 기모 맨투맨', type: OutfitItemType.top),
      OutfitItem(id: 't3', name: '니트', description: '가을용 니트', type: OutfitItemType.top),
      OutfitItem(id: 't4', name: '맨투맨', description: '봄/가을용 맨투맨', type: OutfitItemType.top),
      OutfitItem(id: 't5', name: '셔츠', description: '얇은 셔츠', type: OutfitItemType.top),
      OutfitItem(id: 't6', name: '반팔 티셔츠', description: '여름용 반팔', type: OutfitItemType.top),
    ];
    
    final bottoms = [
      OutfitItem(id: 'b1', name: '기모 바지', description: '겨울용 기모 바지', type: OutfitItemType.bottom),
      OutfitItem(id: 'b2', name: '슬랙스', description: '일반 슬랙스', type: OutfitItemType.bottom),
      OutfitItem(id: 'b3', name: '청바지', description: '기본 청바지', type: OutfitItemType.bottom),
      OutfitItem(id: 'b4', name: '얇은 면바지', description: '여름용 면바지', type: OutfitItemType.bottom),
      OutfitItem(id: 'b5', name: '반바지', description: '여름용 반바지', type: OutfitItemType.bottom),
    ];
    
    final accessories = [
      OutfitItem(id: 'a1', name: '목도리', description: '두꺼운 목도리', type: OutfitItemType.accessory),
      OutfitItem(id: 'a2', name: '장갑', description: '겨울용 장갑', type: OutfitItemType.accessory),
      OutfitItem(id: 'a3', name: '비니', description: '니트 비니', type: OutfitItemType.hat),
      OutfitItem(id: 'a4', name: '양말', description: '기본 양말', type: OutfitItemType.accessory),
      OutfitItem(id: 'a5', name: '선글라스', description: '여름용 선글라스', type: OutfitItemType.accessory),
      OutfitItem(id: 'a6', name: '우산', description: '비/눈 대비 우산', type: OutfitItemType.accessory),
    ];
    
    final shoes = [
      OutfitItem(id: 's1', name: '부츠', description: '겨울용 방한 부츠', type: OutfitItemType.shoes),
      OutfitItem(id: 's2', name: '운동화', description: '일반 운동화', type: OutfitItemType.shoes),
      OutfitItem(id: 's3', name: '로퍼', description: '가을용 로퍼', type: OutfitItemType.shoes),
      OutfitItem(id: 's4', name: '샌들', description: '여름용 샌들', type: OutfitItemType.shoes),
    ];
    
    // 온도별 코디 구성
    List<OutfitSet> outfits = [];
    
    // 매우 추움 (영하 5도 이하)
    if (tempIndex == 0) {
      outfits.add(OutfitSet(
        id: 'o1',
        name: '한파 완전 방한 세트',
        description: '매우 추운 날씨에 적합한 완전 방한 코디입니다.',
        tempRangeIndex: 0,
        gender: gender,
        items: [
          coats[0], tops[0], bottoms[0], shoes[0], accessories[0], accessories[1], accessories[2],
        ],
      ));
    }
    // 추움 (0도 이하)
    else if (tempIndex == 1) {
      outfits.add(OutfitSet(
        id: 'o2',
        name: '겨울 방한 세트',
        description: '추운 겨울에 적합한 방한 코디입니다.',
        tempRangeIndex: 1,
        gender: gender,
        items: [
          coats[1], tops[0], bottoms[0], shoes[0], accessories[0], accessories[2],
        ],
      ));
    }
    // ... 중간 생략 ...
    // 더움 (25도 초과)
    else if (tempIndex >= 7) {
      outfits.add(OutfitSet(
        id: 'o8',
        name: '여름 시원한 세트',
        description: '더운 여름에 적합한 시원한 코디입니다.',
        tempRangeIndex: 8,
        gender: gender,
        items: [
          tops[5], bottoms[4], shoes[3], accessories[4],
        ],
      ));
    }
    // 기본 세트
    else {
      outfits.add(OutfitSet(
        id: 'o9',
        name: '기본 세트',
        description: '일반적인 날씨에 적합한 기본 코디입니다.',
        tempRangeIndex: 4,
        gender: gender,
        items: [
          tops[3], bottoms[2], shoes[1],
        ],
      ));
    }
    
    // 특수 날씨 조건에 맞는 추가 아이템
    if (conditions.contains(WeatherSpecialCondition.rain)) {
      outfits[0].items.add(accessories[5]);  // 우산 추가
      outfits[0].items.add(coats[4]);  // 바람막이 추가
    } else if (conditions.contains(WeatherSpecialCondition.snow)) {
      outfits[0].items.add(accessories[5]);  // 우산 추가
      outfits[0].items.add(accessories[1]);  // 장갑 추가
    }
    
    return outfits;
  }

  @override
  Widget build(BuildContext context) {
    final outfits = _getRecommendedOutfits();
    
    if (outfits.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // 활동 추천 메시지 생성
    final String activityRecommendation = _getActivityRecommendation();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오늘의 코디 추천',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildOutfitCard(context, outfits.first),
        if (activityRecommendation.isNotEmpty) 
          _buildActivityRecommendation(activityRecommendation),
        if (outfits.length > 1) 
          _buildAlternativeOutfits(context, outfits),
      ],
    );
  }

  /// 추천 코디 카드 위젯
  Widget _buildOutfitCard(BuildContext context, OutfitSet outfit) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              outfit.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              outfit.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              '추천 의류 아이템:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...outfit.items.map((item) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.name} - ${item.description}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }

  /// 코디 아이템 목록 위젯
  Widget _buildOutfitItems(OutfitSet outfit) {
    // 종류별로 그룹화
    final Map<OutfitItemType, List<OutfitItem>> itemsByType = {};
    
    for (final item in outfit.items) {
      if (!itemsByType.containsKey(item.type)) {
        itemsByType[item.type] = [];
      }
      itemsByType[item.type]!.add(item);
    }
    
    // 표시 순서 정의
    final typeOrder = [
      OutfitItemType.hat,
      OutfitItemType.outerwear,
      OutfitItemType.top,
      OutfitItemType.bottom,
      OutfitItemType.shoes,
      OutfitItemType.accessory,
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: typeOrder.map((type) {
        if (!itemsByType.containsKey(type) || itemsByType[type]!.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  _getItemTypeLabel(type),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: itemsByType[type]!.map((item) {
                    return Text(item.name);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 피드백 버튼 위젯
  Widget _buildFeedbackButtons(BuildContext context, OutfitSet outfit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.thumb_up_outlined, size: 16),
          label: const Text('도움됨'),
          onPressed: () => _showFeedbackDialog(context, outfit, true),
        ),
        TextButton.icon(
          icon: const Icon(Icons.thumb_down_outlined, size: 16),
          label: const Text('맞지 않음'),
          onPressed: () => _showFeedbackDialog(context, outfit, false),
        ),
      ],
    );
  }

  /// 활동 추천 메시지 생성
  String _getActivityRecommendation() {
    // 날씨와 온도에 따른 활동 추천
    if (weatherCondition.contains('비') || weatherCondition.contains('소나기')) {
      return '비가 오고 있어요. 우산을 챙기고 실내 활동을 추천합니다.';
    } else if (weatherCondition.contains('눈')) {
      return '눈이 오고 있어요. 미끄러우니 조심하세요.';
    } else if (weatherCondition.contains('안개')) {
      return '안개가 짙어요. 운전 시 전방 주시에 주의하세요.';
    } else if (temperature >= 30) {
      return '매우 더운 날씨에요. 물을 자주 마시고 햇빛을 피하세요.';
    } else if (temperature <= 0) {
      return '영하의 날씨에요. 동상에 주의하고 따뜻한 음료를 챙기세요.';
    }
    
    return '';
  }

  /// 활동 추천 위젯
  Widget _buildActivityRecommendation(String recommendation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue[700],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                recommendation,
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 대체 코디 목록 위젯
  Widget _buildAlternativeOutfits(BuildContext context, List<OutfitSet> outfits) {
    final alternatives = outfits.skip(1).take(2).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            '다른 코디 옵션',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...alternatives.map((outfit) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildAlternativeOutfitTile(context, outfit),
          )
        ).toList(),
      ],
    );
  }

  /// 대체 코디 아이템 타일
  Widget _buildAlternativeOutfitTile(BuildContext context, OutfitSet outfit) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      leading: const Icon(Icons.checkroom_outlined),
      title: Text(outfit.name),
      subtitle: Text(
        outfit.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        // 상세 옷차림 보여주기 (향후 구현)
      },
    );
  }

  /// 피드백 다이얼로그 표시
  void _showFeedbackDialog(BuildContext context, OutfitSet outfit, bool isHelpful) {
    showDialog(
      context: context,
      builder: (context) {
        double temperatureRating = 0;
        
        return AlertDialog(
          title: Text(isHelpful ? '코디가 도움이 되었나요?' : '어떤 점이 맞지 않았나요?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('체감 온도는 어땠나요?'),
              StatefulBuilder(
                builder: (context, setState) {
                  return Slider(
                    value: temperatureRating,
                    min: -2,
                    max: 2,
                    divisions: 4,
                    label: _getTemperatureLabel(temperatureRating),
                    onChanged: (value) {
                      setState(() {
                        temperatureRating = value;
                      });
                    },
                  );
                },
              ),
              Text(
                _getTemperatureLabel(temperatureRating),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 피드백 저장 로직
                // TODO: 피드백 저장 서비스 호출
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('피드백이 저장되었습니다. 감사합니다!'),
                  ),
                );
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  /// 온도 평가 레이블 가져오기
  String _getTemperatureLabel(double value) {
    if (value <= -2) return '너무 추웠어요';
    if (value <= -1) return '조금 추웠어요';
    if (value <= 0) return '적당했어요';
    if (value <= 1) return '조금 더웠어요';
    return '너무 더웠어요';
  }

  /// 아이템 타입 레이블 가져오기
  String _getItemTypeLabel(OutfitItemType type) {
    switch (type) {
      case OutfitItemType.hat:
        return '모자/헤드';
      case OutfitItemType.outerwear:
        return '아우터';
      case OutfitItemType.top:
        return '상의';
      case OutfitItemType.bottom:
        return '하의';
      case OutfitItemType.shoes:
        return '신발';
      case OutfitItemType.accessory:
        return '액세서리';
    }
  }
} 