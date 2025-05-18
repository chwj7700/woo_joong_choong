// Firebase 패키지 import
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// 사용자 프로필 관리 서비스
class UserService {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  final firestore.CollectionReference _usersCollection = firestore.FirebaseFirestore.instance.collection('users');
  
  // Firebase 사용 여부
  final bool _firebaseEnabled;
  
  UserService({bool? firebaseEnabled})
      : _firebaseEnabled = firebaseEnabled ?? false;
  
  /// 사용자 프로필 저장 (Firestore)
  Future<void> saveUserProfile(UserModel user) async {
    try {
      if (!_firebaseEnabled) {
        // Firebase 비활성화 상태 - 로컬에만 저장
        await saveUserPreferences(user);
        return;
      }
      
      await _usersCollection.doc(user.userId).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }
  
  /// 사용자 프로필 업데이트 (Firestore)
  Future<void> updateUserProfile(UserModel user) async {
    try {
      if (!_firebaseEnabled) {
        // Firebase 비활성화 상태 - 로컬에만 저장
        await saveUserPreferences(user);
        return;
      }
      
      await _usersCollection.doc(user.userId).update(user.toMap());
    } catch (e) {
      rethrow;
    }
  }
  
  /// 사용자 프로필 가져오기 (Firestore)
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      if (!_firebaseEnabled) {
        // Firebase 비활성화 상태 - 로컬에서 불러오기
        return await getUserPreferences();
      }
      
      final doc = await _usersCollection.doc(userId).get();
      
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  /// 사용자 설정 저장 (로컬 디바이스)
  Future<void> saveUserPreferences(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('user_id', user.userId);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_gender', user.gender ?? '');
      await prefs.setString('user_age_group', user.ageGroup ?? '');
      await prefs.setDouble('user_preferred_temp', user.preferredTemperature ?? 22.0);
      await prefs.setBool('onboarding_completed', user.onboardingCompleted ?? false);
      await prefs.setBool('profile_setup_completed', user.profileSetupCompleted ?? false);
      
      if (user.profileImageUrl != null) {
        await prefs.setString('user_profile_image', user.profileImageUrl!);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// 사용자 설정 불러오기 (로컬 디바이스)
  Future<UserModel?> getUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final userId = prefs.getString('user_id');
      final email = prefs.getString('user_email');
      final name = prefs.getString('user_name');
      
      if (userId == null || email == null) {
        return null;
      }
      
      return UserModel(
        userId: userId,
        email: email,
        name: name ?? '',
        gender: prefs.getString('user_gender'),
        ageGroup: prefs.getString('user_age_group'),
        preferredTemperature: prefs.getDouble('user_preferred_temp'),
        profileImageUrl: prefs.getString('user_profile_image'),
        onboardingCompleted: prefs.getBool('onboarding_completed'),
        profileSetupCompleted: prefs.getBool('profile_setup_completed'),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// 사용자 설정 초기화 (로컬 디바이스)
  Future<void> clearUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_gender');
      await prefs.remove('user_age_group');
      await prefs.remove('user_preferred_temp');
      await prefs.remove('user_profile_image');
      await prefs.remove('onboarding_completed');
      await prefs.remove('profile_setup_completed');
    } catch (e) {
      rethrow;
    }
  }
  
  /// 사용자 ID 가져오기 (로컬)
  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    } catch (e) {
      return null;
    }
  }
  
  /// 사용자 이메일 가져오기 (로컬)
  Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_email');
    } catch (e) {
      return null;
    }
  }
  
  /// 사용자 이름 가져오기 (로컬)
  Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_name');
    } catch (e) {
      return null;
    }
  }
} 