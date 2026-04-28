import 'package:flutter/foundation.dart';
import 'package:src/features/auth/domain/auth_repository.dart';
import 'package:src/features/auth/domain/user.dart';
import 'package:src/features/auth/presentation/controllers/auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;
  AuthState _state = const AuthState();
  bool _profileLoaded = false;

  AuthState get state => _state;

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    final User? user = await _authRepository.login(email, password);
    if (user == null) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Login failed. Check email and password.',
        clearInfo: true,
      );
      notifyListeners();
      return false;
    }
    _profileLoaded = true;
    _state = _state.copyWith(
      currentUser: user,
      isLoading: false,
      info: 'Welcome back, ${user.name.isEmpty ? user.email : user.name}.',
      clearError: true,
    );
    notifyListeners();
    return true;
  }

  Future<bool> register(User user) async {
    _setLoading(true);
    try {
      await _authRepository.register(user);
      _profileLoaded = true;
      _state = _state.copyWith(
        currentUser: user,
        isLoading: false,
        info: 'Registration successful.',
        clearError: true,
      );
      notifyListeners();
      return true;
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Registration failed: $error',
        clearInfo: true,
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> loadProfile() async {
    if (_profileLoaded) return;
    _setLoading(true);
    final User? user = await _authRepository.syncCurrentUser();
    _profileLoaded = true;
    _state = _state.copyWith(
      currentUser: user,
      isLoading: false,
      clearError: true,
      clearInfo: true,
    );
    notifyListeners();
  }

  Future<bool> updateProfile(User user) async {
    _setLoading(true);
    await _authRepository.updateUser(user);
    _profileLoaded = true;
    _state = _state.copyWith(
      currentUser: user,
      isLoading: false,
      info: 'Profile updated.',
      clearError: true,
    );
    notifyListeners();
    return true;
  }

  Future<void> logOut() async {
    await _authRepository.logout();
    _profileLoaded = false;
    _state = const AuthState();
    notifyListeners();
  }

  void clearFeedback() {
    _state = _state.copyWith(clearError: true, clearInfo: true);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _state = _state.copyWith(
      isLoading: value,
      clearError: value,
      clearInfo: value,
    );
    notifyListeners();
  }
}
