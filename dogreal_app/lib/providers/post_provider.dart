import 'dart:io';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';

class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();

  List<Post> _feed = [];
  List<Post> _myPosts = [];
  bool _isLoading = false;
  bool _hasPostedToday = false;
  Post? _todayPost;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<Post> get feed => _feed;
  List<Post> get myPosts => _myPosts;
  bool get isLoading => _isLoading;
  bool get hasPostedToday => _hasPostedToday;
  Post? get todayPost => _todayPost;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // 获取Feed
  Future<void> fetchFeed({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _feed = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final posts = await _postService.getFeed(page: _currentPage);
      
      if (refresh) {
        _feed = posts;
      } else {
        _feed.addAll(posts);
      }

      _hasMore = posts.length >= 10;
      _currentPage++;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取我的帖子
  Future<void> fetchMyPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myPosts = await _postService.getMyPosts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 检查今天是否已发布
  Future<void> checkTodayPost() async {
    try {
      final result = await _postService.checkTodayPost();
      _hasPostedToday = result['hasPosted'];
      _todayPost = result['post'];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 点赞/取消点赞
  Future<void> toggleLike(String postId) async {
    try {
      final result = await _postService.toggleLike(postId);
      
      // 更新Feed中的帖子
      final feedIndex = _feed.indexWhere((post) => post.id == postId);
      if (feedIndex != -1) {
        final post = _feed[feedIndex];
        final updatedLikes = result['isLiked']
            ? [...post.likes, 'current_user'] // 临时添加当前用户ID
            : post.likes.where((id) => id != 'current_user').toList();
        
        _feed[feedIndex] = post.copyWith(
          likesCount: result['likesCount'],
          likes: updatedLikes,
        );
        notifyListeners();
      }

      // 更新我的帖子中的帖子
      final myPostIndex = _myPosts.indexWhere((post) => post.id == postId);
      if (myPostIndex != -1) {
        final post = _myPosts[myPostIndex];
        _myPosts[myPostIndex] = post.copyWith(
          likesCount: result['likesCount'],
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 添加评论
  Future<void> addComment(String postId, String text) async {
    try {
      final comment = await _postService.addComment(postId, text);
      
      // 更新Feed中的帖子
      final feedIndex = _feed.indexWhere((post) => post.id == postId);
      if (feedIndex != -1) {
        final post = _feed[feedIndex];
        _feed[feedIndex] = post.copyWith(
          comments: [...post.comments, comment],
          commentsCount: post.commentsCount + 1,
        );
        notifyListeners();
      }

      // 更新我的帖子中的帖子
      final myPostIndex = _myPosts.indexWhere((post) => post.id == postId);
      if (myPostIndex != -1) {
        final post = _myPosts[myPostIndex];
        _myPosts[myPostIndex] = post.copyWith(
          comments: [...post.comments, comment],
          commentsCount: post.commentsCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 创建帖子
  Future<bool> createPost({
    required String petId,
    required File frontImage,
    required File backImage,
    String? caption,
    String? location,
    bool isLate = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final post = await _postService.createPost(
        petId: petId,
        frontImage: frontImage,
        backImage: backImage,
        caption: caption,
        location: location,
        isLate: isLate,
      );

      _myPosts.insert(0, post);
      _hasPostedToday = true;
      _todayPost = post;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // 清除数据
  void clear() {
    _feed = [];
    _myPosts = [];
    _currentPage = 1;
    _hasMore = true;
    _hasPostedToday = false;
    _todayPost = null;
    _error = null;
    notifyListeners();
  }
}
