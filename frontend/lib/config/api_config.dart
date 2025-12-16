// API Configuration
class ApiConfig {
  // For Chrome/Web testing, use localhost
  // For Android emulator, use 10.0.2.2
  // For real device, use your computer's IP (e.g., 192.168.1.x)
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // Endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String tasks = '/tasks';
}
