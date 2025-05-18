import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/favorite_location_model.dart';
import '../../services/location_service.dart';
import '../../providers/favorite_locations_provider.dart';

/// 즐겨찾기 추가 화면
class AddFavoriteScreen extends StatefulWidget {
  const AddFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<AddFavoriteScreen> createState() => _AddFavoriteScreenState();
}

class _AddFavoriteScreenState extends State<AddFavoriteScreen> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isSearching = false;
  bool _isLoading = false;
  List<LocationData> _searchResults = [];
  LocationData? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // 검색어 변경 시 호출
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _searchLocation(query);
  }

  // 장소 검색 실행
  Future<void> _searchLocation(String query) async {
    if (query.length < 2) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Provider.of<LocationService>(context, listen: false)
          .searchLocation(query);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('검색 중 오류가 발생했습니다: $e'),
        ),
      );
    }
  }

  // 현재 위치 추가
  Future<void> _addCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final location = await Provider.of<LocationService>(context, listen: false)
          .getCurrentLocation();
      
      setState(() {
        _selectedLocation = location;
        _nameController.text = location.name;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('현재 위치를 가져오는 중 오류가 발생했습니다: $e'),
        ),
      );
    }
  }

  // 선택한 위치를 즐겨찾기에 추가
  Future<void> _saveFavorite() async {
    if (_selectedLocation == null ||
        !_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    
    final favorite = FavoriteLocation(
      name: name,
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      address: _selectedLocation!.address,
    );

    try {
      await Provider.of<FavoriteLocationsProvider>(context, listen: false)
          .addLocation(favorite);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('즐겨찾기에 추가되었습니다'),
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 중 오류가 발생했습니다: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾기 추가'),
      ),
      body: Column(
        children: [
          // 검색 부분
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '장소 검색',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: const Text('현재 위치 사용'),
                  onPressed: _addCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),
              ],
            ),
          ),

          // 로딩 표시
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),

          // 검색 결과 표시
          if (_isSearching && _searchResults.isNotEmpty && _selectedLocation == null)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final location = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(location.name),
                    subtitle: location.address != null
                        ? Text(
                            location.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLocation = location;
                        _nameController.text = location.name;
                        _isSearching = false;
                      });
                    },
                  );
                },
              ),
            ),

          // 선택한 위치가 있는 경우 이름 설정 및 저장 폼
          if (_selectedLocation != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '선택한 위치',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(_selectedLocation!.name),
                        subtitle: _selectedLocation!.address != null
                            ? Text(_selectedLocation!.address!)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '표시 이름',
                        hintText: '이 위치를 표시할 이름을 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이름을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveFavorite,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('즐겨찾기에 추가하기'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedLocation = null;
                          _nameController.clear();
                        });
                      },
                      child: const Text('다시 검색하기'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 