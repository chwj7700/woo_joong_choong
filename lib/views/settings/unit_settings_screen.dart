import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_preference_service.dart';
import '../../utils/colors.dart';

/// 단위 설정 화면
class UnitSettingsScreen extends StatefulWidget {
  const UnitSettingsScreen({Key? key}) : super(key: key);

  @override
  State<UnitSettingsScreen> createState() => _UnitSettingsScreenState();
}

class _UnitSettingsScreenState extends State<UnitSettingsScreen> {
  final AppPreferenceService _prefService = AppPreferenceService();
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  /// 설정 로드
  Future<void> _loadSettings() async {
    await _prefService.loadPreferences();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('단위 설정'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '온도 단위',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  RadioListTile<bool>(
                    title: const Text('섭씨 (°C)'),
                    subtitle: const Text('대부분의 국가에서 사용'),
                    value: true,
                    groupValue: _prefService.useCelsius,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _prefService.setTemperatureUnit(value);
                        });
                      }
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text('화씨 (°F)'),
                    subtitle: const Text('미국 등에서 사용'),
                    value: false,
                    groupValue: _prefService.useCelsius,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _prefService.setTemperatureUnit(value);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '온도 비교표',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '주요 온도의 섭씨/화씨 변환 값입니다:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(2),
                        },
                        children: [
                          _buildHeaderRow(['섭씨(°C)', '화씨(°F)', '비고']),
                          _buildTableRow(['-10', '14', '매우 추운 날씨']),
                          _buildTableRow(['0', '32', '물의 어는점']),
                          _buildTableRow(['10', '50', '쌀쌀한 날씨']),
                          _buildTableRow(['20', '68', '쾌적한 날씨']),
                          _buildTableRow(['25', '77', '따뜻한 날씨']),
                          _buildTableRow(['30', '86', '더운 날씨']),
                          _buildTableRow(['37', '98.6', '체온']),
                          _buildTableRow(['40', '104', '극도로 더운 날씨']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '변환 공식:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('• 섭씨 → 화씨: (°C × 9/5) + 32 = °F'),
                    const Text('• 화씨 → 섭씨: (°F - 32) × 5/9 = °C'),
                  ],
                ),
              ),
            ),
            
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '기타 단위',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('기압 단위'),
                    subtitle: Text(_prefService.pressureUnit),
                    trailing: DropdownButton<String>(
                      value: _prefService.pressureUnit,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _prefService.setPressureUnit(newValue);
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'hPa',
                          child: Text('hPa'),
                        ),
                        DropdownMenuItem(
                          value: 'inHg',
                          child: Text('inHg'),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('풍속 단위'),
                    subtitle: Text(_prefService.windSpeedUnit),
                    trailing: DropdownButton<String>(
                      value: _prefService.windSpeedUnit,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _prefService.setWindSpeedUnit(newValue);
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'm/s',
                          child: Text('m/s'),
                        ),
                        DropdownMenuItem(
                          value: 'km/h',
                          child: Text('km/h'),
                        ),
                        DropdownMenuItem(
                          value: 'mph',
                          child: Text('mph'),
                        ),
                        DropdownMenuItem(
                          value: 'knots',
                          child: Text('knots'),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('강수량 단위'),
                    subtitle: Text(_prefService.precipitationUnit),
                    trailing: DropdownButton<String>(
                      value: _prefService.precipitationUnit,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _prefService.setPrecipitationUnit(newValue);
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'mm',
                          child: Text('mm'),
                        ),
                        DropdownMenuItem(
                          value: 'in',
                          child: Text('in'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 테이블 헤더 행 생성
  TableRow _buildHeaderRow(List<String> cells) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Colors.grey,
      ),
      children: cells.map((cell) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            cell,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }
  
  /// 테이블 데이터 행 생성
  TableRow _buildTableRow(List<String> cells) {
    return TableRow(
      children: cells.map((cell) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            cell,
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }
} 