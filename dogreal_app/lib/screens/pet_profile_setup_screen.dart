import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';
import '../services/pet_service.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class PetProfileSetupScreen extends StatefulWidget {
  const PetProfileSetupScreen({super.key});

  @override
  State<PetProfileSetupScreen> createState() => _PetProfileSetupScreenState();
}

class _PetProfileSetupScreenState extends State<PetProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _bioController = TextEditingController();
  final _weightController = TextEditingController();
  
  File? _avatarFile;
  DateTime? _birthday;
  String _gender = 'unknown';
  bool _isLoading = false;
  bool _isEditMode = false;

  final List<String> _commonBreeds = [
    '金毛寻回犬',
    '拉布拉多',
    '哈士奇',
    '柴犬',
    '柯基',
    '泰迪',
    '边境牧羊犬',
    '萨摩耶',
    '博美',
    '比熊',
    '其他'
  ];

  @override
  void initState() {
    super.initState();
    // 延迟加载数据，避免在build期间调用setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingPet();
    });
  }

  Future<void> _loadExistingPet() async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    
    // 先从服务器获取最新数据
    await petProvider.fetchMyPet();
    
    final pet = petProvider.currentPet;
    
    if (pet != null && mounted) {
      setState(() {
        _isEditMode = true;
        _nameController.text = pet.name;
        _breedController.text = pet.breed;
        _birthday = pet.birthday;
        _gender = pet.gender;
        _bioController.text = pet.bio ?? '';
        if (pet.weight != null) {
          _weightController.text = pet.weight.toString();
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _bioController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 1),
      firstDate: DateTime(now.year - 30),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.surface,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  void _showBreedPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                '选择品种',
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _commonBreeds.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _commonBreeds[index],
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    onTap: () {
                      setState(() {
                        _breedController.text = _commonBreeds[index];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_birthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择宠物生日'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? avatarUrl;
      
      // 如果选择了新头像，先上传
      if (_avatarFile != null) {
        final petService = PetService();
        avatarUrl = await petService.uploadAvatar(_avatarFile!);
      } else if (_isEditMode) {
        // 编辑模式下，如果没有选择新头像，使用现有头像
        final petProvider = Provider.of<PetProvider>(context, listen: false);
        avatarUrl = petProvider.currentPet?.avatar;
      }

      // 创建或更新宠物档案
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      final success = await petProvider.createPet(
        name: _nameController.text.trim(),
        breed: _breedController.text.trim(),
        birthday: _birthday!,
        gender: _gender,
        bio: _bioController.text.trim(),
        weight: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        avatar: avatarUrl,
      );

      if (mounted) {
        if (success) {
          // 重新获取宠物数据以确保状态同步
          await petProvider.fetchMyPet();
          
          // 更新成功提示
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEditMode ? '档案更新成功' : '档案创建成功'),
                backgroundColor: AppColors.success,
              ),
            );
            
            // 如果是从注册流程来的（不是编辑模式），跳转到主页
            if (!_isEditMode) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            } else {
              // 编辑模式，返回上一页
              Navigator.of(context).pop();
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(petProvider.error ?? (_isEditMode ? '更新失败' : '创建失败')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_isEditMode ? "更新" : "创建"}失败: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _isEditMode ? '编辑宠物档案' : '创建宠物档案',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xl),
                
                // 头像选择器
                Consumer<PetProvider>(
                  builder: (context, petProvider, _) => AvatarPicker(
                    size: 120,
                    initialImageUrl: petProvider.currentPet?.avatar,
                    onImageSelected: (file) {
                      setState(() {
                        _avatarFile = file;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // 宠物名字
                CustomTextField(
                  controller: _nameController,
                  hintText: '宠物名字',
                  prefixIcon: const Icon(Icons.pets, color: AppColors.textSecondary),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入宠物名字';
                    }
                    if (value.length > 50) {
                      return '名字不能超过50个字符';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // 品种选择
                GestureDetector(
                  onTap: _showBreedPicker,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _breedController,
                      hintText: '品种',
                      prefixIcon: const Icon(Icons.category, color: AppColors.textSecondary),
                      suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请选择品种';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // 生日选择
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cake,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            _birthday == null
                                ? '选择生日'
                                : '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: _birthday == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // 性别选择
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '性别',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _GenderButton(
                              label: '男孩',
                              icon: Icons.male,
                              isSelected: _gender == 'male',
                              onTap: () => setState(() => _gender = 'male'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _GenderButton(
                              label: '女孩',
                              icon: Icons.female,
                              isSelected: _gender == 'female',
                              onTap: () => setState(() => _gender = 'female'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _GenderButton(
                              label: '未知',
                              icon: Icons.help_outline,
                              isSelected: _gender == 'unknown',
                              onTap: () => setState(() => _gender = 'unknown'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // 体重（可选）
                CustomTextField(
                  controller: _weightController,
                  hintText: '体重 (kg) - 可选',
                  prefixIcon: const Icon(Icons.monitor_weight, color: AppColors.textSecondary),
                  keyboardType: TextInputType.number,
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // 个人简介（可选）
                CustomTextField(
                  controller: _bioController,
                  hintText: '个人简介 - 可选',
                  prefixIcon: const Icon(Icons.description, color: AppColors.textSecondary),
                  maxLines: 3,
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // 提交按钮
                CustomButton(
                  text: _isEditMode ? '保存修改' : '创建档案',
                  onPressed: _isLoading ? null : _handleSubmit,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.background : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.background : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
