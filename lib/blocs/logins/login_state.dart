// This file Represents the current UI state including form values, loading status, and error messages.
// ✅ It defines the LoginState class that holds all the data needed to render the UI correctly.

import 'package:equatable/equatable.dart';
// ✅ This imports the Equatable package, which helps compare objects based on their values rather than their references.
// It's used to efficiently determine when the state has actually changed to avoid unnecessary UI rebuilds.

import 'package:gritflow/models/user_model.dart';
// ✅ NEW: This imports the UserModel class which represents a user in the Hive database.
// It's used to store the currently logged-in user's information for display and access.

enum LoginStatus { initial, loading, success, failure, invalidCredentials }
// ✅ This defines an enumeration (a fixed set of named values) for the different states the login process can be in.
// - initial: The default state when the login screen first loads
// - loading: The state when a login attempt is in progress
// - success: The state when login has succeeded
// - failure: The state when login has failed
// - invalidCredentials: NEW: A specific failure state for when the email/password don't match or user doesn't exist
// ✅ NEW: Added 'invalidCredentials' status to differentiate between authentication errors and other failures.
// This allows for more specific error messages and UI handling for credential issues.

class LoginState extends Equatable {
  // ✅ This defines the LoginState class that contains all the data needed for the login screen.
  // It extends Equatable to enable value-based comparison of states.
  
  final String username;
  // ✅ UPDATED: Changed from email to username to support username-based login.
  // This field stores the current value of the username input field. It's marked final because
  // each state object is immutable - instead of changing values, we create new state objects.
  
  final String password;
  // ✅ This field stores the current value of the password input field. It's also immutable.
  
  final LoginStatus status;
  // ✅ This field stores the current status of the login process using the LoginStatus enum.
  // The UI will show different elements based on this status (like a loading spinner or error message).
  
  final String? errorMessage;
  // ✅ This field stores any error message that should be displayed to the user.
  // It's nullable (String?) because there might not be an error message to show.

  final UserModel? user;
  // ✅ NEW: This field stores the currently logged-in user's information from the Hive database.
  // It's nullable because there might not be a logged-in user yet.
  // This allows the UI to display user-specific information and check login status.

  final bool isRememberMe;
  // ✅ NEW: This field stores whether the user has selected the "Remember Me" option.
  // When true, the user's username will be remembered for future login attempts.
  // This enhances user experience by making returning to the app easier.
  // ✅ UPDATED: Now remembers username instead of email.

  const LoginState({
    this.username = '',
    // ✅ UPDATED: Changed from email to username in the constructor parameter.
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.user,
    this.isRememberMe = false,
    // ✅ NEW: Added user parameter that defaults to null
    // ✅ NEW: Added isRememberMe parameter that defaults to false
  });
  // ✅ This is the constructor for LoginState. It has optional parameters with default values:
  // - username defaults to an empty string (UPDATED: changed from email)
  // - password defaults to an empty string
  // - status defaults to LoginStatus.initial
  // - errorMessage defaults to null (no error)
  // - user defaults to null (no logged-in user)
  // - isRememberMe defaults to false
  // The "const" keyword allows instances to be compile-time constants for better performance.

  LoginState copyWith({
    String? username,
    // ✅ UPDATED: Changed from email to username in the copyWith parameter.
    String? password,
    LoginStatus? status,
    String? errorMessage,
    UserModel? user,
    bool? isRememberMe,
    // ✅ NEW: Added user parameter for copying with a user object
    // ✅ NEW: Added isRememberMe parameter for updating remember me preference
  }) {
    // ✅ This method creates a new LoginState with some values changed and others preserved.
    // It's a common pattern in immutable programming and makes state updates cleaner.
    // All parameters are optional, so you only need to specify the values you want to change.
    
    return LoginState(
      username: username ?? this.username,
      // ✅ UPDATED: Changed from email to username in the return statement.
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: user ?? this.user,
      isRememberMe: isRememberMe ?? this.isRememberMe,
      // ✅ NEW: Included user in the new state object
      // ✅ NEW: Included isRememberMe in the new state object
    );
    // ✅ This creates and returns a new LoginState with updated values.
    // The ?? operator is the "null-coalescing" operator:
    // - If the parameter is not null, use the new value
    // - If the parameter is null, keep the current value from "this.field"
    // Note that errorMessage doesn't use ??, so passing null explicitly clears any error message.
  }

  @override
  List<Object?> get props => [username, password, status, errorMessage, user, isRememberMe];
  // ✅ This overrides the props getter from Equatable to specify which properties should be used for equality comparison.
  // When any of these values change, the state is considered different, which triggers a UI update.
  // The List<Object?> type means it can contain null values (for the nullable errorMessage and user).
  // ✅ NEW: Added user and isRememberMe to the properties list so changes to these will be detected.
  // ✅ UPDATED: Changed from email to username in the props list.
}