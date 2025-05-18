import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import '../../services/app_preference_service.dart';
import '../../services/location_service.dart';
import '../../utils/colors.dart';
import '../../routes.dart';
import '../../utils/constants.dart';

/// 위치 설정 화면
class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  final AppPreferenceService _prefService = AppPreferenceService();
  final LocationService _locationService = LocationService(
    apiKey: AppConstants.weatherApiKey,
  );
  
  bool _isLoading = true;
  bool _isLoadingLocation = false;
  
  // 위치 정보
  LocationData? _currentLocation;
  LocationData? _defaultLocation;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  /// 설정 로드
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    await _prefService.loadPreferences();
    
    // 기본 위치 정보 로드
    if (_prefService.defaultLocation != null) {
      final location = _prefService.defaultLocation!;
      _defaultLocation = LocationData(
        latitude: location['latitude'] as double,
        longitude: location['longitude'] as double,
        name: location['name'] as String,
        country: location['country'] as String?,
        state: location['state'] as String?,
        address: location['address'] as String?,
      );
    }
    
    setState(() {
      _isLoading = false;
    });
    
    // 현재 위치 가져오기
    if (_prefService.useCurrentLocation) {
      await _getCurrentLocation();
    }
  }
  
  /// 현재 위치 정보 가져오기
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    
    try {
      final locationData = await _locationService.getCurrentLocation();
      
      setState(() {
        _currentLocation = locationData;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('위치 정보를 가져오는 데 실패했습니다: $e')),
        );
      }
    }
  }
  
  /// 위치 검색 화면으로 이동
  Future<void> _navigateToPlaceSearch() async {
    // 위치 검색 화면으로 이동하고 결과 받기
    final result = await Navigator.pushNamed(context, AppRoutes.placeSearch);
    
    // 선택한 위치가 있으면 기본 위치로 설정
    if (result != null && result is LocationData) {
      setState(() {
        _defaultLocation = result;
      });
      
      // 설정 저장
      await _prefService.setDefaultLocation({
        'latitude': result.latitude,
        'longitude': result.longitude,
        'name': result.name,
        'country': result.country,
        'state': result.state,
        'address': result.address,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 설정'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSettingsList(),
    );
  }
  
  Widget _buildSettingsList() {
    return ChangeNotifierProvider.value(
      value: _prefService,
      child: Consumer<AppPreferenceService>(
        builder: (context, prefService, child) {
          return ListView(
            children: [
              // 현재 위치 설정 섹션
              _buildSection(
                title: '현재 위치',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '현재 위치 사용',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: prefService.useCurrentLocation,
                          onChanged: (value) async {
                            await prefService.setUseCurrentLocation(value);
                            if (value) {
                              await _getCurrentLocation();
                            }
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  if (prefService.useCurrentLocation)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _isLoadingLocation
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _currentLocation == null
                              ? const Text('현재 위치를 가져올 수 없습니다.')
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '현재 위치: ${_currentLocation!.name}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_currentLocation!.address != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(_currentLocation!.address!),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        '${_currentLocation!.state ?? ""} ${_currentLocation!.country ?? ""}'
                                            .trim(),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('새로고침'),
                                        onPressed: _getCurrentLocation,
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                ],
              ),
              
              // 기본 위치 설정 섹션
              _buildSection(
                title: '기본 위치',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '현재 위치를 사용하지 않을 때의 기본 위치입니다.',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        _defaultLocation == null
                            ? const Text('기본 위치가 설정되지 않았습니다.')
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '기본 위치: ${_defaultLocation!.name}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_defaultLocation!.address != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(_defaultLocation!.address!),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      '${_defaultLocation!.state ?? ""} ${_defaultLocation!.country ?? ""}'
                                          .trim(),
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.search),
                          label: const Text('위치 검색'),
                          onPressed: _navigateToPlaceSearch,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // 위치 접근 권한 안내 섹션
              _buildSection(
                title: '위치 접근 권한',
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '위치 권한 안내',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '날씨 정보를 제공하기 위해 위치 접근 권한이 필요합니다. 언제든지 기기 설정에서 권한을 변경할 수 있습니다.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('위치 권한 설정'),
                    subtitle: const Text('기기 설정에서 위치 접근 권한을 변경합니다'),
                    leading: const Icon(Icons.settings),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      try {
                        // 시스템 설정으로 이동
                        await _openAppSettings();
                      } catch (e) {
                        // 에러 처리
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('앱 설정을 열 수 없습니다: $e')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// 앱 설정 화면 열기
  Future<void> _openAppSettings() async {
    // permission_handler의 openAppSettings 사용
    await permission.openAppSettings();
  }
  
  /// 섹션 위젯
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
} 