import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入用户名';
    }
    if (value.length < 2) {
      return '用户名至少需要2个字符';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码至少需要6个字符';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != _passwordController.text) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先同意服务条款和隐私政策'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register(
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          // 注册成功，直接登录并导航到主页
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else {
          // 注册失败，显示错误信息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? '注册失败'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  
                  // 标题
                  const Text(
                    '创建账号',
                    style: AppTextStyles.heading1,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    '加入 DogReal 社区，分享你宠物的真实瞬间',
                    style: AppTextStyles.bodySecondary,
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // 用户名输入框
                  CustomTextField(
                    hintText: '用户名',
                    controller: _nameController,
                    validator: _validateName,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.textGrey,
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // 邮箱输入框
                  CustomTextField(
                    hintText: '邮箱',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.textGrey,
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // 密码输入框
                  CustomTextField(
                    hintText: '密码',
                    controller: _passwordController,
                    isPassword: true,
                    validator: _validatePassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textGrey,
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // 确认密码输入框
                  CustomTextField(
                    hintText: '确认密码',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    validator: _validateConfirmPassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textGrey,
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // 服务条款
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                          activeColor: AppColors.white,
                          checkColor: AppColors.black,
                          side: const BorderSide(
                            color: AppColors.textGrey,
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Wrap(
                          children: [
                            const Text(
                              '我已阅读并同意 ',
                              style: AppTextStyles.caption,
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: 显示服务条款
                              },
                              child: const Text(
                                '服务条款',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.white,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Text(
                              ' 和 ',
                              style: AppTextStyles.caption,
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: 显示隐私政策
                              },
                              child: const Text(
                                '隐私政策',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.white,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // 注册按钮
                  CustomButton(
                    text: '注册',
                    onPressed: _handleRegister,
                    isLoading: authProvider.isLoading,
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // 分割线
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          '或',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // 第三方注册（预留）
                  CustomButton(
                    text: '使用 Apple 注册',
                    onPressed: () {
                      // TODO: 实现 Apple 注册
                    },
                    isOutlined: true,
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // 登录提示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '已有账号？',
                        style: AppTextStyles.bodySecondary,
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          '立即登录',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
