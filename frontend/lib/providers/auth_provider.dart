import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  
  // Check if user is logged in
  Future<bool> checkAuth() async {
    final token = await _apiService.getToken();
    _isAuthenticated = token != null;
    notifyListeners();
    return _isAuthenticated;
  }
  
  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _apiService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    
    _isLoading = false;
    
    if (result['success']) {
      _user = UserModel.fromJson(result['user']);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    
    _errorMessage = result['message'];
    if (result['errors'] != null) {
      final errors = result['errors'] as Map<String, dynamic>;
      _errorMessage = errors.values.first.first;
    }
    notifyListeners();
    return false;
  }
  
  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _apiService.login(
      email: email,
      password: password,
    );
    
    _isLoading = false;
    
    if (result['success']) {
      _user = UserModel.fromJson(result['user']);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    
    _errorMessage = result['message'];
    if (result['errors'] != null) {
      final errors = result['errors'] as Map<String, dynamic>;
      _errorMessage = errors.values.first.first;
    }
    notifyListeners();
    return false;
  }
  
  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await _apiService.logout();
    
    _user = null;
    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
