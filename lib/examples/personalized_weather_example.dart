import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/user_model.dart';
import '../services/personalized_weather_calculator.dart';
import '../services/outfit_recommendation_service.dart';

/// 개인화된 날씨 계산 및 코디 추천 예제 화면
class PersonalizedWeatherExample extends StatefulWidget {
  const PersonalizedWeatherExample({Key? key}) : super(key: key);

  @override
  _PersonalizedWeatherExampleState createState() => _PersonalizedWeatherExampleState();
}

class _PersonalizedWeatherExampleState extends State<PersonalizedWeatherExample> {
  final PersonalizedWeatherCalculator _calculator = PersonalizedWeatherCalculator();
  final OutfitRecommendationService _outfitService = OutfitRecommendationService();
  
  double _temperature = 20.0;
  double _preferredTemp = 0.0;
  double _sweatRate = 2.5;
  String _gender = '남성';
  
  double _personalizedTemp = 0.0;
  String _tempCategory = '';
  String _activityRecommendation = '';
  
  @override
  void initState() {
    super.initState();
    _updateCalculations();
  }
  
  void _updateCalculations() {
    // 테스트용 날씨 데이터 생성
    final weather = WeatherData(
      id: 800,
      main: 'Clear',
      description: '맑음',
      icon: '01d',
      temp: _temperature,
      feelsLike: _temperature + 1.0,
      tempMin: _temperature - 3.0,
      tempMax: _temperature + 3.0,
      pressure: 1013,
      humidity: 60,
      windSpeed: 3.0,
      windDeg: 180,
      clouds: 0,
      dt: DateTime.now(),
      cityName: '서울',
      visibility: 10000,
      coord: Coord(lat: 37.5665, lon: 126.9780),
      sys: Sys(
        country: 'KR',
        sunrise: DateTime.now().subtract(const Duration(hours: 6)),
        sunset: DateTime.now().add(const Duration(hours: 6)),
      ),
    );
    
    // 테스트용 사용자 모델 생성
    final user = UserModel(
      id: 'test',
      userId: 'test_user',
      email: 'test@example.com',
      name: '테스트 사용자',
      gender: _gender,
      preferredTemperature: _preferredTemp,
      sweatRate: _sweatRate,
    );
    
    // 개인화 계산
    setState(() {
      _personalizedTemp = _calculator.calculatePersonalFeelTemp(weather, user);
      _tempCategory = _calculator.getTempCategory(_personalizedTemp);
      _activityRecommendation = _outfitService.getActivityRecommendation(
        _personalizedTemp, 
        []
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인화 날씨 계산 예제'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날씨 설정
              const Text('외부 온도 설정', style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _temperature,
                min: -10.0,
                max: 40.0,
                divisions: 50,
                label: '${_temperature.toStringAsFixed(1)}°C',
                onChanged: (value) {
                  setState(() {
                    _temperature = value;
                  });
                  _updateCalculations();
                },
              ),
              Text('현재 온도: ${_temperature.toStringAsFixed(1)}°C'),
              
              const SizedBox(height: 20),
              
              // 사용자 설정
              const Text('사용자 설정', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('추위/더위 민감도'),
              Slider(
                value: _preferredTemp,
                min: -3.0,
                max: 3.0,
                divisions: 6,
                label: _preferredTemp == 0 
                  ? '중립' 
                  : (_preferredTemp < 0 
                    ? '추위에 민감 (${_preferredTemp.toStringAsFixed(1)})' 
                    : '더위에 민감 (${_preferredTemp.toStringAsFixed(1)})'),
                onChanged: (value) {
                  setState(() {
                    _preferredTemp = value;
                  });
                  _updateCalculations();
                },
              ),
              
              const Text('땀 분비량'),
              Slider(
                value: _sweatRate,
                min: 0.0,
                max: 5.0,
                divisions: 10,
                label: '${_sweatRate.toStringAsFixed(1)}',
                onChanged: (value) {
                  setState(() {
                    _sweatRate = value;
                  });
                  _updateCalculations();
                },
              ),
              
              // 성별 선택
              const Text('성별'),
              DropdownButton<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: '남성', child: Text('남성')),
                  DropdownMenuItem(value: '여성', child: Text('여성')),
                  DropdownMenuItem(value: '기타', child: Text('기타')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _gender = value;
                    });
                    _updateCalculations();
                  }
                },
              ),
              
              const SizedBox(height: 20),
              
              // 계산 결과
              const Text('개인화된 날씨 결과', style: TextStyle(fontWeight: FontWeight.bold)),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('실제 온도: ${_temperature.toStringAsFixed(1)}°C'),
                      Text('체감 온도: ${_personalizedTemp.toStringAsFixed(1)}°C'),
                      Text('온도 범주: $_tempCategory'),
                      const SizedBox(height: 8),
                      const Text('활동 추천:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_activityRecommendation),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 