import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../utils/constants.dart';

class FeedCard extends StatelessWidget {
  final Post post;

  const FeedCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：用户信息
          _buildHeader(context),
          
          // 图片
          _buildImages(),
          
          // 操作按钮
          _buildActions(context),
          
          // 点赞数和评论数
          _buildStats(),
          
          // 描述
          if (post.caption.isNotEmpty) _buildCaption(),
          
          // 评论预览
          if (post.comments.isNotEmpty) _buildCommentsPreview(),
          
          // 发布时间
          _buildTimestamp(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // 宠物头像
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.background,
            backgroundImage: post.petAvatar.isNotEmpty
                ? NetworkImage(post.petAvatar)
                : null,
            child: post.petAvatar.isEmpty
                ? const Icon(Icons.pets, color: AppColors.textSecondary)
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          // 用户名和宠物名
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.username,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${post.petName}, ${post.petAge}岁 · ${post.petBreed}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // 更多按钮
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: 显示更多选项
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImages() {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: post.images.length == 1
          ? _buildSingleImage(post.images[0])
          : _buildDualImages(),
    );
  }

  Widget _buildSingleImage(PostImage image) {
    return Image.network(
      image.url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.background,
          child: const Center(
            child: Icon(
              Icons.broken_image,
              color: AppColors.textSecondary,
              size: 48,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDualImages() {
    return Row(
      children: [
        Expanded(
          child: Image.network(
            post.images[0].url,
            fit: BoxFit.cover,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.background,
                child: const Center(
                  child: Icon(Icons.broken_image,
                      color: AppColors.textSecondary),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Image.network(
            post.images[1].url,
            fit: BoxFit.cover,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.background,
                child: const Center(
                  child: Icon(Icons.broken_image,
                      color: AppColors.textSecondary),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // 点赞按钮
          IconButton(
            icon: Icon(
              post.likes.isNotEmpty ? Icons.favorite : Icons.favorite_border,
              color: post.likes.isNotEmpty ? AppColors.error : AppColors.textPrimary,
              size: 28,
            ),
            onPressed: () {
              postProvider.toggleLike(post.id);
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          // 评论按钮
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.textPrimary,
              size: 28,
            ),
            onPressed: () {
              // TODO: 打开评论界面
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          // 分享按钮
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textPrimary,
              size: 28,
            ),
            onPressed: () {
              // TODO: 分享功能
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    if (post.likesCount == 0 && post.commentsCount == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Text(
        '${post.likesCount}个赞 · ${post.commentsCount}条评论',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${post.username} ',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: post.caption,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.commentsCount > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '查看全部${post.commentsCount}条评论',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ...post.comments.take(2).map((comment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${comment.username} ',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: comment.text,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        timeago.format(post.postedAt, locale: 'zh'),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}
