import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/weather_icons.dart';

/// 날씨 요약 위젯
class WeatherSummaryWidget extends StatelessWidget {
  final WeatherData weather;
  final String locationName;

  const WeatherSummaryWidget({
    Key? key,
    required this.weather,
    required this.locationName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              locationName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_formatDate(weather.dt)} 기준',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherIcon(),
                _buildTemperature(),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetails(),
          ],
        ),
      ),
    );
  }

  /// 날씨 아이콘 위젯
  Widget _buildWeatherIcon() {
    return Column(
      children: [
        Image.asset(
          WeatherIcons.getIconPath(weather.icon),
          width: 80,
          height: 80,
        ),
        const SizedBox(height: 8),
        Text(
          weather.description,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 온도 정보 위젯
  Widget _buildTemperature() {
    return Column(
      children: [
        Text(
          '${weather.temp.toStringAsFixed(1)}°',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Text(
              '최고: ${weather.tempMax.toStringAsFixed(1)}°',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
            Text(
              '최저: ${weather.tempMin.toStringAsFixed(1)}°',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '체감: ${weather.feelsLike.toStringAsFixed(1)}°',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  /// 날씨 상세 정보 위젯
  Widget _buildDetails() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            Icons.water_drop,
            '습도',
            '${weather.humidity}%',
          ),
          _buildDetailItem(
            Icons.air,
            '풍속',
            '${weather.windSpeed} m/s',
          ),
          _buildDetailItem(
            Icons.compress,
            '기압',
            '${weather.pressure} hPa',
          ),
        ],
      ),
    );
  }

  /// 날씨 상세 정보 항목 위젯
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '오늘 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
} 