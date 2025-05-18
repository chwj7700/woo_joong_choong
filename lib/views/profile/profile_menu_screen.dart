import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/colors.dart';
import '../../routes.dart';

/// 사용자 프로필 메뉴 화면
class ProfileMenuScreen extends StatelessWidget {
  const ProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 사용자 프로필 헤더
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 프로필 이미지
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: user?.profileImageUrl != null
                          ? NetworkImage(user!.profileImageUrl!)
                          : null,
                      child: user?.profileImageUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 사용자 이름/닉네임
                    Text(
                      user?.nickname ?? user?.name ?? '사용자',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // 사용자 이메일
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 프로필 편집 버튼
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.profileSetup);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        '프로필 편집',
                        style: TextStyle(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // 메뉴 목록
              _buildMenuItem(
                context,
                icon: Icons.settings,
                title: '앱 설정',
                subtitle: '알림, 언어, 테마 등',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.settingsRoute);
                },
              ),
              
              _buildMenuItem(
                context,
                icon: Icons.notifications_outlined,
                title: '알림 설정',
                subtitle: '날씨 알림, 일정 알림 등',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.notificationSettings);
                },
              ),
              
              _buildMenuItem(
                context,
                icon: Icons.location_on_outlined,
                title: '위치 설정',
                subtitle: '기본 위치, 추가 위치 관리',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.locationSettings);
                },
              ),
              
              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                title: '도움말',
                subtitle: 'FAQ, 문의하기',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.helpScreen);
                },
              ),
              
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: '앱 정보',
                subtitle: '버전, 개발자 정보 등',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.appInfo);
                },
              ),
              
              const Divider(),
              
              // 로그아웃 버튼
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 메뉴 아이템 위젯
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
        size: 28,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      onTap: onTap,
    );
  }
  
  /// 로그아웃 확인 다이얼로그
  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                
                // 로딩 인디케이터 표시
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
                
                try {
                  // 로그아웃 처리
                  await Provider.of<UserProvider>(context, listen: false).signOut();
                  
                  if (!context.mounted) return;
                  
                  // 로딩 인디케이터 닫기
                  Navigator.of(context).pop();
                  
                  // 로그인 화면으로 이동
                  Navigator.pushNamedAndRemoveUntil(
                    context, 
                    AppRoutes.login, 
                    (route) => false,
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  
                  // 로딩 인디케이터 닫기
                  Navigator.of(context).pop();
                  
                  // 오류 메시지 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('로그아웃 실패: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
} 