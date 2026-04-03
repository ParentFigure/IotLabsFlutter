import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:src/features/auth/domain/auth_repository.dart';
import 'package:src/features/auth/domain/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _userKey = 'registered_user';
  static const String _sessionKey = 'current_user_email';

  @override
  Future<void> register(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setString(_sessionKey, user.email);
  }

  @override
  Future<User?> login(String email, String password) async {
    final User? user = await getRegisteredUser();

    if (user == null) {
      return null;
    }

    final bool isValidCredentials =
        user.email == email.trim() && user.password == password;

    if (!isValidCredentials) {
      return null;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, user.email);

    return user;
  }

  @override
  Future<User?> getRegisteredUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rawUser = prefs.getString(_userKey);

    if (rawUser == null) {
      return null;
    }

    final Object? decoded = jsonDecode(rawUser);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return User.fromJson(decoded);
  }

  @override
  Future<User?> getCurrentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? currentEmail = prefs.getString(_sessionKey);
    final User? user = await getRegisteredUser();

    if (currentEmail == null || user == null) {
      return null;
    }

    if (user.email != currentEmail) {
      return null;
    }

    return user;
  }

  @override
  Future<void> updateUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setString(_sessionKey, user.email);
  }

  @override
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
