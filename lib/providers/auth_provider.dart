import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncio_capstone/services/websocket_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  AuthProvider() {
    _loadAuthStatus();
  }

  bool get isAuthenticated => _isAuthenticated;

  Future<void> signIn() async {
    _isAuthenticated = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    WebSocketService().connect();
    notifyListeners();
  }

  Future<void> signOut() async {
    _isAuthenticated = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    WebSocketService().disconnect();
    notifyListeners();
  }

  Future<void> _loadAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAuthenticated') ?? false;
  }
}
