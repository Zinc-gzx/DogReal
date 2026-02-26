import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';
import '../services/notification_service.dart';

class ChallengeProvider with ChangeNotifier {
  final ChallengeService _challengeService = ChallengeService();
  final NotificationService _notificationService = NotificationService();

  Challenge? _todayChallenge;
  List<Challenge> _challengeHistory = [];
  bool _isLoading = false;
  String? _error;

  Challenge? get todayChallenge => _todayChallenge;
  List<Challenge> get challengeHistory => _challengeHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 获取今日挑战
  Future<void> fetchTodayChallenge() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayChallenge = await _challengeService.getTodayChallenge();
      
      // 安排今日挑战通知
      if (_todayChallenge != null) {
        await _notificationService.scheduleTodayChallengeNotification(
          theme: _todayChallenge!.theme,
          icon: _todayChallenge!.icon,
          notificationTime: _todayChallenge!.notificationTime,
        );
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取挑战历史
  Future<void> fetchChallengeHistory({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final challenges = await _challengeService.getChallengeHistory(
        page: page,
        limit: 10,
      );
      
      if (page == 1) {
        _challengeHistory = challenges;
      } else {
        _challengeHistory.addAll(challenges);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 清空数据
  void clear() {
    _todayChallenge = null;
    _challengeHistory = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // 初始化通知服务
  Future<void> initializeNotifications() async {
    try {
      await _notificationService.initialize();
      await _notificationService.requestPermissions();
    } catch (e) {
      print('Initialize notifications error: $e');
    }
  }
}
