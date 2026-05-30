import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import 'models/user_model.dart';

class AuthService {
  final _client = ApiClient();

  /// POST /api/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _client.dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    final token = res.data['token'] as String;
    await _client.saveToken(token);
    return res.data;
  }

  /// POST /api/register (default role = seller)
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _client.dio.post('/register', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    final token = res.data['token'] as String;
    await _client.saveToken(token);
    return res.data;
  }

  /// POST /api/logout
  Future<void> logout() async {
    try {
      await _client.dio.post('/logout');
    } catch (_) {}
    await _client.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _client.getToken();
    return token != null;
  }
}
