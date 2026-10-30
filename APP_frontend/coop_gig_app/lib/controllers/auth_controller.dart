import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthController with ChangeNotifier {
  static const String _tokenKey = 'auth_token';

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _currentUser != null;

  bool get isWorkerPendingVerification {
    if (_currentUser == null || !_currentUser!.isWorker) return false;
    return !_currentUser!.isVerified;
  }

  AuthController() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        ApiService().setToken(_token);
        _currentUser = await ApiService().getMe();
      }
    } catch (e) {
      _token = null;
      _currentUser = null;
      ApiService().setToken(null);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiService().login(identifier: identifier, password: password);
      _token = data['token'];
      _currentUser = User.fromJson(data['user']);
      ApiService().setToken(_token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiService().register(
        name: name,
        email: email,
        mobile: mobile,
        password: password,
        role: role,
      );
      _token = data['token'];
      _currentUser = User.fromJson(data['user']);
      ApiService().setToken(_token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    if (_token == null) return;
    try {
      _currentUser = await ApiService().getMe();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    ApiService().setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }
}

