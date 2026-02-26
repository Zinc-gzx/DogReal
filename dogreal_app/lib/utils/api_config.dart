/*
 * @Description: 
 * @Author: gaozhixin
 * @Date: 2025-12-19 17:56:51
 * @LastEditTime: 2026-02-04 20:00:54
 * @LastEditors: gaozhixin
 */
class ApiConfig {
  // 🔧 环境配置 - 部署前请修改这里
  // ============================================
  
  // 模拟器调试（Mac本地开发）
  static const String _simulatorUrl = 'http://localhost:3000/api';
  
  // 真机调试（需要Mac和手机在同一WiFi）
  // 运行命令获取IP: ipconfig getifaddr en0
  static const String _deviceUrl = 'http://192.168.3.7:3000/api';
  
  // 生产环境（阿里云服务器）
  static const String _productionUrl = 'http://47.243.74.253:3000/api';
  
  // ============================================
  // 当前使用的环境（根据需要修改）
  // ============================================
  // static const String baseUrl = _simulatorUrl;  // 模拟器调试
  // static const String baseUrl = _deviceUrl;   // 真机局域网调试
  static const String baseUrl = _productionUrl; // 🚀 生产环境（阿里云）
  
  // 超时时间
  static const Duration timeout = Duration(seconds: 30);
  
  // Auth API 端点
  static String get register => '/auth/register';
  static String get login => '/auth/login';
  static String get me => '/auth/me';
  
  // Pet API 端点
  static String get pets => '/pets';
  static String get createPet => '/pets';
  static String get getMyPet => '/pets/my-pet';
  
  // Post API 端点
  static String get posts => '/posts';
  static String get createPost => '/posts';
  static String get feed => '/posts/feed';
  static String get myPosts => '/posts/my-posts';
  static String get checkToday => '/posts/check-today';
  
  // Upload API 端点
  static String get uploadAvatar => '/upload/avatar';
  static String get uploadImage => '/upload/image';
  
  // Challenge API 端点
  static String get todayChallenge => '/challenges/today';
  static String get challengeHistory => '/challenges/history';
  
  // Friend API 端点
  static String get searchUsers => '/friends/search';
  static String get sendFriendRequest => '/friends/request';
  static String get acceptFriendRequest => '/friends/accept';
  static String get rejectFriendRequest => '/friends/reject';
  static String get removeFriend => '/friends/remove';
  static String get myFriends => '/friends/my-friends';
  static String get pendingRequests => '/friends/pending';
}
