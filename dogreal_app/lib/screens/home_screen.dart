import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'DogReal.',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              
              // 欢迎信息
              const Text(
                '欢迎回来！',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '@${user?.username ?? "用户"}',
                style: AppTextStyles.bodySecondary,
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // 用户信息卡片
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Icon(
                            Icons.pets,
                            size: 32,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.username ?? '',
                                style: AppTextStyles.heading2,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                user?.email ?? '',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(color: AppColors.mediumGrey),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInfoRow('用户 ID', user?.id ?? ''),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoRow(
                      '注册时间',
                      _formatDate(user?.createdAt),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // 功能区域（待开发）
              const Text(
                '即将推出',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '📷 拍摄宠物照片\n🐾 添加宠物档案\n👥 添加好友\n🔔 每日推送提醒',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySecondary,
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.body,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
