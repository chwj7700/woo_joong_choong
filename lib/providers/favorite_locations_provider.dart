import 'package:flutter/foundation.dart';
import '../models/favorite_location_model.dart';
import '../services/favorite_location_repository.dart';
import '../services/weather_service.dart';
import 'package:collection/collection.dart';

/// 즐겨찾기 위치 상태 관리 Provider
class FavoriteLocationsProvider with ChangeNotifier {
  // 저장소
  final FavoriteLocationRepository _repository;
  final WeatherService? _weatherService;
  
  // 상태
  List<FavoriteLocation> _locations = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // 생성자
  FavoriteLocationsProvider({
    required FavoriteLocationRepository repository,
    WeatherService? weatherService,
  })  : _repository = repository,
        _weatherService = weatherService {
    // 초기 데이터 로드
    loadLocations();
  }
  
  // Getters
  List<FavoriteLocation> get locations => List.unmodifiable(_locations);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLocations => _locations.isNotEmpty;

  /// 모든 즐겨찾기 위치 로드
  Future<void> loadLocations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _locations = await _repository.getAllLocations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '즐겨찾기 정보를 불러오는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }
  
  /// 즐겨찾기 위치 추가
  Future<void> addLocation(FavoriteLocation location) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repository.addLocation(location);
      await loadLocations(); // 전체 목록 다시 로드
    } catch (e) {
      _isLoading = false;
      _errorMessage = '즐겨찾기 추가 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }
  
  /// 즐겨찾기 위치 삭제
  Future<void> removeLocation(String id) async {
    try {
      await _repository.removeLocation(id);
      _locations.removeWhere((location) => location.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = '즐겨찾기 삭제 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }
  
  /// 즐겨찾기 위치 업데이트
  Future<void> updateLocation(FavoriteLocation location) async {
    try {
      await _repository.updateLocation(location);
      
      final index = _locations.indexWhere((item) => item.id == location.id);
      if (index != -1) {
        _locations[index] = location;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '즐겨찾기 업데이트 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }
  
  /// 즐겨찾기 순서 변경
  Future<void> reorderLocations(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _locations.length || 
        newIndex < 0 || newIndex >= _locations.length) {
      return;
    }
    
    // 업데이트 할 목록
    final List<FavoriteLocation> reorderedLocations = List.from(_locations);
    
    // Reorderable ListView에서 변경하는 경우 newIndex 조정
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    // 항목 이동
    final FavoriteLocation item = reorderedLocations.removeAt(oldIndex);
    reorderedLocations.insert(newIndex, item);
    
    // 임시 업데이트 (UI 즉시 반영)
    _locations = reorderedLocations;
    notifyListeners();
    
    // 저장소 업데이트
    try {
      await _repository.reorderLocations(reorderedLocations);
    } catch (e) {
      // 오류 시 원래 목록으로 복원
      await loadLocations();
      _errorMessage = '순서 변경 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }
  
  /// 모든 즐겨찾기 날씨 정보 갱신
  Future<void> refreshWeatherInfo() async {
    if (_weatherService == null || _locations.isEmpty) {
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // 각 위치별 날씨 정보 동시에 가져오기
      final futures = _locations.map((location) async {
        try {
          final weatherData = await _weatherService!.getCurrentWeather(
            location.latitude, 
            location.longitude,
          );
          
          if (weatherData != null) {
            await _repository.updateWeatherInfo(
              location.id,
              weatherData.icon,
              weatherData.temp,
            );
          }
        } catch (e) {
          print('위치 ${location.name}의 날씨 정보 업데이트 실패: $e');
        }
      }).toList();
      
      // 모든 작업 완료 대기
      await Future.wait(futures);
      
      // 데이터 다시 로드
      await loadLocations();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '날씨 정보 갱신 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }
  
  /// 특정 위치의 날씨 정보 업데이트
  Future<void> updateWeatherInfo(String id, String? weatherIcon, double? currentTemp) async {
    try {
      await _repository.updateWeatherInfo(id, weatherIcon, currentTemp);
      
      final index = _locations.indexWhere((item) => item.id == id);
      if (index != -1) {
        _locations[index] = _locations[index].copyWith(
          weatherIcon: weatherIcon,
          currentTemp: currentTemp,
        );
        notifyListeners();
      }
    } catch (e) {
      print('날씨 정보 업데이트 실패: $e');
    }
  }
  
  /// ID로 즐겨찾기 위치 조회
  FavoriteLocation? getLocationById(String id) {
    return _locations.firstWhereOrNull((location) => location.id == id);
  }
} 