import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';

void main() {
  // 设置状态栏样式
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DogReal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.white,
        scaffoldBackgroundColor: AppColors.black,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.white,
          secondary: AppColors.white,
          surface: AppColors.black,
          error: AppColors.error,
        ),
        fontFamily: 'SF Pro Display', // iOS 风格字体
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
