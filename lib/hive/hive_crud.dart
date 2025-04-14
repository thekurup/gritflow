import 'package:hive/hive.dart';
import 'package:gritflow/hive/hive_constants.dart';
import 'package:gritflow/models/user_model.dart';

class HiveUserService {
  // Get reference to the users box
  Future<Box<UserModel>> get _usersBox async =>
      await Hive.openBox<UserModel>(HiveConstants.userBox);

  // Get reference to the auth box (for login state)
  Future<Box> get _authBox async =>
      await Hive.openBox(HiveConstants.authBox);

  // Create a new user
  Future<bool> createUser(UserModel user) async {
    final box = await _usersBox;
    
    // Check if email already exists
    final existingUser = await getUserByEmail(user.email);
    if (existingUser != null) {
      return false; // User already exists
    }
    
    // Check if username already exists
    final existingUsername = await getUserByUsername(user.username);
    if (existingUsername != null) {
      return false; // Username already exists
    }
    
    // Save the user using email as key
    await box.put(user.email, user);
    return true;
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    final box = await _usersBox;
    return box.get(email);
  }

  // Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    final box = await _usersBox;
    
    // Since we store users with email as key, we need to iterate through all users
    final allUsers = box.values.toList();
    for (var user in allUsers) {
      if (user.username.toLowerCase() == username.toLowerCase()) {
        return user;
      }
    }
    return null;
  }

  // Verify login credentials with username
  Future<UserModel?> verifyLogin(String username, String password) async {
    // Try to get user by username
    final user = await getUserByUsername(username);
    
    if (user != null && user.password == password) {
      // Set logged in state
      final authBox = await _authBox;
      await authBox.put(HiveConstants.isLoggedInKey, true);
      await authBox.put(HiveConstants.currentUserKey, user.email);
      return user;
    }
    return null;
  }

  // Verify login credentials with email (keeping for backward compatibility)
  Future<UserModel?> verifyLoginWithEmail(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user != null && user.password == password) {
      // Set logged in state
      final authBox = await _authBox;
      await authBox.put(HiveConstants.isLoggedInKey, true);
      await authBox.put(HiveConstants.currentUserKey, user.email);
      return user;
    }
    return null;
  }

  // Get currently logged in user
  Future<UserModel?> getCurrentUser() async {
    final authBox = await _authBox;
    final isLoggedIn = authBox.get(HiveConstants.isLoggedInKey, defaultValue: false);
    
    if (isLoggedIn) {
      final userEmail = authBox.get(HiveConstants.currentUserKey);
      if (userEmail != null) {
        return await getUserByEmail(userEmail);
      }
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final authBox = await _authBox;
    return authBox.get(HiveConstants.isLoggedInKey, defaultValue: false);
  }

  // Logout user
  Future<void> logout() async {
    final authBox = await _authBox;
    await authBox.put(HiveConstants.isLoggedInKey, false);
    await authBox.delete(HiveConstants.currentUserKey);
  }

  // Update user details
  Future<void> updateUser(UserModel user) async {
    final box = await _usersBox;
    await box.put(user.email, user);
  }

  // Delete user
  Future<void> deleteUser(String email) async {
    final box = await _usersBox;
    await box.delete(email);
  }
  
  // Get all users (for admin purposes or debugging)
  Future<List<UserModel>> getAllUsers() async {
    final box = await _usersBox;
    return box.values.toList();
  }
  
  // Check if username exists
  Future<bool> usernameExists(String username) async {
    final user = await getUserByUsername(username);
    return user != null;
  }
}