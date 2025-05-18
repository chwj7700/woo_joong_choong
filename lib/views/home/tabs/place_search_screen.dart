import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/colors.dart';
import '../../../providers/weather_provider.dart';
import '../../../services/location_service.dart';
import '../../../services/app_preference_service.dart';
import '../../../routes.dart';

/// 위치 검색 화면
class PlaceSearchScreen extends StatefulWidget {
  const PlaceSearchScreen({super.key});

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AppPreferenceService _prefService = AppPreferenceService();
  List<LocationData> _searchResults = [];
  List<String> _recentSearchTerms = [];
  bool _isSearching = false;
  List<LocationData> _recentLocations = [];
  bool _isLoadingPref = true;
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  /// 앱 설정 로드
  Future<void> _loadPreferences() async {
    setState(() {
      _isLoadingPref = true;
    });
    
    await _prefService.loadPreferences();
    
    setState(() {
      _recentLocations = _prefService.recentLocations;
      _recentSearchTerms = _prefService.recentSearchTerms;
      _isLoadingPref = false;
    });
  }
  
  /// 위치 검색 수행
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
    });
    
    try {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final results = await weatherProvider.searchLocation(query);
      
      // 검색어 저장
      if (query.trim().length > 2) {
        await _prefService.addRecentSearchTerm(query.trim());
        setState(() {
          _recentSearchTerms = _prefService.recentSearchTerms;
        });
      }
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
  
  /// 위치 선택 처리
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
      
      // 최근 위치에 추가
      await _prefService.addRecentLocation(location);
      
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        Navigator.of(context).pop(); // 검색 화면 닫기
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
  
  /// 최근 검색어 선택 처리
  void _onSearchTermTap(String term) {
    _searchController.text = term;
    _performSearch(term);
  }
  
  /// 최근 검색어 삭제
  Future<void> _deleteSearchTerm(String term) async {
    await _prefService.removeRecentSearchTerm(term);
    setState(() {
      _recentSearchTerms = _prefService.recentSearchTerms;
    });
  }
  
  /// 최근 위치 삭제
  Future<void> _deleteRecentLocation(int index) async {
    await _prefService.removeRecentLocation(index);
    setState(() {
      _recentLocations = _prefService.recentLocations;
    });
  }
  
  /// 모든 최근 위치 삭제
  Future<void> _clearRecentLocations() async {
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
  
  /// 모든 최근 검색어 삭제
  Future<void> _clearRecentSearchTerms() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('최근 검색어 삭제'),
        content: const Text('모든 최근 검색어를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await _prefService.clearRecentSearchTerms();
              setState(() {
                _recentSearchTerms = [];
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
        title: const Text('위치 검색'),
        elevation: 0,
        actions: [
          // 즐겨찾기 버튼 추가
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: '즐겨찾기',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.favorites);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '도시 또는 지역명 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: (value) {
                if (value.length > 2) {
                  _performSearch(value);
                } else if (value.isEmpty) {
                  setState(() {
                    _searchResults = [];
                  });
                }
              },
              onSubmitted: _performSearch,
              textInputAction: TextInputAction.search,
            ),
          ),
          
          // 최근 검색어 (검색창이 비어있고 검색 결과가 없을 때만 표시)
          if (_searchController.text.isEmpty && 
              _searchResults.isEmpty && 
              _recentSearchTerms.isNotEmpty)
            _buildRecentSearchTerms(),
          
          // 현재 위치 버튼과 즐겨찾기로 이동 버튼을 나란히 배치
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // 현재 위치 버튼
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
                      await weatherProvider.fetchWeatherForCurrentLocation();
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.my_location, color: AppColors.primary),
                          SizedBox(width: 12),
                          Text('현재 위치 사용', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // 버튼 사이 간격
                const SizedBox(width: 16),
                
                // 즐겨찾기로 이동 버튼
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.favorites);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: AppColors.primary),
                          SizedBox(width: 12),
                          Text('즐겨찾기 보기', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 로딩 인디케이터
          if (_isSearching)
            const Center(child: CircularProgressIndicator()),
          
          // 검색 결과 또는 최근 검색 리스트
          if (_isLoadingPref)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: _searchResults.isNotEmpty
                  ? _buildSearchResults()
                  : _buildRecentLocations(),
            ),
        ],
      ),
    );
  }
  
  /// 최근 검색어 표시
  Widget _buildRecentSearchTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최근 검색어',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              if (_recentSearchTerms.isNotEmpty)
                GestureDetector(
                  onTap: _clearRecentSearchTerms,
                  child: const Text(
                    '전체 삭제',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _recentSearchTerms.length,
            itemBuilder: (context, index) {
              final term = _recentSearchTerms[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _onSearchTermTap(term),
                  child: Chip(
                    backgroundColor: Colors.grey[200],
                    label: Text(term),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _deleteSearchTerm(term),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
  
  /// 검색 결과 리스트 빌드
  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '검색 결과 (${_searchResults.length}개)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final location = _searchResults[index];
              return _buildLocationTile(location);
            },
          ),
        ),
      ],
    );
  }
  
  /// 최근 검색 위치 리스트 빌드
  Widget _buildRecentLocations() {
    if (_recentLocations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.place_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('최근 검색 위치가 없습니다.'),
            SizedBox(height: 8),
            Text(
              '위치를 검색하여 날씨 정보를 확인해보세요.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: _clearRecentLocations,
                child: const Text(
                  '전체 삭제',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentLocations.length,
            itemBuilder: (context, index) {
              final location = _recentLocations[index];
              return Dismissible(
                key: Key('location_${location.latitude}_${location.longitude}'),
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
                onDismissed: (direction) => _deleteRecentLocation(index),
                child: _buildLocationTile(location),
              );
            },
          ),
        ),
      ],
    );
  }
  
  /// 위치 타일 위젯 빌드
  Widget _buildLocationTile(LocationData location) {
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
    
    return ListTile(
      leading: const Icon(Icons.place_outlined, color: AppColors.primary),
      title: Text(
        location.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _selectLocation(location),
    );
  }
} 