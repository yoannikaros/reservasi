import 'package:flutter/material.dart';
import 'package:reservasi/models/user.dart';
import 'package:reservasi/repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String get errorMessage => _errorMessage;

  final UserRepository _userRepository = UserRepository();

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = await _userRepository.getUserByCredentials(username, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Username atau password salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(User user) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Check if username already exists
      final existingUser = await _userRepository.getUserByCredentials(user.username, '');
      if (existingUser != null) {
        _errorMessage = 'Username sudah digunakan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Insert new user
      final userId = await _userRepository.insertUser(user);
      if (userId > 0) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal mendaftarkan user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> refreshCurrentUser() async {
    if (_currentUser == null) return;
    final user = await _userRepository.getUserById(_currentUser!.id!);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }
}
