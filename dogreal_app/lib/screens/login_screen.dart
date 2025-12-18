import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // TODO: 实现登录逻辑
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('登录成功！'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  
                  // Logo 区域
                  Center(
                    child: Column(
                      children: [
                        // 这里可以放置你的 Logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: const Icon(
                            Icons.pets,
                            size: 48,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'DogReal.',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          '分享你宠物的真实时刻',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xxl * 1.5),
                  
                  // 欢迎文字
                  const Text(
                    '欢迎回来',
                    style: AppTextStyles.heading1,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    '登录你的账号继续',
                    style: AppTextStyles.bodySecondary,
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
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
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  // 忘记密码
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: 实现忘记密码功能
                      },
                      child: const Text(
                        '忘记密码？',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // 登录按钮
                  CustomButton(
                    text: '登录',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
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
                  
                  // 第三方登录（预留）
                  CustomButton(
                    text: '使用 Apple 登录',
                    onPressed: () {
                      // TODO: 实现 Apple 登录
                    },
                    isOutlined: true,
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // 注册提示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '还没有账号？',
                        style: AppTextStyles.bodySecondary,
                      ),
                      TextButton(
                        onPressed: _navigateToRegister,
                        child: const Text(
                          '立即注册',
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
