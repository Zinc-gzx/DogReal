import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'providers/auth_provider.dart';
import 'providers/pet_provider.dart';
import 'providers/post_provider.dart';
import 'providers/friend_provider.dart';
import 'providers/challenge_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/pet_profile_setup_screen.dart';
import 'utils/constants.dart';

void main() {
  // 配置timeago中文语言包
  timeago.setLocaleMessages('zh', timeago.ZhCnMessages());
  
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => FriendProvider()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
      ],
      child: MaterialApp(
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
        home: const AuthWrapper(),
      ),
    );
  }
}

// 自动登录包装器
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
    
    // 初始化通知服务
    await challengeProvider.initializeNotifications();
    
    await authProvider.tryAutoLogin();
    
    // 如果已登录，检查是否有宠物档案和今日挑战
    if (authProvider.isAuthenticated) {
      try {
        await petProvider.fetchMyPet();
        print('宠物档案加载: ${petProvider.hasPet ? "有档案" : "无档案"}');
      } catch (e) {
        print('加载宠物档案失败: $e');
      }
      
      try {
        await challengeProvider.fetchTodayChallenge();
      } catch (e) {
        print('加载今日挑战失败: $e');
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.white,
          ),
        ),
      );
    }

    return Consumer2<AuthProvider, PetProvider>(
      builder: (context, authProvider, petProvider, _) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }
        
        // 已登录但没有宠物档案，跳转到创建页面
        if (!petProvider.hasPet) {
          return const PetProfileSetupScreen();
        }
        
        // 已登录且有宠物档案，进入主页
        return const MainNavigationScreen();
      },
    );
  }
}
