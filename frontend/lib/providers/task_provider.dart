import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get tasks by status
  List<TaskModel> getTasksByStatus(String status) {
    return _tasks.where((task) => task.status == status).toList();
  }
  
  // Get pending tasks count
  int get pendingCount => _tasks.where((t) => t.status == 'pending').length;
  int get inProgressCount => _tasks.where((t) => t.status == 'in_progress').length;
  int get completedCount => _tasks.where((t) => t.status == 'completed').length;
  
  // Fetch all tasks
  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _apiService.getTasks();
    
    _isLoading = false;
    
    if (result['success']) {
      final List tasksJson = result['tasks'];
      _tasks = tasksJson.map((json) => TaskModel.fromJson(json)).toList();
    } else {
      _errorMessage = result['message'];
    }
    
    notifyListeners();
  }
  
  // Create task
  Future<bool> createTask(TaskModel task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _apiService.createTask(task.toJson());
    
    _isLoading = false;
    
    if (result['success']) {
      final newTask = TaskModel.fromJson(result['task']);
      _tasks.insert(0, newTask);
      notifyListeners();
      return true;
    }
    
    _errorMessage = result['message'];
    notifyListeners();
    return false;
  }
  
  // Update task
  Future<bool> updateTask(TaskModel task) async {
    if (task.id == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _apiService.updateTask(task.id!, task.toJson());
    
    _isLoading = false;
    
    if (result['success']) {
      final updatedTask = TaskModel.fromJson(result['task']);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      notifyListeners();
      return true;
    }
    
    _errorMessage = result['message'];
    notifyListeners();
    return false;
  }
  
  // Delete task
  Future<bool> deleteTask(int taskId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _apiService.deleteTask(taskId);
    
    _isLoading = false;
    
    if (result['success']) {
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
      return true;
    }
    
    _errorMessage = result['message'];
    notifyListeners();
    return false;
  }
  
  // Toggle task status
  Future<bool> toggleTaskStatus(TaskModel task) async {
    String newStatus;
    switch (task.status) {
      case 'pending':
        newStatus = 'in_progress';
        break;
      case 'in_progress':
        newStatus = 'completed';
        break;
      default:
        newStatus = 'pending';
    }
    
    return await updateTask(task.copyWith(status: newStatus));
  }
  
  // Clear tasks
  void clearTasks() {
    _tasks = [];
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
