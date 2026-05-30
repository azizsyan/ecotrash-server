import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/auth_service.dart';
import '../../features/auth/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user      => _user;
  bool get isLoading       => _isLoading;
  String? get error        => _error;
  bool get isLoggedIn      => _user != null;
  bool get isSeller        => _user?.isSeller ?? false;
  bool get isCourier       => _user?.isCourier ?? false;

  final _authService = AuthService();

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _authService.login(email, password);
      _user = UserModel.fromJson(data['user']);

      // Simpan user info ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user_role', _user!.role);
      prefs.setString('user_name', _user!.name);
      prefs.setInt('user_id', _user!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _authService.register(
        name: name, email: email, phone: phone,
        password: password, passwordConfirmation: passwordConfirmation,
      );
      _user = UserModel.fromJson(data['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  String _parseError(dynamic e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('422')) return 'Data tidak valid. Periksa kembali inputmu.';
      if (msg.contains('401')) return 'Email atau password salah.';
      if (msg.contains('network') || msg.contains('SocketException')) {
        return 'Tidak bisa terhubung ke server.';
      }
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
