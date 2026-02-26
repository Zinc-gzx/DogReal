import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/friend_provider.dart';
import '../providers/pet_provider.dart';
import '../providers/challenge_provider.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'friends_screen.dart';
import 'pet_profile_setup_screen.dart';
import 'daily_challenge_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
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
              // 清除所有Provider状态
              petProvider.clearPet();
              friendProvider.clear();
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
        child: SingleChildScrollView(
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
              
              // 功能按钮
              _buildActionButton(
                context,
                icon: Icons.pets,
                label: '宠物档案',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PetProfileSetupScreen(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              _buildActionButton(
                context,
                icon: Icons.people,
                label: '好友',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FriendsScreen(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // 今日挑战
              _buildActionButton(
                context,
                icon: Icons.emoji_events,
                label: '今日挑战',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DailyChallengeScreen(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // 即将推出
              const Text(
                '即将推出',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '🏆 好友排行榜\n📊 数据统计',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final friendProvider = Provider.of<FriendProvider>(context);
    final hasBadge = label == '好友' && friendProvider.pendingRequestsCount > 0;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Icon(icon, color: AppColors.white, size: 28),
                if (hasBadge)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${friendProvider.pendingRequestsCount}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.heading2,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.white.withOpacity(0.5),
              size: 16,
            ),
          ],
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
