import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/colors.dart'; // 앱 색상 사용

/// 날씨 아이콘을 표시하는 위젯
/// OpenWeatherMap 아이콘 API를 사용합니다
class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;
  final Color? backgroundColor;
  final bool addShadow;
  final bool useWhiteBackground;

  const WeatherIcon({
    Key? key,
    required this.iconCode,
    this.size = 50.0,
    this.backgroundColor,
    this.addShadow = true, // 기본적으로 그림자 제거
    this.useWhiteBackground = false, // 기본적으로 하얀 배경 제거
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // OpenWeatherMap 아이콘 URL
    String iconUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';

    // 그림자나 배경이 있는 경우 Container로 감싸기
    if (useWhiteBackground || backgroundColor != null || addShadow) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? (useWhiteBackground ? Colors.white.withOpacity(0.3) : null), // 투명도 증가
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: addShadow ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 더 투명한 그림자
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Image.network(
          iconUrl,
          width: size * 0.9,
          height: size * 0.9,
          errorBuilder: (context, error, stackTrace) {
            // 네트워크 이미지 로드 실패 시 기본 아이콘 표시
            return Icon(
              _getWeatherIcon(iconCode),
              size: size * 0.7,
              color: _getWeatherColor(iconCode),
            );
          },
        ),
      );
    } else {
      // 배경 없이 이미지만 표시 (기본 설정)
      return Image.network(
        iconUrl,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          // 네트워크 이미지 로드 실패 시 기본 아이콘 표시
          // 더 심플한 폴백 아이콘 사용
          return Icon(
            _getWeatherIcon(iconCode),
            size: size * 0.9,
            color: _getWeatherColor(iconCode),
          );
        },
      );
    }
  }
  
  /// 아이콘 코드에 따른 Material 아이콘 반환
  IconData _getWeatherIcon(String code) {
    if (code.startsWith('01')) {
      return Icons.wb_sunny;
    } else if (code.startsWith('02') || code.startsWith('03')) {
      return Icons.cloud_queue;
    } else if (code.startsWith('04')) {
      return Icons.cloud;
    } else if (code.startsWith('09') || code.startsWith('10')) {
      return Icons.water_drop;
    } else if (code.startsWith('11')) {
      return Icons.bolt;
    } else if (code.startsWith('13')) {
      return Icons.ac_unit;
    } else if (code.startsWith('50')) {
      return Icons.foggy;
    }
    
    return Icons.wb_cloudy;
  }
  
  /// 아이콘 코드에 따른 색상 반환 (앱 테마에 더 어울리는 색상으로 수정)
  Color _getWeatherColor(String code) {
    if (code.startsWith('01')) {
      return Colors.amber.shade600; // 맑음
    } else if (code.startsWith('02') || code.startsWith('03')) {
      return AppColors.primary; // 구름 조금 - 앱 주요 색상 사용
    } else if (code.startsWith('04')) {
      return Colors.blueGrey.shade600; // 흐림
    } else if (code.startsWith('09') || code.startsWith('10')) {
      return Colors.lightBlue.shade600; // 비
    } else if (code.startsWith('11')) {
      return Colors.indigo.shade400; // 뇌우
    } else if (code.startsWith('13')) {
      return Colors.lightBlue.shade300; // 눈
    } else if (code.startsWith('50')) {
      return Colors.blueGrey.shade600; // 안개
    }
    
    return AppColors.primary; // 기본값 - 앱 주요 색상 사용
  }
} 