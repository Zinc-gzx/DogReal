import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../utils/api_config.dart';
import 'storage_service.dart';

class ApiError implements Exception {
  final String message;
  final int? statusCode;

  ApiError(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class PostService {
  final StorageService _storage = StorageService();

  // 获取请求头
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 获取Feed
  Future<List<Post>> getFeed({int page = 1, int limit = 10}) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(
                '${ApiConfig.baseUrl}${ApiConfig.feed}?page=$page&limit=$limit'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> postsJson = data['data'];
        return postsJson.map((json) => Post.fromJson(json)).toList();
      } else {
        throw ApiError(
          data['message'] ?? '获取Feed失败',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiError('网络连接失败，请检查网络设置');
    } on http.ClientException {
      throw ApiError('网络请求失败');
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError('获取Feed失败: ${e.toString()}');
    }
  }

  // 获取我的帖子
  Future<List<Post>> getMyPosts() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.myPosts}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> postsJson = data['data'];
        return postsJson.map((json) => Post.fromJson(json)).toList();
      } else {
        throw ApiError(
          data['message'] ?? '获取帖子失败',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiError('网络连接失败，请检查网络设置');
    } on http.ClientException {
      throw ApiError('网络请求失败');
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError('获取帖子失败: ${e.toString()}');
    }
  }

  // 检查今天是否已发布
  Future<Map<String, dynamic>> checkTodayPost() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.checkToday}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'hasPosted': data['data']['hasPostedToday'],
          'post': data['data']['post'] != null
              ? Post.fromJson(data['data']['post'])
              : null,
        };
      } else {
        throw ApiError(
          data['message'] ?? '检查失败',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiError('网络连接失败，请检查网络设置');
    } on http.ClientException {
      throw ApiError('网络请求失败');
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError('检查失败: ${e.toString()}');
    }
  }

  // 点赞/取消点赞
  Future<Map<String, dynamic>> toggleLike(String postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/posts/$postId/like'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'isLiked': data['data']['isLiked'],
          'likesCount': data['data']['likesCount'],
        };
      } else {
        throw ApiError(
          data['message'] ?? '操作失败',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiError('网络连接失败，请检查网络设置');
    } on http.ClientException {
      throw ApiError('网络请求失败');
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError('操作失败: ${e.toString()}');
    }
  }

  // 添加评论
  Future<Comment> addComment(String postId, String text) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/posts/$postId/comment'),
            headers: headers,
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return Comment.fromJson(data['data']);
      } else {
        throw ApiError(
          data['message'] ?? '评论失败',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiError('网络连接失败，请检查网络设置');
    } on http.ClientException {
      throw ApiError('网络请求失败');
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError('评论失败: ${e.toString()}');
    }
  }

  // 创建帖子（上传图片）
  Future<Post> createPost({
    required String petId,
    required File frontImage,
    required File backImage,
    String? caption,
    String? location,
    bool isLate = false,
  }) async {
    try {
      final token = await _storage.getToken();

      if (token == null || token.isEmpty) {
        throw ApiError('请先登录');
      }

      // 首先上传前置照片
      final frontImageUrl = await _uploadImage(frontImage, token);
      
      // 然后上传后置照片
      final backImageUrl = await _uploadImage(backImage, token);

      // 构建images数组
      final images = [
        {'url': backImageUrl, 'type': 'back'},
        {'url': frontImageUrl, 'type': 'front'},
      ];

      // 创建帖子
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createPost}'),
            headers: headers,
            body: jsonEncode({
              'petId': petId,
              'images': images,
              'caption': caption ?? '',
              'location': location ?? '',
              'isLate': isLate,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return Post.fromJson(data['data']);
      } else {
        throw ApiError(
          data['message'] ?? '发布失败',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiError('网络连接失败，请检查网络设置');
    } on http.ClientException {
      throw ApiError('网络请求失败');
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError('发布失败: ${e.toString()}');
    }
  }

  // 上传单张图片
  Future<String> _uploadImage(File image, String token) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadImage}'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data']['url'];
      } else {
        throw ApiError(
          data['message'] ?? '图片上传失败',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError('图片上传失败: ${e.toString()}');
    }
  }
}
