/// Constants for Hive box names and keys
class HiveConstants {
  // Box names
  static const String userBox = 'users_box';
  static const String authBox = 'auth_box';
  static const String habitBox = 'habits_box';
  static const String userHabitsBox = 'user_habits_box';

  // Auth box keys
  static const String currentUserKey = 'current_user';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Type IDs for Hive adapters
  static const int userModelTypeId = 1;
  static const int habitModelTypeId = 2;
  static const int iconDataTypeId = 3;
}