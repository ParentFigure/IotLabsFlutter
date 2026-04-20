import 'package:src/features/auth/domain/user.dart';

abstract class AuthRepository {
  Future<void> register(User user);
  Future<User?> login(String email, String password);
  Future<User?> getRegisteredUser();
  Future<User?> getCurrentUser();
  Future<User?> syncCurrentUser();
  Future<void> updateUser(User user);
  Future<void> logout();
}
