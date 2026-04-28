import 'package:src/features/auth/domain/user.dart';

class AuthState {
  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.error,
    this.info,
  });

  final User? currentUser;
  final bool isLoading;
  final String? error;
  final String? info;

  AuthState copyWith({
    User? currentUser,
    bool? isLoading,
    String? error,
    String? info,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      info: clearInfo ? null : info ?? this.info,
    );
  }
}
