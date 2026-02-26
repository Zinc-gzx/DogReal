import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/post_provider.dart';
import '../providers/pet_provider.dart';
import 'main_navigation_screen.dart';

/// 创建帖子页面 - 添加标题并发布
class CreatePostScreen extends StatefulWidget {
  final String frontImagePath;
  final String backImagePath;

  const CreatePostScreen({
    super.key,
    required this.frontImagePath,
    required this.backImagePath,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _publishPost() async {
    if (_isPosting) return;

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    if (petProvider.currentPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先创建宠物档案'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      await postProvider.createPost(
        petId: petProvider.currentPet!.id,
        caption: _captionController.text.trim(),
        frontImage: File(widget.frontImagePath),
        backImage: File(widget.backImagePath),
      );

      if (mounted) {
        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('发布成功！'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // 跳转回主页并刷新Feed
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
          (route) => false,
        );

        // 刷新Feed
        postProvider.fetchFeed(refresh: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发布失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部工具栏
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.white,
                      size: 28,
                    ),
                    onPressed: _isPosting
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    '发布',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: _isPosting ? null : _publishPost,
                    child: _isPosting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            '发布',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 照片预览（小图）
                    Row(
                      children: [
                        // 后置镜头
                        Expanded(
                          child: _buildSmallPhotoPreview(
                            context,
                            imagePath: widget.backImagePath,
                            label: '后置',
                          ),
                        ),
                        const SizedBox(width: 12),

                        // 前置镜头
                        Expanded(
                          child: _buildSmallPhotoPreview(
                            context,
                            imagePath: widget.frontImagePath,
                            label: '前置',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 标题输入框
                    const Text(
                      '添加说明（可选）',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _captionController,
                      maxLines: 4,
                      maxLength: 200,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: '分享你的心情...',
                        hintStyle: TextStyle(
                          color: AppColors.white.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: AppColors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        counterStyle: TextStyle(
                          color: AppColors.white.withOpacity(0.5),
                        ),
                      ),
                      enabled: !_isPosting,
                    ),

                    const SizedBox(height: 24),

                    // 提示信息
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.white.withOpacity(0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '每天只能发布一次，好友可以看到你的分享',
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallPhotoPreview(
    BuildContext context, {
    required String imagePath,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.white.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
