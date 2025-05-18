import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/favorite_location_model.dart';
import '../../models/user_model.dart';
import '../../models/weather_model.dart';
import '../../providers/weather_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/favorite_locations_provider.dart';
import '../../widgets/hourly_forecast_widget.dart';
import '../../widgets/daily_forecast_widget.dart';
import '../../widgets/weather_summary_widget.dart';
import '../../widgets/outfit_recommendation_widget.dart';
import '../../widgets/loader_widget.dart';
import '../../utils/weather_icons.dart';
import '../../services/location_service.dart';  // LocationData 클래스를 import

/// 즐겨찾기 상세 화면
class FavoriteDetailScreen extends StatefulWidget {
  final FavoriteLocation location;

  const FavoriteDetailScreen({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  State<FavoriteDetailScreen> createState() => _FavoriteDetailScreenState();
}

class _FavoriteDetailScreenState extends State<FavoriteDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _isRefreshing = false;
  
  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }
  
  // 날씨 데이터 로드
  Future<void> _loadWeatherData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 위치 데이터로 LocationData 생성
      final locationData = LocationData(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
        name: widget.location.name,
        country: 'KR',
        address: widget.location.address,
      );
      
      // 날씨 공급자를 통해 해당 위치의 날씨 정보 로드
      await Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeatherForLocation(locationData);
      
      // 사용자 정보 로드
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final WeatherProvider weatherProvider = 
          Provider.of<WeatherProvider>(context, listen: false);
      
      // 사용자 프로필이 있을 경우 개인화된 날씨 계산
      if (userProvider.user != null) {
        weatherProvider.calculatePersonalizedWeather(userProvider.user!);
      }
      
      // 즐겨찾기 위치 날씨 정보 업데이트
      if (weatherProvider.currentWeather != null) {
        Provider.of<FavoriteLocationsProvider>(context, listen: false)
            .updateWeatherInfo(
              widget.location.id,
              weatherProvider.currentWeather!.icon,
              weatherProvider.currentWeather!.temp,
            );
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '날씨 데이터를 가져오는 중 오류가 발생했습니다: $e';
      });
    }
  }
  
  // 새로고침 처리
  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      await _loadWeatherData();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _handleRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isLoading ? null : _showEditDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoaderWidget())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildWeatherContent(),
    );
  }
  
  // 오류 표시 위젯
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? '알 수 없는 오류가 발생했습니다.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleRefresh,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
  
  // 날씨 정보 위젯
  Widget _buildWeatherContent() {
    return Consumer2<WeatherProvider, UserProvider>(
      builder: (context, weatherProvider, userProvider, child) {
        final weather = weatherProvider.currentWeather;
        final user = userProvider.user;
        
        if (weather == null) {
          return const Center(
            child: Text('날씨 데이터를 불러올 수 없습니다.'),
          );
        }
        
        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 현재 날씨 요약
                WeatherSummaryWidget(
                  weather: weather,
                  locationName: widget.location.name,
                ),
                
                // 개인화된 날씨 정보
                if (user != null && weatherProvider.personalizedFeelTemp != null)
                  _buildPersonalizedWeather(weatherProvider, user),
                
                // 시간별 예보
                if (weatherProvider.hourlyForecast != null &&
                    weatherProvider.hourlyForecast!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: HourlyForecastWidget(
                      hourlyForecast: weatherProvider.hourlyForecast!,
                    ),
                  ),
                
                // 일별 예보
                if (weatherProvider.dailyForecast != null &&
                    weatherProvider.dailyForecast!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DailyForecastWidget(
                      dailyForecast: weatherProvider.dailyForecast!,
                    ),
                  ),
                
                // 옷차림 추천
                if (user != null && weatherProvider.recommendedOutfits != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OutfitRecommendationWidget(
                      temperature: weather.temp,
                      weatherCondition: weather.description,
                      userPreferences: {
                        'gender': user.gender ?? 'female',
                        'age': user.birthYear != null ? DateTime.now().year - user.birthYear! : 30,
                        'tempSensitivity': user.preferredTemperature == null ? 'normal' : 
                            (user.preferredTemperature! > 1 ? 'cold_sensitive' : 
                             (user.preferredTemperature! < -1 ? 'heat_sensitive' : 'normal')),
                      },
                    ),
                  ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // 개인화된 날씨 정보 위젯
  Widget _buildPersonalizedWeather(
      WeatherProvider weatherProvider, UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '개인화된 날씨 정보',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('${user.name}님의 체감 온도'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${weatherProvider.personalizedFeelTemp!.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '(실제 ${weatherProvider.currentWeather!.temp.toStringAsFixed(1)}°)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    weatherProvider.tempCategory ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 즐겨찾기 편집 다이얼로그
  void _showEditDialog() {
    final textController = TextEditingController(text: widget.location.name);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('즐겨찾기 편집'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: '장소 이름',
              hintText: '장소 이름을 입력하세요',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _updateFavoriteName(textController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }
  
  // 즐겨찾기 이름 업데이트
  void _updateFavoriteName(String newName) {
    if (newName.isEmpty || newName == widget.location.name) {
      return;
    }
    
    final updatedLocation = widget.location.copyWith(name: newName);
    
    Provider.of<FavoriteLocationsProvider>(context, listen: false)
        .updateLocation(updatedLocation);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('즐겨찾기 이름이 변경되었습니다'),
      ),
    );
  }
}

