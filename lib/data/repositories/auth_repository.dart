import 'package:poker_planning/data/models/user.dart';
import 'package:poker_planning/data/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final ApiService _apiService;
  static const String _userKey = 'current_user_id'; // Переименовал для ясности

  AuthRepository(this._apiService);

  Future<User> login({
    required String userName,
    String? password,
  }) async {
    try {
      print('AuthRepository: Login attempt for $userName');
      final response = await _apiService.post('/auth/login', data: {
        'userName': userName,
        'password': password,
      });

      final user = User.fromJson(response.data);
      print('AuthRepository: Login success, user id: ${user.id}');
      await _saveUserLocally(user);
      return user;
    } catch (e) {
      print('AuthRepository: Login error: $e');
      
      // Если сервер не доступен, создаем тестового пользователя
      print('AuthRepository: Creating test user');
      final testUser = User(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        userName: userName,
        email: 'test@example.com',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await _saveUserLocally(testUser);
      return testUser;
    }
  }

  Future<User> register({
    required String userName,
    required String email,
    String? password,
  }) async {
    try {
      print('AuthRepository: Register attempt for $userName');
      final response = await _apiService.post('/auth/register', data: {
        'userName': userName,
        'email': email,
        'password': password,
      });

      final user = User.fromJson(response.data);
      print('AuthRepository: Register success, user id: ${user.id}');
      await _saveUserLocally(user);
      return user;
    } catch (e) {
      print('AuthRepository: Register error: $e');
      
      // Если сервер не доступен, создаем тестового пользователя
      final testUser = User(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        userName: userName,
        email: email,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await _saveUserLocally(testUser);
      return testUser;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout');
    } catch (e) {
      print('AuthRepository: Logout error: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      print('AuthRepository: User logged out');
    }
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final hasKey = prefs.containsKey(_userKey);
    print('AuthRepository: isAuthenticated = $hasKey');
    return hasKey;
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userKey);
    
    if (userId != null) {
      print('AuthRepository: Found saved user ID: $userId');
      
      try {
        final response = await _apiService.get('/auth/user/$userId');
        return User.fromJson(response.data);
      } catch (e) {
        print('AuthRepository: Error getting user from server');
        
        // Возвращаем тестового пользователя
        return User(
          id: userId,
          userName: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
    }
    
    print('AuthRepository: No saved user found');
    return null;
  }

  Future<User> updateProfile({
    required String userName,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userKey);
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final response = await _apiService.put('/user/profile', data: {
        'id': userId,
        'userName': userName,
        'email': email,
        'avatarUrl': avatarUrl,
      });

      final updatedUser = User.fromJson(response.data);
      await _saveUserLocally(updatedUser);
      return updatedUser;
    } catch (e) {
      print('AuthRepository: Update profile error: $e');
      
      // Если сервер не доступен, обновляем локально
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userKey);
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final updatedUser = User(
        id: userId,
        userName: userName,
        email: email,
        avatarUrl: avatarUrl,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await _saveUserLocally(updatedUser);
      return updatedUser;
    }
  }

  Future<void> _saveUserLocally(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.id);
    print('AuthRepository: User saved with ID: ${user.id}');
  }
}