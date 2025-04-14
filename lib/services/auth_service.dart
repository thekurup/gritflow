import 'package:gritflow/hive/hive_crud.dart';
import 'package:gritflow/models/user_model.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  final UserModel? user;

  AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
  });
}

class AuthService {
  final HiveUserService _hiveUserService = HiveUserService();

  // Login method
  Future<AuthResult> login(String email, String password) async {
    try {
      final user = await _hiveUserService.verifyLogin(email, password);
      
      if (user != null) {
        return AuthResult(
          success: true,
          user: user,
        );
      } else {
        return AuthResult(
          success: false,
          errorMessage: 'Invalid email or password',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Authentication error: ${e.toString()}',
      );
    }
  }

  // Logout method
  Future<AuthResult> logout() async {
    try {
      await _hiveUserService.logout();
      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Logout error: ${e.toString()}',
      );
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _hiveUserService.isLoggedIn();
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    return await _hiveUserService.getCurrentUser();
  }
}