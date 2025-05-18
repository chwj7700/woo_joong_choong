import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../utils/colors.dart';
import '../../../routes.dart';
import '../../../providers/weather_provider.dart';
import '../../../models/weather_model.dart';
import '../../../widgets/weather_icon.dart';
import '../../../services/location_service.dart';
import '../../../services/app_preference_service.dart';

/// 홈 화면의 날씨 탭
class WeatherTab extends StatefulWidget {
  const WeatherTab({super.key});

  @override
  State<WeatherTab> createState() => _WeatherTabState();
}

class _WeatherTabState extends State<WeatherTab> {
  final AppPreferenceService _prefService = AppPreferenceService();
  List<LocationData> _recentLocations = [];
  bool _isLoadingPrefs = true;
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
    
    // 화면이 처음 로드될 때 날씨 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      if (weatherProvider.currentWeather == null) {
        weatherProvider.fetchWeatherForCurrentLocation();
      }
    });
  }
  
  /// 설정 로드
  Future<void> _loadPreferences() async {
    await _prefService.loadPreferences();
    
    setState(() {
      _recentLocations = _prefService.recentLocations;
      _isLoadingPrefs = false;
    });
  }
  
  /// 위치 메뉴 표시
  void _showLocationMenu() async {
    await _loadPreferences();
    
    if (!mounted) return;
    
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final selectedLocation = weatherProvider.selectedLocation;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '위치 선택',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, AppRoutes.placeSearch);
                        },
                        icon: const Icon(Icons.add_location_alt),
                        label: const Text('위치 검색'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.my_location, color: AppColors.primary),
                  title: const Text('현재 위치', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('현재 기기 위치 날씨 보기'),
                  selected: selectedLocation == null || 
                           _prefService.useCurrentLocation,
                  selectedTileColor: Colors.grey[100],
                  onTap: () {
                    weatherProvider.fetchWeatherForCurrentLocation();
                    Navigator.of(context).pop();
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text(
                        '최근 검색 위치',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _recentLocations.isEmpty
                      ? const Center(
                          child: Text(
                            '최근 검색한 위치가 없습니다.\n위치를 검색하여 날씨 정보를 확인해보세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _recentLocations.length,
                          itemBuilder: (context, index) {
                            final location = _recentLocations[index];
                            
                            // 주소 구성 (state 및 country 정보 포함)
                            final List<String> addressParts = [];
                            
                            if (location.state != null && location.state!.isNotEmpty) {
                              addressParts.add(location.state!);
                            }
                            
                            if (location.country != null && location.country!.isNotEmpty) {
                              addressParts.add(location.country!);
                            }
                            
                            final String subtitle = addressParts.isEmpty 
                                ? '위도: ${location.latitude.toStringAsFixed(4)}, 경도: ${location.longitude.toStringAsFixed(4)}'
                                : addressParts.join(', ');
                            
                            final isSelected = selectedLocation != null &&
                                location.latitude == selectedLocation.latitude &&
                                location.longitude == selectedLocation.longitude;
                            
                            return ListTile(
                              leading: const Icon(Icons.place_outlined, color: AppColors.primary),
                              title: Text(
                                location.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(subtitle),
                              selected: isSelected,
                              selectedTileColor: Colors.grey[100],
                              onTap: () {
                                weatherProvider.fetchWeatherForLocation(location);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        // 날씨 데이터 로딩 상태에 따른 UI 처리
        final isLoading = weatherProvider.isLoading;
        final hasError = weatherProvider.hasError;
        final weatherData = weatherProvider.currentWeather;
        final hourlyForecast = weatherProvider.hourlyForecast;
        final dailyForecast = weatherProvider.dailyForecast;
        final airQuality = weatherProvider.airQuality;
        final location = weatherProvider.selectedLocation;
        
        // 로딩 중이거나 데이터가 없는 경우
        if (isLoading || weatherData == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // 에러 발생한 경우
        if (hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    weatherProvider.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      weatherProvider.refreshWeather();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // 날씨 데이터가 있는 경우 UI 표시
        return Scaffold(
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: () => weatherProvider.refreshWeather(),
            child: CustomScrollView(
              slivers: [
                // 고정된 높이의 앱바 (확장되지 않음)
                SliverAppBar(
                  // 앱바 높이 명시적으로 설정
                  toolbarHeight: 50, 
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  // 고정된 위치 및 날씨 정보를 표시하는 앱바
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.8),
                          AppColors.primary,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 위치 정보 (앱바 상단)
                          GestureDetector(
                            onTap: _showLocationMenu,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  location?.name ?? '위치 정보 없음',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 날씨 관련 버튼들
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // 검색 화면으로 이동
                        Navigator.pushNamed(context, AppRoutes.placeSearch);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        weatherProvider.refreshWeather();
                      },
                    ),
                  ],
                ),
                
                // 날씨 요약 정보
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildWeatherInfo(
                                  Icons.thermostat,
                                  '${weatherData.feelsLike.round()}°',
                                  '체감',
                                ),
                                _buildWeatherInfo(
                                  Icons.water_drop,
                                  '${weatherData.humidity}%',
                                  '습도',
                                ),
                                _buildWeatherInfo(
                                  Icons.air,
                                  '${weatherData.windSpeed}m/s',
                                  '바람',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '최고: ${weatherData.tempMax.round()}°',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '최저: ${weatherData.tempMin.round()}°',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 대기질 정보
                if (airQuality != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '대기질 정보',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildAirQualityInfo(
                                    '미세먼지',
                                    '${airQuality.pm10.round()} μg/m³',
                                    airQuality.pm10Level,
                                    _getAirQualityColor(airQuality.pm10Level),
                                  ),
                                  _buildAirQualityInfo(
                                    '초미세먼지',
                                    '${airQuality.pm2_5.round()} μg/m³',
                                    airQuality.pm25Level,
                                    _getAirQualityColor(airQuality.pm25Level),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // 오늘의 코디 추천
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.checkroom, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text(
                                  '오늘의 코디 추천',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getClothingRecommendation(weatherData.temp),
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(Icons.thumb_up_alt_outlined),
                                label: const Text('오늘 코디 어땠나요?'),
                                onPressed: () {
                                  // 피드백 기능 구현
                                  _showFeedbackDialog(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 시간별 예보
                if (hourlyForecast != null && hourlyForecast.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                            child: Text(
                              '시간별 예보',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 130,
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: hourlyForecast.length > 24 ? 24 : hourlyForecast.length,
                                  itemBuilder: (context, index) {
                                    final forecast = hourlyForecast[index];
                                    return Container(
                                      width: 70,
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            index == 0 ? '지금' : 
                                              '${forecast.dt.hour}시',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(height: 8),
                                          WeatherIcon(
                                            iconCode: forecast.icon,
                                            size: 24,
                                            useWhiteBackground: false,
                                            backgroundColor: null,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${forecast.temp.round()}°',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // 일별 예보
                if (dailyForecast != null && dailyForecast.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                            child: Text(
                              '7일 예보',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: List.generate(
                                  dailyForecast.length > 7 ? 7 : dailyForecast.length,
                                  (index) => _buildDailyForecastItem(dailyForecast[index], index),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // 날씨 활동 팁
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                          child: Text(
                            '오늘의 활동 추천',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: _getWeatherTips(weatherData, airQuality),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 하단 여백
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// 날씨 상세 정보 아이템 위젯
  Widget _buildWeatherInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  /// 대기질 정보 위젯
  Widget _buildAirQualityInfo(String title, String value, String grade, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            grade,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  
  /// 일별 예보 아이템 위젯
  Widget _buildDailyForecastItem(DailyForecast forecast, int index) {
    final DateTime today = DateTime.now();
    String dayText;
    
    if (index == 0) {
      dayText = '오늘';
    } else if (index == 1) {
      dayText = '내일';
    } else {
      // 요일을 한글로 변환
      final weekday = forecast.dt.weekday;
      switch (weekday) {
        case 1: dayText = '월'; break;
        case 2: dayText = '화'; break;
        case 3: dayText = '수'; break;
        case 4: dayText = '목'; break;
        case 5: dayText = '금'; break;
        case 6: dayText = '토'; break;
        case 7: dayText = '일'; break;
        default: dayText = '';
      }
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              dayText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: [
              WeatherIcon(
                iconCode: forecast.icon,
                size: 24,
                useWhiteBackground: false,
                backgroundColor: null,
              ),
              const SizedBox(width: 8),
              Text(
                '${forecast.temp.min.round()}° / ${forecast.temp.max.round()}°',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 날씨 활동 팁 아이템 위젯
  Widget _buildActivityRecommendation(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            radius: 20,
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 날씨와 대기질에 따른 활동 팁 목록 생성
  List<Widget> _getWeatherTips(WeatherData weather, AirQuality? airQuality) {
    final List<Widget> tips = [];
    final double temp = weather.temp;
    final String main = weather.main.toLowerCase();
    
    // 온도 기반 팁
    if (temp >= 30) {
      tips.add(_buildActivityRecommendation(
        Icons.thermostat, 
        '매우 더운 날씨입니다. 실외 활동 시 수분 섭취와 그늘을 찾으세요.', 
        AppColors.warning
      ));
    } else if (temp >= 25) {
      tips.add(_buildActivityRecommendation(
        Icons.wb_sunny, 
        '더운 날씨입니다. 자외선 차단제를 바르고 물을 자주 마시세요.', 
        AppColors.warning
      ));
    } else if (temp >= 20) {
      tips.add(_buildActivityRecommendation(
        Icons.directions_walk, 
        '산책하기 좋은 날씨입니다.', 
        AppColors.success
      ));
    } else if (temp >= 10) {
      tips.add(_buildActivityRecommendation(
        Icons.directions_run, 
        '야외활동하기 적합한 온도입니다.', 
        AppColors.success
      ));
    } else if (temp >= 0) {
      tips.add(_buildActivityRecommendation(
        Icons.ac_unit, 
        '쌀쌀한 날씨입니다. 따뜻한 옷차림을 준비하세요.', 
        AppColors.info
      ));
    } else {
      tips.add(_buildActivityRecommendation(
        Icons.ac_unit, 
        '매우 추운 날씨입니다. 동상에 주의하세요.', 
        AppColors.error
      ));
    }
    
    // 날씨 상태 기반 팁
    if (main.contains('rain')) {
      tips.add(_buildActivityRecommendation(
        Icons.umbrella, 
        '비 예보가 있습니다. 우산을 준비하세요.', 
        AppColors.info
      ));
    } else if (main.contains('snow')) {
      tips.add(_buildActivityRecommendation(
        Icons.snowing, 
        '눈이 내릴 예정입니다. 미끄럼에 주의하세요.', 
        AppColors.info
      ));
    } else if (main.contains('clear')) {
      tips.add(_buildActivityRecommendation(
        Icons.wb_sunny, 
        '맑은 하늘입니다. 야외 활동에 좋은 날씨입니다.', 
        AppColors.success
      ));
    } else if (main.contains('cloud')) {
      tips.add(_buildActivityRecommendation(
        Icons.cloud, 
        '구름이 있지만 비 소식은 없습니다.', 
        AppColors.info
      ));
    } else if (main.contains('mist') || main.contains('fog')) {
      tips.add(_buildActivityRecommendation(
        Icons.cloud, 
        '안개가 있습니다. 운전 시 시야에 주의하세요.', 
        AppColors.warning
      ));
    }
    
    // 대기질 기반 팁
    if (airQuality != null) {
      if (airQuality.aqi >= 4) {
        tips.add(_buildActivityRecommendation(
          Icons.masks, 
          '대기질이 좋지 않습니다. 실외 활동 시 마스크 착용을 권장합니다.', 
          AppColors.error
        ));
      } else if (airQuality.aqi >= 3) {
        tips.add(_buildActivityRecommendation(
          Icons.air, 
          '대기질이 보통 수준입니다. 민감군은 장시간 실외 활동을 자제하세요.', 
          AppColors.warning
        ));
      }
    }
    
    // 옷차림 추천 팁
    tips.add(_buildActivityRecommendation(
      Icons.checkroom, 
      _getClothingRecommendation(temp), 
      AppColors.primary
    ));
    
    return tips;
  }
  
  /// 온도에 따른 옷차림 추천
  String _getClothingRecommendation(double temp) {
    if (temp >= 28) {
      return '민소매, 반팔, 반바지, 짧은 치마, 린넨 소재의 옷이 좋습니다.';
    } else if (temp >= 23) {
      return '반팔, 얇은 셔츠, 반바지, 면바지가 적당합니다.';
    } else if (temp >= 20) {
      return '얇은 가디건이나 긴팔, 면바지, 청바지가 좋습니다.';
    } else if (temp >= 17) {
      return '얇은 니트, 맨투맨, 가디건, 청바지가 적당합니다.';
    } else if (temp >= 12) {
      return '자켓, 가디건, 간절기 야상, 청바지, 면바지가 좋습니다.';
    } else if (temp >= 9) {
      return '자켓, 트렌치코트, 니트, 청바지, 스타킹이 적당합니다.';
    } else if (temp >= 5) {
      return '코트, 가죽자켓, 히트텍, 니트, 레깅스가 좋습니다.';
    } else {
      return '패딩, 두꺼운 코트, 목도리, 장갑, 기모제품이 필요합니다.';
    }
  }
  
  /// 대기질 등급에 따른 색상 반환
  Color _getAirQualityColor(String grade) {
    switch (grade) {
      case '좋음':
        return AppColors.dustGood;
      case '보통':
        return AppColors.dustModerate;
      case '나쁨':
        return AppColors.dustBad;
      case '매우 나쁨':
        return AppColors.dustVeryBad;
      default:
        return Colors.grey;
    }
  }
  
  /// 코디 피드백 다이얼로그 표시
  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오늘의 코디 피드백'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('오늘 추천해드린 옷차림은 어떠셨나요?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFeedbackButton(context, Icons.sentiment_very_dissatisfied, '추웠어요', Colors.blue),
                _buildFeedbackButton(context, Icons.sentiment_satisfied, '적당했어요', Colors.green),
                _buildFeedbackButton(context, Icons.sentiment_very_satisfied, '더웠어요', Colors.red),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
  
  /// 피드백 버튼 위젯
  Widget _buildFeedbackButton(BuildContext context, IconData icon, String text, Color color) {
    return InkWell(
      onTap: () {
        // 피드백 저장 로직 추가 (미구현)
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('피드백 감사합니다! "$text"(으)로 기록되었습니다.')),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }
} 