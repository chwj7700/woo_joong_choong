import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/colors.dart';
import '../../../routes.dart';
import '../../../services/location_service.dart';
import '../../../services/app_preference_service.dart';
import '../../../providers/weather_provider.dart';

/// 장소 탭 화면
class PlacesTab extends StatefulWidget {
  const PlacesTab({super.key});

  @override
  State<PlacesTab> createState() => _PlacesTabState();
}

class _PlacesTabState extends State<PlacesTab> {
  final AppPreferenceService _prefService = AppPreferenceService();
  List<LocationData> _recentLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// 설정 로드
  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });
    
    await _prefService.loadPreferences();
    
    setState(() {
      _recentLocations = _prefService.recentLocations;
      _isLoading = false;
    });
  }
  
  /// 위치 선택
  void _selectLocation(LocationData location) async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      await weatherProvider.fetchWeatherForLocation(location);
      
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        
        // 홈 탭으로 이동하기 위한 함수 호출 (부모 화면에서 구현 필요)
        if (widget.key != null) {
          // Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${location.name} 날씨 정보가 업데이트되었습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('날씨 정보를 가져오는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  /// 위치 삭제
  Future<void> _deleteLocation(int index) async {
    await _prefService.removeRecentLocation(index);
    setState(() {
      _recentLocations = _prefService.recentLocations;
    });
  }

  /// 모든 최근 위치 삭제
  Future<void> _clearAllLocations() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('최근 위치 삭제'),
        content: const Text('모든 최근 위치를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await _prefService.clearRecentLocations();
              setState(() {
                _recentLocations = [];
              });
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 장소'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '위치 검색',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.placeSearch);
            },
          ),
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: '즐겨찾기',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.favorites);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.placeSearch);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_location_alt, color: Colors.white),
      ),
    );
  }

  /// 화면 본문 구성
  Widget _buildContent() {
    if (_recentLocations.isEmpty) {
      return _buildEmptyView();
    }
    
    return _buildLocationsList();
  }

  /// 빈 화면 표시
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '저장된 장소가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '자주 확인하는 장소를 추가해보세요',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.placeSearch);
            },
            icon: const Icon(Icons.search),
            label: const Text('장소 검색'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 장소 목록 표시
  Widget _buildLocationsList() {
    return Column(
      children: [
        // 최근 검색 위치 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최근 검색 위치',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_recentLocations.isNotEmpty)
                TextButton(
                  onPressed: _clearAllLocations,
                  child: const Text('전체 삭제'),
                ),
            ],
          ),
        ),
        
        // 현재 위치 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: InkWell(
            onTap: () async {
              final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
              
              // 로딩 표시
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                await weatherProvider.fetchWeatherForCurrentLocation();
                
                if (mounted) {
                  Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('현재 위치의 날씨 정보가 업데이트되었습니다.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('날씨 정보를 가져오는 중 오류가 발생했습니다: $e')),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.my_location, color: AppColors.primary),
                  SizedBox(width: 16),
                  Text(
                    '현재 위치 사용',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // 최근 검색 위치 목록
        Expanded(
          child: ListView.builder(
            itemCount: _recentLocations.length,
            itemBuilder: (context, index) {
              final location = _recentLocations[index];
              final LocationData currentLocation = location;
              
              // 주소 구성 (state 및 country 정보 포함)
              final List<String> addressParts = [];
              
              if (currentLocation.state != null && currentLocation.state!.isNotEmpty) {
                addressParts.add(currentLocation.state!);
              }
              
              if (currentLocation.country != null && currentLocation.country!.isNotEmpty) {
                addressParts.add(currentLocation.country!);
              }
              
              final String subtitle = addressParts.isEmpty 
                  ? '위도: ${currentLocation.latitude.toStringAsFixed(4)}, 경도: ${currentLocation.longitude.toStringAsFixed(4)}'
                  : addressParts.join(', ');
              
              return Dismissible(
                key: Key('location_${currentLocation.latitude}_${currentLocation.longitude}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) => _deleteLocation(index),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ListTile(
                    leading: const Icon(Icons.place, color: AppColors.primary),
                    title: Text(
                      currentLocation.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _selectLocation(currentLocation),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 