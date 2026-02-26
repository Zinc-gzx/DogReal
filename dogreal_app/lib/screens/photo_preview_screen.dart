import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'create_post_screen.dart';

/// 照片预览页面 - 显示拍摄的双镜头照片
class PhotoPreviewScreen extends StatelessWidget {
  final String frontImagePath;
  final String backImagePath;

  const PhotoPreviewScreen({
    super.key,
    required this.frontImagePath,
    required this.backImagePath,
  });

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
                      Icons.close,
                      color: AppColors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    '照片预览',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // 照片显示区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // 后置镜头照片（主照片）
                    _buildPhotoCard(
                      context,
                      title: '后置镜头',
                      imagePath: backImagePath,
                      isPrimary: true,
                    ),

                    const SizedBox(height: 24),

                    // 前置镜头照片（小照片）
                    _buildPhotoCard(
                      context,
                      title: '前置镜头',
                      imagePath: frontImagePath,
                      isPrimary: false,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // 底部按钮
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // 重拍按钮
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        side: const BorderSide(color: AppColors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '重拍',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 下一步按钮
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => CreatePostScreen(
                              frontImagePath: frontImagePath,
                              backImagePath: backImagePath,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '下一步',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildPhotoCard(
    BuildContext context, {
    required String title,
    required String imagePath,
    required bool isPrimary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.white.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: isPrimary ? 3 / 4 : 1,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
