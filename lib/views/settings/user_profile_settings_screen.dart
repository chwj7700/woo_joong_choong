import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';

/// 사용자 프로필 설정 화면
class UserProfileSettingsScreen extends StatefulWidget {
  const UserProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileSettingsScreen> createState() => _UserProfileSettingsScreenState();
}

class _UserProfileSettingsScreenState extends State<UserProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 폼 필드 컨트롤러들
  final TextEditingController _nameController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedAgeGroup;
  double _temperatureSensitivity = 0.0;
  double _sweatRate = 2.5;
  
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  /// 사용자 프로필 정보 불러오기
  void _loadUserProfile() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    
    if (user != null) {
      _nameController.text = user.name;
      _selectedGender = user.gender;
      _selectedAgeGroup = user.ageGroup;
      _temperatureSensitivity = user.preferredTemperature ?? 0.0;
      _sweatRate = user.sweatRate ?? 2.5;
    }
  }
  
  /// 프로필 저장
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final result = await userProvider.updateUserProfile(
        name: _nameController.text,
        gender: _selectedGender,
        ageGroup: _selectedAgeGroup,
        preferredTemperature: _temperatureSensitivity,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 업데이트되었습니다.')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 업데이트 중 오류가 발생했습니다.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 설정'),
        elevation: 0,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                '저장',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          
          if (user == null) {
            return const Center(
              child: Text('사용자 정보를 불러올 수 없습니다.'),
            );
          }
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 기본 정보 섹션
                    _buildSectionTitle('기본 정보'),
                    _buildTextField(
                      controller: _nameController,
                      labelText: '이름',
                      hintText: '이름을 입력하세요',
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이름을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 성별 선택
                    _buildSectionTitle('성별'),
                    _buildGenderSelection(),
                    const SizedBox(height: 24),
                    
                    // 연령대 선택
                    _buildSectionTitle('연령대'),
                    _buildAgeGroupSelection(),
                    const SizedBox(height: 24),
                    
                    // 온도 민감도 설정
                    _buildSectionTitle('온도 민감도'),
                    _buildTemperatureSensitivitySlider(),
                    const SizedBox(height: 24),
                    
                    // 발한율 설정
                    _buildSectionTitle('발한율'),
                    _buildSweatRateSlider(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// 섹션 제목 위젯
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
  
  /// 텍스트 필드 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }
  
  /// 성별 선택 위젯
  Widget _buildGenderSelection() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('남성'),
          value: '남성',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('여성'),
          value: '여성',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('기타'),
          value: '기타',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('응답하지 않음'),
          value: '응답하지 않음',
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
      ],
    );
  }
  
  /// 연령대 선택 위젯
  Widget _buildAgeGroupSelection() {
    final ageGroups = ['10대', '20대', '30대', '40대', '50대', '60대 이상'];
    
    return Wrap(
      spacing: 8,
      children: ageGroups.map((age) {
        final isSelected = _selectedAgeGroup == age;
        
        return ChoiceChip(
          label: Text(age),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedAgeGroup = selected ? age : null;
            });
          },
          backgroundColor: Colors.grey[200],
          selectedColor: AppColors.primary.withOpacity(0.7),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
  
  /// 온도 민감도 슬라이더 위젯
  Widget _buildTemperatureSensitivitySlider() {
    String sensitivityText;
    
    if (_temperatureSensitivity <= -2) {
      sensitivityText = '추위에 매우 민감';
    } else if (_temperatureSensitivity <= -1) {
      sensitivityText = '추위에 약간 민감';
    } else if (_temperatureSensitivity < 1) {
      sensitivityText = '보통';
    } else if (_temperatureSensitivity < 2) {
      sensitivityText = '더위에 약간 민감';
    } else {
      sensitivityText = '더위에 매우 민감';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추위/더위 민감도: $sensitivityText',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('추위에 민감', style: TextStyle(fontSize: 12)),
            Expanded(
              child: Slider(
                value: _temperatureSensitivity,
                min: -3,
                max: 3,
                divisions: 12,
                onChanged: (value) {
                  setState(() {
                    _temperatureSensitivity = value;
                  });
                },
              ),
            ),
            const Text('더위에 민감', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
  
  /// 발한율 슬라이더 위젯
  Widget _buildSweatRateSlider() {
    String sweatRateText;
    
    if (_sweatRate <= 1) {
      sweatRateText = '매우 적음';
    } else if (_sweatRate <= 2) {
      sweatRateText = '적음';
    } else if (_sweatRate <= 3) {
      sweatRateText = '보통';
    } else if (_sweatRate <= 4) {
      sweatRateText = '많음';
    } else {
      sweatRateText = '매우 많음';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '땀 분비량: $sweatRateText',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('적음', style: TextStyle(fontSize: 12)),
            Expanded(
              child: Slider(
                value: _sweatRate,
                min: 0,
                max: 5,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    _sweatRate = value;
                  });
                },
              ),
            ),
            const Text('많음', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
} 