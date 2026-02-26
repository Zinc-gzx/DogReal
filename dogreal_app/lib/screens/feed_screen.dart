import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/feed_card.dart';
import '../utils/constants.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.checkTodayPost();
    await postProvider.fetchFeed(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      if (!postProvider.isLoading && postProvider.hasMore) {
        postProvider.fetchFeed();
      }
    }
  }

  Future<void> _handleRefresh() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.checkTodayPost();
    await postProvider.fetchFeed(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<PostProvider>(
          builder: (context, postProvider, _) {
            if (postProvider.isLoading && postProvider.feed.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (postProvider.error != null && postProvider.feed.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      postProvider.error ?? '加载失败',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: _loadInitialData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                      ),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }

            if (postProvider.feed.isEmpty) {
              return _buildEmptyState(postProvider);
            }

            return RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 顶部提示
                  if (!postProvider.hasPostedToday)
                    SliverToBoxAdapter(
                      child: _buildPostReminderBanner(),
                    ),

                  // Feed列表
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < postProvider.feed.length) {
                          return FeedCard(post: postProvider.feed[index]);
                        } else if (postProvider.hasMore) {
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Center(
                              child: Text(
                                '没有更多内容了',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      childCount: postProvider.feed.length +
                          (postProvider.hasMore ? 1 : 1),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(PostProvider postProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            postProvider.hasPostedToday ? Icons.pets : Icons.camera_alt,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            postProvider.hasPostedToday
                ? '还没有好友发布照片'
                : '今天还没有发布照片',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            postProvider.hasPostedToday
                ? '等待好友分享他们宠物的日常'
                : '发布照片后可以查看好友的Feed',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (!postProvider.hasPostedToday) ...[
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: 跳转到相机页面
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('相机功能即将推出')),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('拍摄照片'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostReminderBanner() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.camera_alt,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '📸 今天还没发布照片',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '记录你家宠物的日常瞬间',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: 跳转到相机页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('相机功能即将推出')),
              );
            },
            icon: const Icon(Icons.arrow_forward_ios),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
