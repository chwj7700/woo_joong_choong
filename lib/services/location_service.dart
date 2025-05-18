import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import '../utils/constants.dart';
import '../utils/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import '../views/favorites/favorite_detail_screen.dart';

/// 위치 정보 모델
class LocationData {
  final double latitude;
  final double longitude;
  final String name;
  final String? country;
  final String? state;
  final DateTime timestamp;
  final String? address;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.name,
    this.country,
    this.state,
    DateTime? timestamp,
    this.address,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// JSON 데이터로 변환
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'country': country,
      'state': state,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'address': address,
    };
  }
  
  /// JSON 데이터에서 LocationData 객체 생성
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      name: json['name'] as String,
      country: json['country'] as String?,
      state: json['state'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      address: json['address'] as String?,
    );
  }
  
  /// 문자열 표현
  @override
  String toString() {
    return '$name${state != null ? ', $state' : ''}${country != null ? ', $country' : ''}';
  }
}

/// 위치 서비스
class LocationService {
  final String apiKey;
  final http.Client _client;
  
  // 마지막으로 조회한 위치
  LocationData? _lastKnownLocation;
  
  LocationService({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();
  
  /// 현재 위치 정보 가져오기
  Future<LocationData> getCurrentLocation() async {
    // 위치 권한 확인
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requestPermission = await Geolocator.requestPermission();
      if (requestPermission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 활성화해 주세요.');
    }
    
    try {
      // 현재 위치 조회
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // 위도/경도로 주소 조회
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        // 위치 이름 생성
        final name = _getLocationName(placemark);
        
        // 주소 생성
        final address = _getLocationAddress(placemark);
        
        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          name: name,
          country: placemark.isoCountryCode ?? 'KR',
          state: placemark.administrativeArea,
          address: address,
        );
      }
      
      // 주소 정보가 없는 경우
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        name: '현재 위치',
        country: 'KR',
        address: null,
      );
    } catch (e) {
      throw Exception('현재 위치를 가져오는 중 오류가 발생했습니다: $e');
    }
  }
  
  /// 마지막으로 알려진 위치 정보 반환
  LocationData? getLastKnownLocation() {
    return _lastKnownLocation;
  }
  
  /// 위치 권한 확인
  Future<bool> _checkLocationPermission() async {
    // 위치 서비스 활성화 여부 확인
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    // 위치 권한 상태 확인
    var permission = await Geolocator.checkPermission();
    
    // 권한이 없는 경우 권한 요청
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    // 영구적으로 거부된 경우
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }
  
  /// 역지오코딩 (좌표 → 주소)
  Future<LocationData> reverseGeocode(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        '${WeatherApiConstants.geoUrl}/reverse?lat=$latitude&lon=$longitude&limit=1&appid=$apiKey'
      );
      
      final response = await _client.get(url).timeout(
        Duration(seconds: AppConstants.locationTimeoutSeconds),
      );
      
      if (response.statusCode != 200) {
        return LocationData(
          latitude: latitude,
          longitude: longitude,
          name: '알 수 없는 위치',
          address: null,
        );
      }
      
      final List<dynamic> data = jsonDecode(response.body);
      
      if (data.isEmpty) {
        return LocationData(
          latitude: latitude,
          longitude: longitude,
          name: '알 수 없는 위치',
          address: null,
        );
      }
      
      final locationData = data[0];
      final name = locationData['name'] as String? ?? '알 수 없는 위치';
      final country = locationData['country'] as String?;
      final state = locationData['state'] as String?;
      
      return LocationData(
        latitude: latitude,
        longitude: longitude,
        name: name,
        country: country,
        state: state,
        address: null,
      );
    } catch (e) {
      // 에러 발생 시 기본 위치 데이터 반환
      return LocationData(
        latitude: latitude,
        longitude: longitude,
        name: '알 수 없는 위치',
        address: null,
      );
    }
  }
  
  /// 지오코딩 (주소/지명 → 좌표)
  Future<List<LocationData>> searchLocation(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    try {
      // 주소 검색 시도 (더 정확한 결과)
      List<LocationData> results = [];
      
      try {
        final List<Location> locations = await locationFromAddress(query);
        
        if (locations.isNotEmpty) {
          for (final location in locations) {
            try {
              // 위도/경도로 주소 상세 정보 조회
              final List<Placemark> placemarks = await placemarkFromCoordinates(
                location.latitude,
                location.longitude,
              );
              
              if (placemarks.isNotEmpty) {
                final placemark = placemarks.first;
                
                // 위치 이름 생성
                final name = _getLocationName(placemark);
                
                // 주소 생성
                final address = _getLocationAddress(placemark);
                
                results.add(LocationData(
                  latitude: location.latitude,
                  longitude: location.longitude,
                  name: name,
                  country: placemark.isoCountryCode ?? 'KR',
                  state: placemark.administrativeArea,
                  address: address,
                ));
              }
            } catch (e) {
              if (kDebugMode) {
                print('위치 정보 변환 중 오류: $e');
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('지오코딩 검색 오류: $e');
        }
      }
      
      // 결과가 없거나 적은 경우 Open Weather Map API로 추가 검색
      if (results.isEmpty || results.length < 3) {
        try {
          final additionalResults = await _searchLocationByName(query);
          
          // 중복 제거하며 합치기
          for (final location in additionalResults) {
            bool isDuplicate = false;
            
            for (final existingLocation in results) {
              // 위도/경도 소수점 2자리까지 비교하여 거의 동일한 위치인지 확인
              if ((existingLocation.latitude - location.latitude).abs() < 0.01 &&
                  (existingLocation.longitude - location.longitude).abs() < 0.01) {
                isDuplicate = true;
                break;
              }
            }
            
            if (!isDuplicate) {
              results.add(location);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Open Weather API 위치 검색 오류: $e');
          }
        }
      }
      
      // 최대 10개 결과로 제한
      if (results.length > 10) {
        results = results.sublist(0, 10);
      }
      
      return results;
    } catch (e) {
      throw Exception('위치 검색 중 오류가 발생했습니다: $e');
    }
  }
  
  /// 위치명으로 Open Weather Map API 검색
  Future<List<LocationData>> _searchLocationByName(String query) async {
    try {
      final url = Uri.parse(
        '${WeatherApiConstants.geoUrl}${WeatherApiConstants.geocoding}?q=$query&limit=5&appid=$apiKey'
      );
      
      final response = await _client.get(url).timeout(
        Duration(seconds: AppConstants.locationTimeoutSeconds),
      );
      
      if (response.statusCode != 200) {
        return [];
      }
      
      final List<dynamic> data = jsonDecode(response.body);
      
      if (data.isEmpty) {
        return [];
      }
      
      final List<LocationData> results = [];
      
      for (final item in data) {
        final double lat = (item['lat'] as num).toDouble();
        final double lon = (item['lon'] as num).toDouble();
        final String name = item['name'] as String;
        final String country = item['country'] as String;
        final String? state = item['state'] as String?;
        
        results.add(LocationData(
          latitude: lat,
          longitude: lon,
          name: name,
          country: country,
          state: state,
          address: state != null ? '$name, $state, $country' : '$name, $country',
        ));
      }
      
      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Open Weather Map API 위치 검색 오류: $e');
      }
      return [];
    }
  }
  
  /// 위치 정보 캐싱
  Future<void> _cacheLocationData(LocationData location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_location', jsonEncode(location.toJson()));
    } catch (e) {
      // 캐싱 실패는 치명적이지 않으므로 무시
      print('위치 정보 캐싱 실패: $e');
    }
  }
  
  /// 캐시된 위치 정보 가져오기
  Future<LocationData?> _getCachedLocationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString('cached_location');
      
      if (locationJson == null) {
        return null;
      }
      
      final locationData = LocationData.fromJson(jsonDecode(locationJson));
      
      // 캐시된 데이터가 24시간 이상 지난 경우 null 반환
      final now = DateTime.now();
      final difference = now.difference(locationData.timestamp);
      
      if (difference.inHours > 24) {
        return null;
      }
      
      return locationData;
    } catch (e) {
      return null;
    }
  }
  
  /// 기본 위치 정보 반환 (서울)
  LocationData getDefaultLocation() {
    return LocationData(
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
      name: '서울',
      country: '대한민국',
      address: '서울특별시',
    );
  }
  
  /// 위치 이름 생성
  String _getLocationName(Placemark placemark) {
    // 지역 이름 우선순위: 지역명 > 하위 행정구역 > 행정구역 > 국가
    String name = placemark.name ?? '';
    
    if (name.isEmpty || name == 'Unnamed Road') {
      if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
        name = placemark.subLocality!;
      } else if (placemark.locality != null && placemark.locality!.isNotEmpty) {
        name = placemark.locality!;
      } else if (placemark.subAdministrativeArea != null && 
                placemark.subAdministrativeArea!.isNotEmpty) {
        name = placemark.subAdministrativeArea!;
      } else if (placemark.administrativeArea != null && 
                placemark.administrativeArea!.isNotEmpty) {
        name = placemark.administrativeArea!;
      } else {
        name = placemark.country ?? '알 수 없는 위치';
      }
    }
    
    return name;
  }
  
  /// 주소 생성
  String? _getLocationAddress(Placemark placemark) {
    // 주소 구성 요소
    final components = <String>[];
    
    // 국가 (해외인 경우)
    if (placemark.isoCountryCode != 'KR' && 
        placemark.country != null && 
        placemark.country!.isNotEmpty) {
      components.add(placemark.country!);
    }
    
    // 시/도
    if (placemark.administrativeArea != null && 
        placemark.administrativeArea!.isNotEmpty) {
      components.add(placemark.administrativeArea!);
    }
    
    // 군/구
    if (placemark.subAdministrativeArea != null && 
        placemark.subAdministrativeArea!.isNotEmpty) {
      components.add(placemark.subAdministrativeArea!);
    }
    
    // 시/군/구
    if (placemark.locality != null && 
        placemark.locality!.isNotEmpty) {
      components.add(placemark.locality!);
    }
    
    // 읍/면/동
    if (placemark.subLocality != null && 
        placemark.subLocality!.isNotEmpty) {
      components.add(placemark.subLocality!);
    }
    
    // 번지
    if (placemark.thoroughfare != null && 
        placemark.thoroughfare!.isNotEmpty) {
      components.add(placemark.thoroughfare!);
      
      if (placemark.subThoroughfare != null && 
          placemark.subThoroughfare!.isNotEmpty) {
        components.add(placemark.subThoroughfare!);
      }
    }
    
    if (components.isEmpty) {
      return null;
    }
    
    return components.join(' ');
  }

  /// 앱 설정 화면 열기
  Future<bool> openAppSettings() async {
    return await permission.openAppSettings();
  }
}

 