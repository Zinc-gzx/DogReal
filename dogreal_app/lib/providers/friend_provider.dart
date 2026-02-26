import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../services/friend_service.dart';

class FriendProvider with ChangeNotifier {
  final FriendService _friendService = FriendService();

  List<Friend> _friends = [];
  List<FriendRequest> _pendingRequests = [];
  List<UserSearchResult> _searchResults = [];
  
  bool _isLoading = false;
  String? _error;

  List<Friend> get friends => _friends;
  List<FriendRequest> get pendingRequests => _pendingRequests;
  List<UserSearchResult> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get friendsCount => _friends.length;
  int get pendingRequestsCount => _pendingRequests.length;

  // 搜索用户
  Future<void> searchUsers(String query) async {
    if (query.trim().length < 2) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _friendService.searchUsers(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 清空搜索结果
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  // 发送好友请求
  Future<bool> sendFriendRequest(String recipientId) async {
    try {
      await _friendService.sendFriendRequest(recipientId);
      
      // 更新搜索结果中的状态
      final index = _searchResults.indexWhere((u) => u.id == recipientId);
      if (index != -1) {
        _searchResults[index] = UserSearchResult(
          id: _searchResults[index].id,
          username: _searchResults[index].username,
          email: _searchResults[index].email,
          friendshipStatus: 'pending',
          isRequester: true,
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 接受好友请求
  Future<bool> acceptFriendRequest(String requestId) async {
    try {
      await _friendService.acceptFriendRequest(requestId);
      
      // 从待处理列表中移除
      _pendingRequests.removeWhere((r) => r.id == requestId);
      
      // 重新获取好友列表
      await fetchMyFriends();
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 拒绝好友请求
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      await _friendService.rejectFriendRequest(requestId);
      
      // 从待处理列表中移除
      _pendingRequests.removeWhere((r) => r.id == requestId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 删除好友
  Future<bool> removeFriend(String friendshipId) async {
    try {
      await _friendService.removeFriend(friendshipId);
      
      // 从好友列表中移除
      _friends.removeWhere((f) => f.id == friendshipId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 获取我的好友列表
  Future<void> fetchMyFriends() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _friends = await _friendService.getMyFriends();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取待处理的好友请求
  Future<void> fetchPendingRequests() async {
    try {
      _pendingRequests = await _friendService.getPendingRequests();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 清空状态
  void clear() {
    _friends = [];
    _pendingRequests = [];
    _searchResults = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
