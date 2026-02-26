import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import 'photo_preview_screen.dart';

/// 相机拍摄页面 - BeReal风格双镜头拍照
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isRearCameraSelected = true;
  bool _isLoading = true;
  String? _error;
  
  // 保存拍摄的照片
  String? _frontImagePath;
  String? _backImagePath;
  
  // 防止多重请求
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _error = '没有可用的相机';
          _isLoading = false;
        });
        return;
      }

      await _onCameraSwitch();
    } catch (e) {
      setState(() {
        _error = '相机初始化失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onCameraSwitch() async {
    if (_cameras == null || _cameras!.isEmpty) return;

    final camera = _isRearCameraSelected
        ? _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras!.first,
          )
        : _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras!.first,
          );

    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _controller = controller;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = '相机初始化失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final image = await _controller!.takePicture();

      if (_isRearCameraSelected) {
        // 拍摄后置镜头
        _backImagePath = image.path;
        
        // 自动切换到前置镜头
        setState(() {
          _isRearCameraSelected = false;
          _isLoading = true;
        });
        await _onCameraSwitch();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('后置照片已拍摄，现在拍摄前置照片'),
              duration: Duration(seconds: 2),
              backgroundColor: AppColors.white,
            ),
          );
        }
      } else {
        // 拍摄前置镜头，完成拍摄
        _frontImagePath = image.path;
        
        // 跳转到预览页面
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PhotoPreviewScreen(
                frontImagePath: _frontImagePath!,
                backImagePath: _backImagePath!,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拍照失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // 从相册选择照片
  Future<void> _pickFromGallery() async {
    // 防止多重请求
    if (_isPickingImage) {
      print('已经在选择照片中，忽略重复请求');
      return;
    }
    
    setState(() {
      _isPickingImage = true;
    });
    
    final ImagePicker picker = ImagePicker();
    
    try {
      print('开始选择后置照片...');
      // 选择后置照片
      final XFile? backImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      print('后置照片选择结果: ${backImage?.path ?? "取消"}');
      
      if (backImage == null) {
        print('用户取消了后置照片选择');
        setState(() {
          _isPickingImage = false;
        });
        return;
      }
      
      if (!mounted) {
        print('组件已卸载，中止操作');
        return;
      }
      
      // 第一张照片选择成功后，显示提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 第1张已选择，请继续选择第2张照片'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // 等待一小会儿让用户看到提示
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('开始选择前置照片...');
      // 选择前置照片
      final XFile? frontImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      print('前置照片选择结果: ${frontImage?.path ?? "取消"}');
      
      if (frontImage == null) {
        print('用户取消了前置照片选择');
        setState(() {
          _isPickingImage = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已取消，请重新选择'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      if (!mounted) {
        print('组件已卸载，中止操作');
        return;
      }
      
      print('两张照片都已选择，准备跳转到预览页面');
      print('前置: ${frontImage.path}');
      print('后置: ${backImage.path}');
      
      // 跳转到预览页面 - 在跳转前不重置状态
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PhotoPreviewScreen(
            frontImagePath: frontImage.path,
            backImagePath: backImage.path,
          ),
        ),
      );
      
      print('已跳转到预览页面');
    } catch (e) {
      print('选择照片出错: $e');
      setState(() {
        _isPickingImage = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择照片失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              )
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.photo_library_outlined,
                            color: AppColors.white,
                            size: 80,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '模拟器无法使用相机',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '请从相册选择照片来测试发布功能',
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _isPickingImage ? null : _pickFromGallery,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.black,
                                disabledBackgroundColor: AppColors.white.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              icon: _isPickingImage 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.black,
                                    ),
                                  )
                                : const Icon(Icons.photo_library),
                              label: Text(
                                _isPickingImage ? '选择中...' : '从相册选择照片',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _error = null;
                              });
                              _initializeCamera();
                            },
                            child: const Text(
                              '或重试打开相机',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      // 相机预览
                      Positioned.fill(
                        child: _controller != null &&
                                _controller!.value.isInitialized
                            ? CameraPreview(_controller!)
                            : const SizedBox.shrink(),
                      ),

                      // 顶部工具栏
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.black.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
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
                              Text(
                                _backImagePath == null
                                    ? '拍摄后置照片'
                                    : '拍摄前置照片',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.photo_library,
                                  color: AppColors.white,
                                  size: 28,
                                ),
                                onPressed: _pickFromGallery,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 底部控制栏
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.black.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // 已拍摄的照片预览
                              if (_backImagePath != null)
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(
                                      File(_backImagePath!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(width: 50),

                              // 拍照按钮
                              GestureDetector(
                                onTap: _takePicture,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.white,
                                      width: 4,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),

                              // 切换镜头按钮
                              IconButton(
                                icon: const Icon(
                                  Icons.flip_camera_ios,
                                  color: AppColors.white,
                                  size: 32,
                                ),
                                onPressed: _backImagePath == null
                                    ? () {
                                        setState(() {
                                          _isRearCameraSelected =
                                              !_isRearCameraSelected;
                                          _isLoading = true;
                                        });
                                        _onCameraSwitch();
                                      }
                                    : null,
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
}
