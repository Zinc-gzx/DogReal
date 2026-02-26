import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/challenge.dart';
import '../utils/api_config.dart';
import 'storage_service.dart';

class ChallengeService {
  final StorageService _storage = StorageService();
  
  // 获取今日挑战
  Future<Challenge> getTodayChallenge() async {
    try {
      final token = await _storage.getToken();
      if (token == null) {
        throw Exception('未登录');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.todayChallenge}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Challenge.fromJson(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? '获取今日挑战失败');
      }
    } catch (e) {
      throw Exception('获取今日挑战失败: $e');
    }
  }

  // 获取挑战历史
  Future<List<Challenge>> getChallengeHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await _storage.getToken();
      if (token == null) {
        throw Exception('未登录');
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.challengeHistory}?page=$page&limit=$limit',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> challengesJson = data['data']['challenges'];
        return challengesJson.map((json) => Challenge.fromJson(json)).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? '获取挑战历史失败');
      }
    } catch (e) {
      throw Exception('获取挑战历史失败: $e');
    }
  }
}
