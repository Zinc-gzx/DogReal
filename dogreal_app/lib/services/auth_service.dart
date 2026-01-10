import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/api_config.dart';

class AuthService {
  // 注册
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'email': email,
              'password': password,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        throw ApiError.fromJson(data);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: '网络连接失败: ${e.toString()}');
    }
  }

  // 登录
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        throw ApiError.fromJson(data);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: '网络连接失败: ${e.toString()}');
    }
  }

  // 获取当前用户信息
  Future<User> getCurrentUser(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.me}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return User.fromJson(data['data']);
      } else {
        throw ApiError.fromJson(data);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(message: '网络连接失败: ${e.toString()}');
    }
  }
}
