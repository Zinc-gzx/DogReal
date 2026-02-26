import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/friend.dart';
import '../utils/api_config.dart';
import 'storage_service.dart';

class FriendService {
  final StorageService _storage = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 搜索用户
  Future<List<UserSearchResult>> searchUsers(String query) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/friends/search?query=$query'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List users = data['data'] ?? [];
        return users.map((u) => UserSearchResult.fromJson(u)).toList();
      } else {
        throw Exception(data['message'] ?? '搜索失败');
      }
    } catch (e) {
      throw Exception('搜索失败: $e');
    }
  }

  // 发送好友请求
  Future<void> sendFriendRequest(String recipientId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/friends/request'),
            headers: headers,
            body: jsonEncode({'recipientId': recipientId}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode != 201) {
        throw Exception(data['message'] ?? '发送请求失败');
      }
    } catch (e) {
      throw Exception('发送请求失败: $e');
    }
  }

  // 接受好友请求
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/friends/accept/$requestId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? '接受请求失败');
      }
    } catch (e) {
      throw Exception('接受请求失败: $e');
    }
  }

  // 拒绝好友请求
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/friends/reject/$requestId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? '拒绝请求失败');
      }
    } catch (e) {
      throw Exception('拒绝请求失败: $e');
    }
  }

  // 删除好友
  Future<void> removeFriend(String friendshipId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/friends/$friendshipId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? '删除好友失败');
      }
    } catch (e) {
      throw Exception('删除好友失败: $e');
    }
  }

  // 获取我的好友列表
  Future<List<Friend>> getMyFriends() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/friends/my-friends'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List friends = data['data'] ?? [];
        return friends.map((f) => Friend.fromJson(f)).toList();
      } else {
        throw Exception(data['message'] ?? '获取好友列表失败');
      }
    } catch (e) {
      throw Exception('获取好友列表失败: $e');
    }
  }

  // 获取待处理的好友请求
  Future<List<FriendRequest>> getPendingRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/friends/pending'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List requests = data['data'] ?? [];
        return requests.map((r) => FriendRequest.fromJson(r)).toList();
      } else {
        throw Exception(data['message'] ?? '获取请求列表失败');
      }
    } catch (e) {
      throw Exception('获取请求列表失败: $e');
    }
  }
}
