import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// 사용자 상태 관리 Provider
class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  UserModel? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  bool _isOnboardingCompleted = false;
  bool _isProfileSetupCompleted = false;
  bool _firebaseEnabled = false;
  
  // 게터
  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isProfileSetupCompleted => _isProfileSetupCompleted;
  bool get firebaseEnabled => _firebaseEnabled;
  
  UserProvider({bool firebaseEnabled = false}) {
    _firebaseEnabled = firebaseEnabled;
    _init();
  }
  
  /// 초기화 - 로컬 저장소에서 사용자 상태 및 설정 로드
  Future<void> _init() async {
    _setLoading(true);
    
    try {
      // Firebase 사용 가능하면 현재 로그인 상태 확인
      if (_firebaseEnabled && _authService.currentUser != null) {
        await _loadOrCreateUserProfile(_authService.currentUser!);
      } else {
        // 로컬 저장소에서 사용자 기본 정보 확인
        final user = await _userService.getUserPreferences();
        
        if (user != null) {
          _user = user;
          _isLoggedIn = true;
          _isOnboardingCompleted = user.onboardingCompleted ?? false;
          _isProfileSetupCompleted = user.profileSetupCompleted ?? false;
        } else {
          _isLoggedIn = false;
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  /// 이메일/비밀번호로 회원가입
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      // Firebase 인증
      final authResult = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      
      if (authResult != AuthResultStatus.successful) {
        _setError(_authService.getErrorMessage(authResult));
        return false;
      }
      
      // 테스트 모드에서는 임의의 UserModel 생성
      if (!_firebaseEnabled) {
        final newUser = UserModel(
          userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: name,
          onboardingCompleted: false,
          profileSetupCompleted: false,
        );
        
        _user = newUser;
        await _userService.saveUserPreferences(newUser);
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      
      // 사용자 Firebase 정보 확인 및 저장
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        await _loadOrCreateUserProfile(firebaseUser);
        return true;
      } else {
        _setError('사용자 프로필 생성에 실패했습니다.');
        return false;
      }
    } catch (e) {
      _setError('회원가입 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 이메일/비밀번호로 로그인
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      // Firebase 인증
      final authResult = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (authResult != AuthResultStatus.successful) {
        _setError(_authService.getErrorMessage(authResult));
        return false;
      }
      
      // 테스트 모드에서는 임의의 UserModel 생성
      if (!_firebaseEnabled) {
        // SharedPreferences에서 사용자 정보를 확인하거나, 기본값 생성
        final prefs = await _userService.getUserPreferences();
        if (prefs != null) {
          _user = prefs;
        } else {
          _user = UserModel(
            userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            name: '테스트 사용자',
            onboardingCompleted: true,
            profileSetupCompleted: true,
          );
          await _userService.saveUserPreferences(_user!);
        }
        
        _isLoggedIn = true;
        _isOnboardingCompleted = _user?.onboardingCompleted ?? true;
        _isProfileSetupCompleted = _user?.profileSetupCompleted ?? true;
        notifyListeners();
        return true;
      }
      
      // 사용자 Firebase 정보 확인 및 저장
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        await _loadOrCreateUserProfile(firebaseUser);
        return true;
      } else {
        _setError('사용자 프로필 불러오기에 실패했습니다.');
        return false;
      }
    } catch (e) {
      _setError('로그인 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Google 로그인
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;
    
    try {
      // Firebase 인증
      final authResult = await _authService.signInWithGoogle();
      
      if (authResult != AuthResultStatus.successful) {
        _setError(_authService.getErrorMessage(authResult));
        return false;
      }
      
      // 테스트 모드에서는 임의의 UserModel 생성
      if (!_firebaseEnabled) {
        _user = UserModel(
          userId: 'google_${DateTime.now().millisecondsSinceEpoch}',
          email: 'google_user@example.com',
          name: 'Google 테스트 사용자',
          profileImageUrl: 'https://via.placeholder.com/150',
          onboardingCompleted: true,
          profileSetupCompleted: false,
        );
        
        await _userService.saveUserPreferences(_user!);
        _isLoggedIn = true;
        _isOnboardingCompleted = true;
        _isProfileSetupCompleted = false;
        notifyListeners();
        return true;
      }
      
      // 사용자 Firebase 정보 확인 및 저장
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        await _loadOrCreateUserProfile(firebaseUser);
        return true;
      } else {
        _setError('사용자 프로필 불러오기에 실패했습니다.');
        return false;
      }
    } catch (e) {
      _setError('Google 로그인 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 로그아웃
  Future<bool> signOut() async {
    _setLoading(true);
    
    try {
      await _authService.signOut();
      await _userService.clearUserPreferences();
      
      _user = null;
      _isLoggedIn = false;
      _isOnboardingCompleted = false;
      _isProfileSetupCompleted = false;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('로그아웃 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 비밀번호 재설정 이메일 전송
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _error = null;
    
    try {
      final authResult = await _authService.sendPasswordResetEmail(email);
      
      if (authResult != AuthResultStatus.successful) {
        _setError(_authService.getErrorMessage(authResult));
        return false;
      }
      
      return true;
    } catch (e) {
      _setError('비밀번호 재설정 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 온보딩 완료 상태 설정
  Future<void> setOnboardingCompleted(bool value) async {
    _isOnboardingCompleted = value;
    
    if (_user != null) {
      _user = _user!.copyWith(onboardingCompleted: value);
      
      if (!_firebaseEnabled) {
        await _userService.saveUserPreferences(_user!);
      } else {
        await _userService.updateUserProfile(_user!);
      }
    }
    
    notifyListeners();
  }
  
  /// 프로필 설정 완료 상태 설정
  Future<void> setProfileSetupCompleted(bool value) async {
    _isProfileSetupCompleted = value;
    
    if (_user != null) {
      _user = _user!.copyWith(profileSetupCompleted: value);
      
      if (!_firebaseEnabled) {
        await _userService.saveUserPreferences(_user!);
      } else {
        await _userService.updateUserProfile(_user!);
      }
    }
    
    notifyListeners();
  }
  
  /// 프로필 정보 업데이트
  Future<bool> updateUserProfile({
    String? name,
    String? gender,
    String? ageGroup,
    double? preferredTemperature,
    String? profileImageUrl,
  }) async {
    _setLoading(true);
    
    try {
      if (_user != null) {
        _user = _user!.copyWith(
          name: name ?? _user!.name,
          gender: gender ?? _user!.gender,
          ageGroup: ageGroup ?? _user!.ageGroup,
          preferredTemperature: preferredTemperature ?? _user!.preferredTemperature,
          profileImageUrl: profileImageUrl ?? _user!.profileImageUrl,
        );
        
        if (!_firebaseEnabled) {
          await _userService.saveUserPreferences(_user!);
        } else {
          await _userService.updateUserProfile(_user!);
        }
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('프로필 업데이트 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Firebase User 정보에서 UserModel 생성 및 저장
  Future<void> _loadOrCreateUserProfile(firebase.User firebaseUser) async {
    try {
      // Firestore에서 사용자 정보 확인
      final userFromDb = await _userService.getUserProfile(firebaseUser.uid);
      
      if (userFromDb != null) {
        // 기존 사용자 정보 로드
        _user = userFromDb;
        _isOnboardingCompleted = userFromDb.onboardingCompleted ?? false;
        _isProfileSetupCompleted = userFromDb.profileSetupCompleted ?? false;
      } else {
        // 신규 사용자 프로필 생성
        _user = UserModel(
          userId: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? '',
          profileImageUrl: firebaseUser.photoURL,
          onboardingCompleted: false,
          profileSetupCompleted: false,
        );
        
        // Firestore에 신규 사용자 정보 저장
        if (_firebaseEnabled) {
          await _userService.saveUserProfile(_user!);
        }
      }
      
      // 로컬에도 사용자 정보 저장
      await _userService.saveUserPreferences(_user!);
      
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      _setError('사용자 프로필 로드 중 오류가 발생했습니다: ${e.toString()}');
    }
  }
  
  /// 로딩 상태 설정
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  /// 오류 메시지 설정
  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
} 