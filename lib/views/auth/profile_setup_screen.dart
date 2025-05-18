import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/colors.dart';
import '../../routes.dart';

/// 사용자 프로필 설정 화면
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  double _temperaturePreference = 0; // 0: 평균, -3: 추위 선호, +3: 더위 선호
  int? _selectedAgeGroup;
  String? _selectedGender;

  final List<String> _genderOptions = ['남성', '여성', '기타', '응답하지 않음'];
  final List<String> _ageGroupOptions = ['10대', '20대', '30대', '40대', '50대 이상'];

  @override
  void initState() {
    super.initState();
    
    // 기존 사용자 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      
      if (user != null) {
        if (user.nickname != null && user.nickname!.isNotEmpty) {
          _nicknameController.text = user.nickname!;
        } else if (user.name.isNotEmpty) {
          _nicknameController.text = user.name; // 이름을 닉네임 기본값으로 사용
        }
        
        if (user.gender != null) {
          setState(() {
            _selectedGender = user.gender;
          });
        }
        
        if (user.ageGroup != null) {
          setState(() {
            // 인덱스 찾기
            _selectedAgeGroup = _ageGroupOptions.indexOf(user.ageGroup!);
            if (_selectedAgeGroup == -1) {
              _selectedAgeGroup = null; // 목록에 없으면 null로 설정
            }
          });
        }
        
        if (user.preferredTemperature != null) {
          setState(() {
            _temperaturePreference = user.preferredTemperature!;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  /// 프로필 설정 저장
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    String? selectedAgeGroupText;
    if (_selectedAgeGroup != null && _selectedAgeGroup! >= 0 && _selectedAgeGroup! < _ageGroupOptions.length) {
      selectedAgeGroupText = _ageGroupOptions[_selectedAgeGroup!];
    }

    try {
      final success = await userProvider.updateUserProfile(
        name: _nicknameController.text.trim(),
        gender: _selectedGender,
        ageGroup: selectedAgeGroupText,
        preferredTemperature: _temperaturePreference,
      );
      
      if (!mounted) return;
      
      if (success) {
        // 프로필 설정 완료 상태 업데이트
        await userProvider.setProfileSetupCompleted(true);
        
        // 홈 화면으로 이동
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        // 오류 메시지 표시
        if (userProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('프로필 저장 실패: ${userProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 예상치 못한 오류 처리
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('프로필 저장 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 설정'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '맞춤형 날씨 정보를 위한 정보를 설정해주세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 프로필 이미지 선택
                  Center(
                    child: Stack(
                      children: [
                        // 프로필 이미지 영역
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                        
                        // 이미지 추가 버튼
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.add_a_photo,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // 이미지 선택 다이얼로그 표시 (미구현)
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 닉네임 입력 필드
                  TextFormField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: '닉네임',
                      hintText: '다른 사용자에게 표시될 이름',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '닉네임을 입력해주세요';
                      }
                      if (value.length < 2) {
                        return '닉네임은 최소 2자 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 성별 선택
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '성별 (선택)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: _genderOptions.map((gender) {
                          return ChoiceChip(
                            label: Text(gender),
                            selected: _selectedGender == gender,
                            onSelected: (selected) {
                              setState(() {
                                _selectedGender = selected ? gender : null;
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: _selectedGender == gender 
                                  ? AppColors.primary 
                                  : Colors.black,
                              fontWeight: _selectedGender == gender
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 연령대 선택
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '연령대 (선택)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: List.generate(_ageGroupOptions.length, (index) {
                          final ageGroup = _ageGroupOptions[index];
                          return ChoiceChip(
                            label: Text(ageGroup),
                            selected: _selectedAgeGroup == index,
                            onSelected: (selected) {
                              setState(() {
                                _selectedAgeGroup = selected ? index : null;
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: _selectedAgeGroup == index 
                                  ? AppColors.primary 
                                  : Colors.black,
                              fontWeight: _selectedAgeGroup == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 온도 선호도 설정
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '온도 선호도',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '같은 온도여도 사람마다 느끼는 정도가 다릅니다. 본인의 체감 온도를 설정해주세요.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('추위를 더 잘 타요'),
                          Text('평균'),
                          Text('더위를 더 잘 타요'),
                        ],
                      ),
                      
                      Slider(
                        value: _temperaturePreference,
                        min: -3,
                        max: 3,
                        divisions: 6,
                        activeColor: AppColors.primary,
                        inactiveColor: Colors.grey[300],
                        onChanged: (value) {
                          setState(() {
                            _temperaturePreference = value;
                          });
                        },
                      ),
                      
                      // 현재 선택된 값 표시
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getTemperaturePreferenceText(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 저장 버튼
                  ElevatedButton(
                    onPressed: userProvider.isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    ),
                    child: userProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            '설정 완료',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 건너뛰기 버튼
                  TextButton(
                    onPressed: userProvider.isLoading ? null : () {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    },
                    child: const Text(
                      '건너뛰기',
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// 온도 선호도 텍스트 가져오기
  String _getTemperaturePreferenceText() {
    if (_temperaturePreference < -2) {
      return '매우 추위에 민감';
    } else if (_temperaturePreference < -1) {
      return '추위에 민감';
    } else if (_temperaturePreference < 0) {
      return '약간 추위에 민감';
    } else if (_temperaturePreference == 0) {
      return '평균적인 체감';
    } else if (_temperaturePreference <= 1) {
      return '약간 더위에 민감';
    } else if (_temperaturePreference <= 2) {
      return '더위에 민감';
    } else {
      return '매우 더위에 민감';
    }
  }
} 