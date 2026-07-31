import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void setErrorMessage(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    setErrorMessage('');
    try {
      UserModel? loggedInUser = await _authService.login(email, password);
      if (loggedInUser != null) {
        _user = loggedInUser;
        setLoading(false);
        return true;
      }
    } catch (e) {
      setErrorMessage(e.toString().replaceAll('Exception: ', ''));
    }
    setLoading(false);
    return false;
  }

  Future<bool> signInWithGoogle() async {
    setLoading(true);
    setErrorMessage('');
    try {
      UserModel? googleUser = await _authService.signInWithGoogle();
      if (googleUser != null) {
        _user = googleUser;
        setLoading(false);
        return true;
      }
    } catch (e) {
      setErrorMessage(e.toString().replaceAll('Exception: ', ''));
    }
    setLoading(false);
    return false;
  }

  Future<bool> adminLogin(String email, String password) async {
    setLoading(true);
    setErrorMessage('');
    try {
      UserModel? loggedInAdmin = await _authService.adminLogin(email, password);
      if (loggedInAdmin != null) {
        _user = loggedInAdmin;
        setLoading(false);
        return true;
      }
    } catch (e) {
      setErrorMessage(e.toString().replaceAll('Exception: ', ''));
    }
    setLoading(false);
    return false;
  }

  Future<bool> signUp(String name, String email, String password) async {
    setLoading(true);
    setErrorMessage('');
    try {
      UserModel? newUser = await _authService.signUp(name, email, password);
      if (newUser != null) {
        _user = newUser;
        setLoading(false);
        return true;
      }
    } catch (e) {
      setErrorMessage(e.toString().replaceAll('Exception: ', ''));
    }
    setLoading(false);
    return false;
  }

  Future<bool> resetPassword(String email) async {
    setLoading(true);
    setErrorMessage('');
    try {
      await _authService.resetPassword(email);
      setLoading(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
