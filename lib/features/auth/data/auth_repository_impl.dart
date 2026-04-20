import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:src/features/auth/domain/auth_repository.dart';
import 'package:src/features/auth/domain/user.dart';
import 'package:src/shared/network/api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({ApiClient? client}) : _client = client ?? ApiClient();

  static const String _userKey = 'registered_user';
  static const String _sessionKey = 'current_user_email';
  static const String _tokenKey = 'auth_token';

  final ApiClient _client;

  @override
  Future<void> register(User user) async {
    final Map<String, dynamic> response = await _client.post(
      '/auth/register',
      body: user.toJson(),
    );
    await _saveSession(_userFromResponse(response, fallback: user), response);
  }

  @override
  Future<User?> login(String email, String password) async {
    try {
      final Map<String, dynamic> response = await _client.post(
        '/auth/login',
        body: <String, dynamic>{'email': email, 'password': password},
      );
      final User user = _userFromResponse(
        response,
        fallback: User(email: email, name: '', password: password),
      );
      await _saveSession(user, response);
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User?> getRegisteredUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rawUser = prefs.getString(_userKey);
    if (rawUser == null) return null;
    final Object? decoded = jsonDecode(rawUser);
    return decoded is Map<String, dynamic> ? User.fromJson(decoded) : null;
  }

  @override
  Future<User?> getCurrentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? currentEmail = prefs.getString(_sessionKey);
    final User? user = await getRegisteredUser();
    return currentEmail == null || user == null || user.email != currentEmail
        ? null
        : user;
  }

  @override
  Future<User?> syncCurrentUser() async {
    final User? localUser = await getCurrentUser();
    try {
      final Map<String, dynamic> response = await _client.get('/auth/me');
      final User user = _userFromResponse(response, fallback: localUser);
      await _saveSession(user, response);
      return user;
    } catch (_) {
      return localUser;
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      final Map<String, dynamic> response = await _client.put(
        '/auth/me',
        body: user.toJson(),
      );
      await _saveSession(_userFromResponse(response, fallback: user), response);
    } catch (_) {
      await _saveSession(user, const <String, dynamic>{});
    }
  }

  @override
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_tokenKey);
  }

  Future<void> _saveSession(User user, Map<String, dynamic> response) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setString(_sessionKey, user.email);
    final String? token =
        response['access_token'] as String? ?? response['token'] as String?;
    if (token != null && token.isNotEmpty) {
      await prefs.setString(_tokenKey, token);
    }
  }

  User _userFromResponse(Map<String, dynamic> response, {User? fallback}) {
    final Object? rawUser = response['user'];
    if (rawUser is Map<String, dynamic>) return User.fromJson(rawUser);
    if (response.containsKey('email') && response.containsKey('name')) {
      return User.fromJson(response);
    }
    return fallback ?? const User(email: '', name: '', password: '');
  }
}
