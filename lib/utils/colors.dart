import 'package:flutter/material.dart';

/// 앱에서 사용하는 모든 색상 정의
class AppColors {
  // 주요 색상
  static const Color primary = Color(0xFF4A90E2); // 메인 색상 (하늘색/파란색)
  static const Color primaryDark = Color(0xFF3B73B4); // 메인 색상 어두운 버전
  static const Color primaryLight = Color(0xFF81B3F3); // 메인 색상 밝은 버전
  static const Color secondary = Color(0xFF5AC8FA); // 보조 색상
  static const Color accent = Color(0xFF5AC8FA); // 강조 색상

  // 텍스트 색상
  static const Color textPrimary = Color(0xFF333333); // 기본 텍스트
  static const Color textSecondary = Color(0xFF757575); // 보조 텍스트
  static const Color textLight = Color(0xFFBDBDBD); // 흐린 텍스트

  // 배경 색상
  static const Color background = Color(0xFFF5F5F5); // 기본 배경
  static const Color cardBackground = Color(0xFFFFFFFF); // 카드 배경
  static const Color divider = Color(0xFFE0E0E0); // 구분선

  // 상태 색상
  static const Color success = Color(0xFF4CAF50); // 성공
  static const Color error = Color(0xFFE53935); // 오류
  static const Color warning = Color(0xFFFFB300); // 경고
  static const Color info = Color(0xFF2196F3); // 정보

  // 날씨 관련 색상
  static const Color sunny = Color(0xFFFFD54F); // 맑음
  static const Color cloudy = Color(0xFFBDBDBD); // 흐림
  static const Color rainy = Color(0xFF4FC3F7); // 비
  static const Color snowy = Color(0xFFE1F5FE); // 눈
  static const Color foggy = Color(0xFFECEFF1); // 안개

  // 온도 관련 색상
  static const Color cold = Color(0xFF81D4FA); // 추움
  static const Color cool = Color(0xFF4FC3F7); // 시원함
  static const Color mild = Color(0xFFA5D6A7); // 보통
  static const Color warm = Color(0xFFFFB74D); // 따뜻함
  static const Color hot = Color(0xFFFF8A65); // 더움

  // 미세먼지 관련 색상
  static const Color dustGood = Color(0xFF4CAF50);      // 좋음 (녹색)
  static const Color dustModerate = Color(0xFFFFC107);  // 보통 (노랑)
  static const Color dustBad = Color(0xFFFF9800);       // 나쁨 (주황)
  static const Color dustVeryBad = Color(0xFFE53935);   // 매우 나쁨 (빨강)
  
  // 그라데이션
  static const List<Color> primaryGradient = [
    Color(0xFF4A90E2),
    Color(0xFF5AC8FA),
  ];
  
  static const List<Color> coldGradient = [
    Color(0xFF81D4FA),
    Color(0xFF4FC3F7),
  ];
  
  static const List<Color> hotGradient = [
    Color(0xFFFFB74D),
    Color(0xFFFF8A65),
  ];

  // 알림 중요도
  static const Color lowPriority = Color(0xFF4CAF50);
  static const Color mediumPriority = Color(0xFFFFC107);
  static const Color highPriority = Color(0xFFE53935);
} 