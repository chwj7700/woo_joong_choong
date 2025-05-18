// Firebase 패키지 import
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import '../models/user_model.dart';

/// 인증 결과 상태 열거형
enum AuthResultStatus {
  successful,
  emailAlreadyExists,
  wrongPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  tooManyRequests,
  weakPassword,
  undefined,
  networkRequestFailed,
}

/// Firebase 인증 서비스
class AuthService {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  
  // Firebase 사용 여부 (전달 받거나 자동 감지)
  final bool _firebaseEnabled;
  
  AuthService({bool? firebaseEnabled}) 
      : _firebaseEnabled = firebaseEnabled ?? false;
  
  /// 현재 로그인한 사용자 가져오기
  firebase.User? get currentUser {
    if (!_firebaseEnabled) return null;
    return _auth.currentUser;
  }
  
  /// 인증 상태 변경 스트림
  Stream<firebase.User?> get authStateChanges => _auth.authStateChanges();
  
  /// 이메일/비밀번호로 회원가입
  Future<AuthResultStatus> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (!_firebaseEnabled) {
        // Firebase 비활성화 상태 - 테스트용 임시 처리
        await Future.delayed(const Duration(seconds: 1)); // 로딩 시뮬레이션
        
        // 로컬에 이메일 저장 (나중에 로그인 확인용)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('test_email', email);
        await prefs.setString('test_password', password);
        await prefs.setString('test_name', name);
        
        return AuthResultStatus.successful;
      }
      
      // 계정 생성
      final firebase.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 사용자 이름 업데이트
      await result.user?.updateDisplayName(name);
      
      return AuthResultStatus.successful;
    } catch (e) {
      return _handleException(e);
    }
  }
  
  /// 이메일/비밀번호로 로그인
  Future<AuthResultStatus> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (!_firebaseEnabled) {
        // Firebase 비활성화 상태 - 테스트용 임시 처리
        print('Firebase 비활성화 상태: 테스트 모드로 로그인을 시도합니다.');
        await Future.delayed(const Duration(seconds: 1)); // 로딩 시뮬레이션
        
        // 로컬에서 저장된 이메일/비밀번호 확인
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('test_email');
        final savedPassword = prefs.getString('test_password');
        
        // 테스트를 위해 기본값 설정
        if (savedEmail == null) {
          print('테스트 계정 설정: test@example.com / password123');
          await prefs.setString('test_email', 'test@example.com');
          await prefs.setString('test_password', 'password123');
          await prefs.setString('test_name', '테스트 사용자');
        }
        
        // 입력 값과 저장된 값 비교 (간단한 모의 인증)
        final storedEmail = prefs.getString('test_email') ?? 'test@example.com';
        final storedPass = prefs.getString('test_password') ?? 'password123';
        
        print('로그인 시도: $email (저장된 테스트 계정: $storedEmail)');
        
        if (email == storedEmail && password == storedPass) {
          print('테스트 모드 로그인 성공');
          return AuthResultStatus.successful;
        } else if (email != storedEmail) {
          print('테스트 모드 로그인 실패: 사용자를 찾을 수 없음');
          return AuthResultStatus.userNotFound;
        } else {
          print('테스트 모드 로그인 실패: 비밀번호 불일치');
          return AuthResultStatus.wrongPassword;
        }
      }
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return AuthResultStatus.successful;
    } catch (e) {
      print('로그인 오류: $e');
      return _handleException(e);
    }
  }
  
  /// Google 로그인
  Future<AuthResultStatus> signInWithGoogle() async {
    try {
      if (!_firebaseEnabled) {
        // Firebase 비활성화 상태 - 테스트용 임시 처리
        await Future.delayed(const Duration(seconds: 1)); // 로딩 시뮬레이션
        
        // 로컬에 Google 로그인 정보 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('test_email', 'google_user@example.com');
        await prefs.setString('test_name', 'Google 테스트 사용자');
        
        return AuthResultStatus.successful;
      }
      
      // 모바일인 경우
      if (Platform.isAndroid || Platform.isIOS) {
        // 구글 로그인 다이얼로그 표시
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        
        if (googleUser == null) {
          return AuthResultStatus.operationNotAllowed; // 사용자가 취소함
        }
        
        // 인증 정보 가져오기
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        // Firebase 인증 정보 생성
        final firebase.AuthCredential credential = firebase.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        // Firebase로 로그인
        await _auth.signInWithCredential(credential);
        
        return AuthResultStatus.successful;
      } 
      // 웹인 경우
      else {
        // 구글 로그인 제공자 생성
        firebase.GoogleAuthProvider googleProvider = firebase.GoogleAuthProvider();
        
        // 로그인 진행
        await _auth.signInWithPopup(googleProvider);
        
        return AuthResultStatus.successful;
      }
    } catch (e) {
      return _handleException(e);
    }
  }
  
  /// 로그아웃
  Future<void> signOut() async {
    if (!_firebaseEnabled) {
      // Firebase 비활성화 상태 - 테스트용 임시 처리
      await Future.delayed(const Duration(milliseconds: 500)); // 로딩 시뮬레이션
      return;
    }
    
    await _auth.signOut();
    
    // Google 로그인 상태도 로그아웃
    if (Platform.isAndroid || Platform.isIOS) {
      await GoogleSignIn().signOut();
    }
  }
  
  /// 비밀번호 재설정 이메일 전송
  Future<AuthResultStatus> sendPasswordResetEmail(String email) async {
    try {
      if (!_firebaseEnabled) {
        // Firebase 비활성화 상태 - 테스트용 임시 처리
        await Future.delayed(const Duration(seconds: 1)); // 로딩 시뮬레이션
        
        // 로컬에 저장된 이메일 확인
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('test_email');
        
        if (savedEmail == null || email != savedEmail) {
          return AuthResultStatus.userNotFound;
        }
        
        return AuthResultStatus.successful;
      }
      
      await _auth.sendPasswordResetEmail(email: email);
      
      return AuthResultStatus.successful;
    } catch (e) {
      return _handleException(e);
    }
  }
  
  /// 현재 사용자 정보로 UserModel 객체 생성
  UserModel? getCurrentUserProfile() {
    if (!_firebaseEnabled) return null;
    
    final firebase.User? user = _auth.currentUser;
    if (user == null) return null;
    
    return UserModel(
      userId: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      profileImageUrl: user.photoURL,
    );
  }
  
  /// Firebase 예외 처리
  AuthResultStatus _handleException(dynamic e) {
    if (!_firebaseEnabled) {
      return AuthResultStatus.networkRequestFailed;
    }
    
    AuthResultStatus status;
    
    if (e is firebase.FirebaseAuthException) {
      status = _getAuthResultStatus(e.code);
    } else {
      status = AuthResultStatus.undefined;
    }
    
    return status;
  }
  
  /// Firebase 오류 코드를 AuthResultStatus로 변환
  AuthResultStatus _getAuthResultStatus(String code) {
    switch (code) {
      case 'invalid-email':
        return AuthResultStatus.invalidEmail;
      case 'wrong-password':
        return AuthResultStatus.wrongPassword;
      case 'user-not-found':
        return AuthResultStatus.userNotFound;
      case 'user-disabled':
        return AuthResultStatus.userDisabled;
      case 'too-many-requests':
        return AuthResultStatus.tooManyRequests;
      case 'operation-not-allowed':
        return AuthResultStatus.operationNotAllowed;
      case 'email-already-in-use':
        return AuthResultStatus.emailAlreadyExists;
      case 'weak-password':
        return AuthResultStatus.weakPassword;
      case 'network-request-failed':
        return AuthResultStatus.networkRequestFailed;
      default:
        return AuthResultStatus.undefined;
    }
  }
  
  /// 오류 코드를 사용자 친화적인 메시지로 변환
  String getErrorMessage(AuthResultStatus status) {
    String message;
    
    switch (status) {
      case AuthResultStatus.invalidEmail:
        message = '유효하지 않은 이메일 형식입니다.';
        break;
      case AuthResultStatus.wrongPassword:
        message = '비밀번호가 잘못되었습니다.';
        break;
      case AuthResultStatus.userNotFound:
        message = '해당 이메일로 가입된 사용자가 없습니다.';
        break;
      case AuthResultStatus.userDisabled:
        message = '해당 계정이 비활성화되었습니다.';
        break;
      case AuthResultStatus.tooManyRequests:
        message = '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
        break;
      case AuthResultStatus.operationNotAllowed:
        message = '이 작업은 현재 허용되지 않습니다.';
        break;
      case AuthResultStatus.emailAlreadyExists:
        message = '이미 가입된 이메일입니다.';
        break;
      case AuthResultStatus.weakPassword:
        message = '비밀번호가 너무 약합니다. 더 강력한 비밀번호를 사용해주세요.';
        break;
      case AuthResultStatus.networkRequestFailed:
        message = '네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인해주세요.';
        break;
      case AuthResultStatus.undefined:
        message = '알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
        break;
      case AuthResultStatus.successful:
        message = '성공';
        break;
      default:
        message = '알 수 없는 오류가 발생했습니다. 다시 시도해주세요.';
    }
    
    return message;
  }
} 