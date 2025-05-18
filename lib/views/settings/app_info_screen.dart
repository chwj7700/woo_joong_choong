import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';

/// 앱 정보 화면
class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  late Future<PackageInfo> _packageInfoFuture;
  
  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }
  
  /// 웹 URL 열기
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URL을 열 수 없습니다: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 정보'),
        elevation: 0,
      ),
      body: FutureBuilder<PackageInfo>(
        future: _packageInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('오류가 발생했습니다: ${snapshot.error}'),
            );
          }
          
          final packageInfo = snapshot.data!;
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 앱 로고 및 기본 정보
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 앱 아이콘 이미지
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.cloud,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '우중충',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '버전 ${packageInfo.version} (${packageInfo.buildNumber})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 섹션: 앱 정보
                _buildSection(
                  title: '앱 정보',
                  children: [
                    ListTile(
                      title: const Text('개발자'),
                      subtitle: const Text('우중충 개발팀'),
                      leading: const Icon(Icons.code),
                    ),
                    ListTile(
                      title: const Text('문의하기'),
                      subtitle: const Text('woojoongchoong@example.com'),
                      leading: const Icon(Icons.email),
                      onTap: () {
                        _launchUrl('mailto:woojoongchoong@example.com');
                      },
                    ),
                    ListTile(
                      title: const Text('앱 평가하기'),
                      subtitle: const Text('앱 스토어에서 평가해주세요'),
                      leading: const Icon(Icons.star),
                      onTap: () {
                        // TODO: 스토어 URL 설정
                        _launchUrl('https://play.google.com/store/apps/details?id=com.woojoongchoong.app');
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 섹션: 오픈소스 라이선스
                _buildSection(
                  title: '오픈소스 라이선스',
                  children: [
                    ListTile(
                      title: const Text('라이선스 정보'),
                      leading: const Icon(Icons.document_scanner),
                      onTap: () {
                        showLicensePage(
                          context: context,
                          applicationName: '우중충',
                          applicationVersion: packageInfo.version,
                          applicationLegalese: '© 2023 우중충 개발팀',
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 섹션: 법적 정보
                _buildSection(
                  title: '법적 정보',
                  children: [
                    ListTile(
                      title: const Text('이용약관'),
                      leading: const Icon(Icons.assignment),
                      onTap: () {
                        _launchUrl('https://example.com/terms');
                      },
                    ),
                    ListTile(
                      title: const Text('개인정보 처리방침'),
                      leading: const Icon(Icons.privacy_tip),
                      onTap: () {
                        _launchUrl('https://example.com/privacy');
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 푸터
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '© 2023 우중충 개발팀. 모든 권리 보유.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
  
  /// 섹션 위젯
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
} 