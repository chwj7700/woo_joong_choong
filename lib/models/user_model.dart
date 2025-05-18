import 'package:uuid/uuid.dart';

/// 사용자 모델
class UserModel {
  final String id; // 고유 ID
  final String userId; // Firebase Auth UID
  final String email;
  String name;
  String? nickname;
  String? profileImageUrl;
  String? gender; // '남성', '여성', '기타', '응답하지 않음'
  int? birthYear;
  String? ageGroup; // '10대', '20대' 등
  double? preferredTemperature; // -3 (추위에 민감) ~ 3 (더위에 민감)
  double? sweatRate; // 0 (적음) ~ 5 (많음)
  bool? onboardingCompleted;
  bool? profileSetupCompleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  
  // 이전 버전과의 호환성을 위한 게터 및 세터
  bool get hasCompletedOnboarding => onboardingCompleted ?? false;
  bool get hasCompletedProfileSetup => profileSetupCompleted ?? false;
  double get temperaturePreference => preferredTemperature ?? 0.0;
  
  set hasCompletedOnboarding(bool value) => onboardingCompleted = value;
  set hasCompletedProfileSetup(bool value) => profileSetupCompleted = value;
  set temperaturePreference(double value) => preferredTemperature = value;

  UserModel({
    String? id,
    required this.userId,
    required this.email,
    required this.name,
    this.nickname,
    this.profileImageUrl,
    this.gender,
    this.birthYear,
    this.ageGroup,
    this.preferredTemperature = 0.0,
    this.sweatRate = 2.5,
    this.onboardingCompleted = false,
    this.profileSetupCompleted = false,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4();

  /// Firestore에서 데이터를 가져올 때 사용
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      nickname: map['nickname'],
      profileImageUrl: map['profileImageUrl'],
      gender: map['gender'],
      birthYear: map['birthYear'],
      ageGroup: map['ageGroup'],
      preferredTemperature: map['preferredTemperature']?.toDouble() ?? map['temperaturePreference']?.toDouble() ?? 0.0,
      sweatRate: map['sweatRate']?.toDouble() ?? 2.5,
      onboardingCompleted: map['onboardingCompleted'] ?? map['hasCompletedOnboarding'] ?? false,
      profileSetupCompleted: map['profileSetupCompleted'] ?? map['hasCompletedProfileSetup'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt']) 
          : DateTime.now(),
    );
  }

  /// Firestore에 데이터를 저장할 때 사용
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'email': email,
      'name': name,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'gender': gender,
      'birthYear': birthYear,
      'ageGroup': ageGroup,
      'preferredTemperature': preferredTemperature,
      'sweatRate': sweatRate,
      'onboardingCompleted': onboardingCompleted,
      'profileSetupCompleted': profileSetupCompleted,
      'hasCompletedOnboarding': onboardingCompleted, // 이전 버전과의 호환성
      'hasCompletedProfileSetup': profileSetupCompleted, // 이전 버전과의 호환성
      'temperaturePreference': preferredTemperature, // 이전 버전과의 호환성
      'createdAt': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// 사용자 정보 업데이트
  UserModel copyWith({
    String? userId,
    String? email,
    String? name,
    String? nickname,
    String? profileImageUrl,
    String? gender,
    int? birthYear,
    String? ageGroup,
    double? preferredTemperature,
    double? sweatRate,
    bool? onboardingCompleted,
    bool? profileSetupCompleted,
  }) {
    return UserModel(
      id: this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      ageGroup: ageGroup ?? this.ageGroup,
      preferredTemperature: preferredTemperature ?? this.preferredTemperature,
      sweatRate: sweatRate ?? this.sweatRate,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      profileSetupCompleted: profileSetupCompleted ?? this.profileSetupCompleted,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 