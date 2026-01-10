class ApiConfig {
  // 开发环境 - 使用本地 IP 地址，因为模拟器无法访问 localhost
  static const String baseUrl = 'http://localhost:3000/api/v1';
  
  // 如果在真机测试，需要使用你的 Mac 的局域网 IP 地址
  // static const String baseUrl = 'http://YOUR_MAC_IP:3000/api/v1';
  
  // 超时时间
  static const Duration timeout = Duration(seconds: 30);
  
  // API 端点
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
}
