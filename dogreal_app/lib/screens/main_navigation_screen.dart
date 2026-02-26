import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'feed_screen.dart';
import 'camera_screen.dart';
import 'home_screen.dart';

/// 主导航屏幕 - 带底部导航栏
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const SizedBox.shrink(), // Camera不在IndexedStack中
    const HomeScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      // 点击相机按钮，打开相机页面
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CameraScreen(),
          fullscreenDialog: true,
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.black,
          border: Border(
            top: BorderSide(
              color: AppColors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: '动态',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.camera_alt_outlined,
                  selectedIcon: Icons.camera_alt,
                  label: '相机',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: '我的',
                  index: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppColors.white : AppColors.white.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
