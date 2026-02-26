import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';

class PetProvider with ChangeNotifier {
  final PetService _petService = PetService();
  
  Pet? _currentPet;
  bool _isLoading = false;
  String? _error;

  Pet? get currentPet => _currentPet;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPet => _currentPet != null;

  // 创建宠物档案
  Future<bool> createPet({
    required String name,
    required String breed,
    required DateTime birthday,
    required String gender,
    String? bio,
    double? weight,
    String? avatar,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pet = await _petService.createPet(
        name: name,
        breed: breed,
        birthday: birthday,
        gender: gender,
        bio: bio,
        weight: weight,
        avatar: avatar,
      );

      _currentPet = pet;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 获取我的宠物
  Future<void> fetchMyPet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pet = await _petService.getMyPet();
      _currentPet = pet;
      _error = null; // 成功加载，清除错误
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // 只在非404错误时设置error
      if (!e.toString().contains('404') && !e.toString().contains('未找到')) {
        _error = e.toString();
        print('获取宠物档案错误: $e');
      } else {
        // 404说明确实没有宠物档案，这不是错误
        _currentPet = null;
        _error = null;
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新宠物档案
  Future<bool> updatePet({
    required String petId,
    String? name,
    String? breed,
    DateTime? birthday,
    String? gender,
    String? bio,
    double? weight,
    String? avatar,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pet = await _petService.updatePet(
        petId: petId,
        name: name,
        breed: breed,
        birthday: birthday,
        gender: gender,
        bio: bio,
        weight: weight,
        avatar: avatar,
      );

      _currentPet = pet;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 清除宠物数据
  void clearPet() {
    _currentPet = null;
    _error = null;
    notifyListeners();
  }
}
