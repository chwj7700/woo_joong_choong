import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_location_model.dart';

/// 즐겨찾기 위치 저장소 인터페이스
abstract class FavoriteLocationRepository {
  /// 모든 즐겨찾기 위치 조회
  Future<List<FavoriteLocation>> getAllLocations();
  
  /// ID로 특정 즐겨찾기 위치 조회
  Future<FavoriteLocation?> getLocationById(String id);
  
  /// 새 즐겨찾기 위치 추가
  Future<void> addLocation(FavoriteLocation location);
  
  /// 즐겨찾기 위치 제거
  Future<void> removeLocation(String id);
  
  /// 즐겨찾기 위치 업데이트
  Future<void> updateLocation(FavoriteLocation location);
  
  /// 즐겨찾기 위치 순서 변경
  Future<void> reorderLocations(List<FavoriteLocation> locations);
  
  /// 날씨 정보 업데이트
  Future<void> updateWeatherInfo(String id, String? weatherIcon, double? currentTemp);
}

/// 로컬 저장소를 사용한 즐겨찾기 위치 저장소 구현
class LocalFavoriteLocationRepository implements FavoriteLocationRepository {
  static const String _favoritesKey = 'favorite_locations';
  static const String _orderKey = 'favorite_locations_order';
  
  /// 모든 즐겨찾기 위치 조회
  @override
  Future<List<FavoriteLocation>> getAllLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteJson = prefs.getString(_favoritesKey);
    final orderJson = prefs.getString(_orderKey);
    
    if (favoriteJson == null) {
      return [];
    }
    
    try {
      final Map<String, dynamic> favoritesMap = jsonDecode(favoriteJson);
      final List<String> order = orderJson != null 
          ? List<String>.from(jsonDecode(orderJson))
          : favoritesMap.keys.toList();
      
      // 순서대로 정렬된 즐겨찾기 목록 반환
      final List<FavoriteLocation> result = [];
      for (final id in order) {
        if (favoritesMap.containsKey(id)) {
          result.add(FavoriteLocation.fromJson(favoritesMap[id]));
        }
      }
      
      // 순서에 없는 항목들을 추가 (잘못된 상태 처리)
      for (final id in favoritesMap.keys) {
        if (!order.contains(id)) {
          result.add(FavoriteLocation.fromJson(favoritesMap[id]));
        }
      }
      
      return result;
    } catch (e) {
      print('즐겨찾기 로딩 오류: $e');
      return [];
    }
  }
  
  /// ID로 특정 즐겨찾기 위치 조회
  @override
  Future<FavoriteLocation?> getLocationById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteJson = prefs.getString(_favoritesKey);
    
    if (favoriteJson == null) {
      return null;
    }
    
    try {
      final Map<String, dynamic> favoritesMap = jsonDecode(favoriteJson);
      if (favoritesMap.containsKey(id)) {
        return FavoriteLocation.fromJson(favoritesMap[id]);
      }
      return null;
    } catch (e) {
      print('즐겨찾기 로딩 오류: $e');
      return null;
    }
  }
  
  /// 새 즐겨찾기 위치 추가
  @override
  Future<void> addLocation(FavoriteLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteJson = prefs.getString(_favoritesKey);
    final orderJson = prefs.getString(_orderKey);
    
    Map<String, dynamic> favoritesMap = {};
    List<String> order = [];
    
    // 기존 데이터 로드
    if (favoriteJson != null) {
      favoritesMap = jsonDecode(favoriteJson);
    }
    
    if (orderJson != null) {
      order = List<String>.from(jsonDecode(orderJson));
    }
    
    // 데이터 추가
    favoritesMap[location.id] = location.toJson();
    if (!order.contains(location.id)) {
      order.add(location.id);
    }
    
    // 저장
    await prefs.setString(_favoritesKey, jsonEncode(favoritesMap));
    await prefs.setString(_orderKey, jsonEncode(order));
  }
  
  /// 즐겨찾기 위치 제거
  @override
  Future<void> removeLocation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteJson = prefs.getString(_favoritesKey);
    final orderJson = prefs.getString(_orderKey);
    
    if (favoriteJson == null) {
      return;
    }
    
    try {
      Map<String, dynamic> favoritesMap = jsonDecode(favoriteJson);
      List<String> order = orderJson != null 
          ? List<String>.from(jsonDecode(orderJson))
          : favoritesMap.keys.toList();
      
      // 데이터 및 순서에서 삭제
      favoritesMap.remove(id);
      order.remove(id);
      
      // 저장
      await prefs.setString(_favoritesKey, jsonEncode(favoritesMap));
      await prefs.setString(_orderKey, jsonEncode(order));
    } catch (e) {
      print('즐겨찾기 삭제 오류: $e');
    }
  }
  
  /// 즐겨찾기 위치 업데이트
  @override
  Future<void> updateLocation(FavoriteLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteJson = prefs.getString(_favoritesKey);
    
    if (favoriteJson == null) {
      // 존재하지 않는 경우 새로 추가
      await addLocation(location);
      return;
    }
    
    try {
      Map<String, dynamic> favoritesMap = jsonDecode(favoriteJson);
      
      // 업데이트
      favoritesMap[location.id] = location.toJson();
      
      // 저장
      await prefs.setString(_favoritesKey, jsonEncode(favoritesMap));
    } catch (e) {
      print('즐겨찾기 업데이트 오류: $e');
    }
  }
  
  /// 즐겨찾기 위치 순서 변경
  @override
  Future<void> reorderLocations(List<FavoriteLocation> locations) async {
    final prefs = await SharedPreferences.getInstance();
    
    // ID 목록 추출
    final List<String> order = locations.map((location) => location.id).toList();
    
    // 순서 저장
    await prefs.setString(_orderKey, jsonEncode(order));
  }
  
  /// 날씨 정보 업데이트
  @override
  Future<void> updateWeatherInfo(String id, String? weatherIcon, double? currentTemp) async {
    final location = await getLocationById(id);
    if (location == null) return;
    
    final updatedLocation = location.copyWith(
      weatherIcon: weatherIcon,
      currentTemp: currentTemp,
    );
    
    await updateLocation(updatedLocation);
  }
} 