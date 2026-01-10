import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  // 注册
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authService.register(
        username: username,
        email: email,
        password: password,
      );

      if (response.success && response.user != null && response.token != null) {
        _user = response.user;
        _token = response.token;

        // 保存到本地存储
        await _storageService.saveAuthData(
          token: response.token!,
          userId: response.user!.id,
          username: response.user!.username,
          email: response.user!.email,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiError catch (e) {
      _error = e.message;
      if (e.errors != null && e.errors!.isNotEmpty) {
        _error = e.errors!.map((err) => err.message).join('\n');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '注册失败: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 登录
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success && response.user != null && response.token != null) {
        _user = response.user;
        _token = response.token;

        // 保存到本地存储
        await _storageService.saveAuthData(
          token: response.token!,
          userId: response.user!.id,
          username: response.user!.username,
          email: response.user!.email,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiError catch (e) {
      _error = e.message;
      if (e.errors != null && e.errors!.isNotEmpty) {
        _error = e.errors!.map((err) => err.message).join('\n');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '登录失败: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 自动登录（从本地存储恢复）
  Future<bool> tryAutoLogin() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return false;

      _token = token;
      
      // 从后端获取用户信息
      _user = await _authService.getCurrentUser(token);
      
      notifyListeners();
      return true;
    } catch (e) {
      // Token 可能过期，清除本地数据
      await logout();
      return false;
    }
  }

  // 登出
  Future<void> logout() async {
    _user = null;
    _token = null;
    _error = null;
    await _storageService.clearAll();
    notifyListeners();
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
