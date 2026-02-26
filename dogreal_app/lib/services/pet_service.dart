import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/pet.dart';
import '../utils/api_config.dart';
import 'storage_service.dart';

class ApiError implements Exception {
  final String message;
  final int? statusCode;

  ApiError(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class PetService {
  final StorageService _storage = StorageService();

  // 获取请求头
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 创建宠物档案
  Future<Pet> createPet({
    required String name,
    required String breed,
    required DateTime birthday,
    required String gender,
    String? bio,
    double? weight,
    String? avatar,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createPet}'),
            headers: headers,
            body: jsonEncode({
              'name': name,
              'breed': breed,
              'birthday': birthday.toIso8601String(),
              'gender': gender,
              'bio': bio ?? '',
              'weight': weight,
              'avatar': avatar ?? '',
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Pet.fromJson(data['data']);
      } else {
        throw ApiError(
          data['message'] ?? '创建宠物档案失败',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiError('网络连接失败，请检查网络设置');
    } on http.ClientException {
      throw ApiError('网络请求失败');
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError('创建宠物档案失败: ${e.toString()}');
    }
  }

  // 获取我的宠物
  Future<Pet?> getMyPet() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getMyPet}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Pet.fromJson(data['data']);
      } else if (response.statusCode == 404) {
        return null; // 未找到宠物档案
      } else {
        throw ApiError(
          data['message'] ?? '获取宠物信息失败',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiError('网络连接失败，请检查网络设置');
    } on http.ClientException {
      throw ApiError('网络请求失败');
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError('获取宠物信息失败: ${e.toString()}');
    }
  }

  // 更新宠物档案
  Future<Pet> updatePet({
    required String petId,
    String? name,
    String? breed,
    DateTime? birthday,
    String? gender,
    String? bio,
    double? weight,
    String? avatar,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (breed != null) body['breed'] = breed;
      if (birthday != null) body['birthday'] = birthday.toIso8601String();
      if (gender != null) body['gender'] = gender;
      if (bio != null) body['bio'] = bio;
      if (weight != null) body['weight'] = weight;
      if (avatar != null) body['avatar'] = avatar;

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.pets}/$petId'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Pet.fromJson(data['data']);
      } else {
        throw ApiError(
          data['message'] ?? '更新宠物档案失败',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiError('网络连接失败，请检查网络设置');
    } on http.ClientException {
      throw ApiError('网络请求失败');
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError('更新宠物档案失败: ${e.toString()}');
    }
  }

  // 上传头像
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final token = await _storage.getToken();
      if (token == null) {
        throw ApiError('未登录');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadAvatar}'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
          );
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data']['url'];
      } else {
        throw ApiError(
          data['message'] ?? '上传头像失败',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiError('网络连接失败，请检查网络设置');
    } on http.ClientException {
      throw ApiError('网络请求失败');
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError('上传头像失败: ${e.toString()}');
    }
  }
}
