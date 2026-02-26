import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';

class AvatarPicker extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File?) onImageSelected;
  final double size;

  const AvatarPicker({
    super.key,
    this.initialImageUrl,
    required this.onImageSelected,
    this.size = 120,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          _selectedImage = file;
        });
        widget.onImageSelected(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.textPrimary,
                ),
                title: const Text(
                  '拍照',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.textPrimary,
                ),
                title: const Text(
                  '从相册选择',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null || widget.initialImageUrl != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete,
                    color: AppColors.error,
                  ),
                  title: const Text(
                    '移除照片',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                    });
                    widget.onImageSelected(null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Stack(
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textSecondary,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _buildImageWidget(),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: AppColors.background,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
      );
    } else if (widget.initialImageUrl != null &&
        widget.initialImageUrl!.isNotEmpty) {
      return Image.network(
        widget.initialImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.pets,
        size: widget.size * 0.4,
        color: AppColors.textSecondary,
      ),
    );
  }
}
