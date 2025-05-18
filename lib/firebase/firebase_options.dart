// 참고: 실제 Firebase 프로젝트에서는 firebase_options.dart 파일이 flutterfire CLI에 의해 자동 생성됩니다.
// 이 예제 파일은 임시적으로 사용되며 실제 Firebase 프로젝트 연동 시 flutterfire CLI로 생성된 파일로 교체하는 것이 좋습니다.

// 주의: 이 파일은 실제 Firebase 프로젝트 키 값으로 교체해야 합니다.
// FlutterFire CLI로 자동 생성된 firebase_options.dart 파일의 내용을 이 파일로 복사하거나
// 위치를 lib/firebase_options.dart로 변경하고 import 경로를 수정해야 합니다.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// 기본 Firebase 옵션 설정
/// 
/// 실제 Firebase 프로젝트에서는 이 파일이 flutterfire CLI에 의해 자동 생성됩니다.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions는 Windows 플랫폼에 대한 옵션이 정의되어 있지 않습니다.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions는 Linux 플랫폼에 대한 옵션이 정의되어 있지 않습니다.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions는 지정된 플랫폼에 대한 옵션이 정의되어 있지 않습니다: ${defaultTargetPlatform.toString()}',
        );
    }
  }

  // 웹 옵션 (FlutterFire CLI로 생성된 실제 값으로 교체해야 함)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',          // 실제 값으로 교체
    appId: 'YOUR_WEB_APP_ID',            // 실제 값으로 교체
    messagingSenderId: 'YOUR_SENDER_ID', // 실제 값으로 교체
    projectId: 'YOUR_PROJECT_ID',        // 실제 값으로 교체
    authDomain: 'YOUR_AUTH_DOMAIN',      // 실제 값으로 교체
    storageBucket: 'YOUR_STORAGE_BUCKET',// 실제 값으로 교체
    measurementId: 'YOUR_MEASUREMENT_ID',// 실제 값으로 교체
  );

  // Android 옵션 (FlutterFire CLI로 생성된 실제 값으로 교체해야 함)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',      // 실제 값으로 교체
    appId: 'YOUR_ANDROID_APP_ID',        // 실제 값으로 교체
    messagingSenderId: 'YOUR_SENDER_ID', // 실제 값으로 교체
    projectId: 'YOUR_PROJECT_ID',        // 실제 값으로 교체
    storageBucket: 'YOUR_STORAGE_BUCKET',// 실제 값으로 교체
  );

  // iOS 옵션 (FlutterFire CLI로 생성된 실제 값으로 교체해야 함)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',          // 실제 값으로 교체
    appId: 'YOUR_IOS_APP_ID',            // 실제 값으로 교체
    messagingSenderId: 'YOUR_SENDER_ID', // 실제 값으로 교체
    projectId: 'YOUR_PROJECT_ID',        // 실제 값으로 교체
    storageBucket: 'YOUR_STORAGE_BUCKET',// 실제 값으로 교체
    iosClientId: 'YOUR_IOS_CLIENT_ID',   // 실제 값으로 교체
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',   // 실제 값으로 교체
  );

  // macOS 옵션 (FlutterFire CLI로 생성된 실제 값으로 교체해야 함)
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',        // 실제 값으로 교체
    appId: 'YOUR_MACOS_APP_ID',          // 실제 값으로 교체
    messagingSenderId: 'YOUR_SENDER_ID', // 실제 값으로 교체
    projectId: 'YOUR_PROJECT_ID',        // 실제 값으로 교체
    storageBucket: 'YOUR_STORAGE_BUCKET',// 실제 값으로 교체
    iosClientId: 'YOUR_MACOS_CLIENT_ID', // 실제 값으로 교체
    iosBundleId: 'YOUR_MACOS_BUNDLE_ID', // 실제 값으로 교체
  );
} 