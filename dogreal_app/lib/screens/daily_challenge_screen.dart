import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../utils/constants.dart';
import 'camera_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChallengeProvider>(context, listen: false).fetchTodayChallenge();
    });
  }

  @override
  Widget build(BuildContext context) {
    final challengeProvider = Provider.of<ChallengeProvider>(context);
    final challenge = challengeProvider.todayChallenge;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '今日挑战',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
      ),
      body: challengeProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.white,
              ),
            )
          : challengeProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 64,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '加载失败',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Text(
                          challengeProvider.error ?? '',
                          style: AppTextStyles.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ElevatedButton(
                        onPressed: () {
                          challengeProvider.fetchTodayChallenge();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.black,
                        ),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : challenge == null
                  ? const Center(
                      child: Text(
                        '暂无挑战',
                        style: AppTextStyles.bodySecondary,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.xl),

                          // 挑战图标
                          Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppColors.darkGrey,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white.withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  challenge.icon,
                                  style: const TextStyle(fontSize: 64),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // 挑战主题
                          Text(
                            challenge.theme,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // 挑战描述
                          Text(
                            challenge.description,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 18,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          // 推送时间提示
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
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
                                const Icon(
                                  Icons.notifications_active,
                                  color: AppColors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '今日提醒时间',
                                        style: AppTextStyles.bodySecondary,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        challenge.notificationTime,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          // 参与挑战按钮
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const CameraScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: 24),
                                  SizedBox(width: AppSpacing.sm),
                                  Text(
                                    '参与挑战',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // BeReal 风格提示
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.darkGrey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppColors.textGrey,
                                  size: 32,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  '每天只有一次机会\n展示你宠物最真实的瞬间',
                                  style: AppTextStyles.bodySecondary.copyWith(
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          // 查看历史挑战
                          TextButton(
                            onPressed: () {
                              _showChallengeHistory(context);
                            },
                            child: const Text(
                              '查看历史挑战 →',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  void _showChallengeHistory(BuildContext context) {
    final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
    
    // 加载历史挑战
    challengeProvider.fetchChallengeHistory();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkGrey,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<ChallengeProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  // 顶部拖拽条
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.sm),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // 标题
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Text(
                      '历史挑战',
                      style: AppTextStyles.heading2,
                    ),
                  ),
                  
                  const Divider(
                    color: AppColors.mediumGrey,
                    height: AppSpacing.lg,
                  ),
                  
                  // 历史列表
                  Expanded(
                    child: provider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                            ),
                          )
                        : provider.challengeHistory.isEmpty
                            ? const Center(
                                child: Text(
                                  '暂无历史挑战',
                                  style: AppTextStyles.bodySecondary,
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                itemCount: provider.challengeHistory.length,
                                itemBuilder: (context, index) {
                                  final challenge = provider.challengeHistory[index];
                                  return _buildHistoryItem(challenge);
                                },
                              ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(dynamic challenge) {
    final date = DateTime.parse(challenge.date.toString());
    final dateStr = '${date.month}月${date.day}日';
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.mediumGrey,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                challenge.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.theme,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
