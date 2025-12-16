import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  // Save token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  // Delete token
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
  
  // Get headers with auth token
  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (withAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}'),
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 && data['success'] == true) {
        await saveToken(data['data']['token']);
        return {'success': true, 'user': data['data']['user']};
      }
      
      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
        'errors': data['errors'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
  
  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        await saveToken(data['data']['token']);
        return {'success': true, 'user': data['data']['user']};
      }
      
      return {
        'success': false,
        'message': data['message'] ?? 'Login failed',
        'errors': data['errors'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
  
  // Logout
  Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logout}'),
        headers: await _getHeaders(),
      );
      
      await deleteToken();
      return response.statusCode == 200;
    } catch (e) {
      await deleteToken();
      return false;
    }
  }
  
  // Get Tasks
  Future<Map<String, dynamic>> getTasks() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.tasks}'),
        headers: await _getHeaders(),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'tasks': data['data']};
      }
      
      return {'success': false, 'message': data['message'] ?? 'Failed to load tasks'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
  
  // Create Task
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.tasks}'),
        headers: await _getHeaders(),
        body: jsonEncode(taskData),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'task': data['data']};
      }
      
      return {'success': false, 'message': data['message'] ?? 'Failed to create task'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
  
  // Update Task
  Future<Map<String, dynamic>> updateTask(int taskId, Map<String, dynamic> taskData) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.tasks}/$taskId'),
        headers: await _getHeaders(),
        body: jsonEncode(taskData),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'task': data['data']};
      }
      
      return {'success': false, 'message': data['message'] ?? 'Failed to update task'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
  
  // Delete Task
  Future<Map<String, dynamic>> deleteTask(int taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.tasks}/$taskId'),
        headers: await _getHeaders(),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      }
      
      return {'success': false, 'message': data['message'] ?? 'Failed to delete task'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
