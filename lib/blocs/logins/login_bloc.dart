// Contains the business logic that processes events and emits new states.
// ✅ It holds the BLoC (Business Logic Component) that handles all login-related business logic.

import 'package:flutter_bloc/flutter_bloc.dart';
// ✅ This imports the core BLoC package, which provides the Bloc class that we'll extend to create our login logic handler.

import 'package:gritflow/blocs/logins/login_event.dart';
// ✅ This imports the login events (like LoginUsernameChanged, LoginPasswordChanged, LoginSubmitted) that this BLoC will respond to.
// ✅ UPDATED: References reflect the change from email-based to username-based events.

import 'package:gritflow/blocs/logins/login_state.dart';
// ✅ This imports the LoginState class that defines what data the BLoC maintains and emits to the UI.

import 'package:gritflow/services/auth_service.dart';
// ✅ This imports the AuthService that handles the actual authentication API calls or logic.

import 'package:gritflow/hive/hive_crud.dart';
// ✅ NEW: This imports the HiveUserService to interact with the local Hive database.
// It provides methods to create, read, update and delete user data stored locally.

import 'package:shared_preferences/shared_preferences.dart';
// ✅ NEW: This imports SharedPreferences which is used to store simple data like the "Remember Me" setting.
// While Hive is used for more complex data storage, SharedPreferences is simpler for basic preferences.

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  // ✅ This defines the LoginBloc class that extends Bloc with LoginEvent as input type and LoginState as output type.
  // It processes login events and emits login states.
  
  final AuthService _authService = AuthService();
  // ✅ This creates an instance of the AuthService to handle the actual authentication. It's a private field (with _).
  
  final HiveUserService _userService = HiveUserService();
  // ✅ NEW: This creates an instance of the HiveUserService to handle interactions with the Hive database.
  // It's used to verify login credentials, retrieve user data, and manage session state.

  LoginBloc() : super(const LoginState()) {
    // ✅ This is the constructor that initializes the BLoC with an empty default LoginState.
    // The 'super' call passes the initial state to the parent Bloc class.
    
    on<LoginUsernameChanged>(_onUsernameChanged);
    // ✅ UPDATED: Changed from _onEmailChanged to _onUsernameChanged to handle username input events.
    // This registers the _onUsernameChanged handler to respond when a LoginUsernameChanged event is added to the BLoC.
    
    on<LoginPasswordChanged>(_onPasswordChanged);
    // ✅ This registers the _onPasswordChanged handler to respond when a LoginPasswordChanged event is added to the BLoC.
    
    on<LoginRememberMeChanged>(_onRememberMeChanged);
    // ✅ NEW: This registers the handler for the "Remember Me" checkbox toggle event.
    // It will update the state when the user decides whether to remember their login.
    
    on<LoginCheckSavedCredentials>(_onCheckSavedCredentials);
    // ✅ NEW: This registers the handler for checking if there are saved credentials.
    // It's triggered when the login screen first loads to potentially auto-fill the form.
    
    on<LoginSubmitted>(_onSubmitted);
    // ✅ This registers the _onSubmitted handler to respond when a LoginSubmitted event is added to the BLoC.
    
    on<LoginClearError>(_onClearError);
    // ✅ NEW: This registers a handler for clearing error messages from the state.
    // It allows the UI to reset error states when appropriate.
    
    on<LogoutRequested>(_onLogoutRequested);
    // ✅ NEW: This registers a handler for processing logout requests.
    // It will clear session data from Hive when the user logs out.
  }

  void _onUsernameChanged(LoginUsernameChanged event, Emitter<LoginState> emit) {
    // ✅ UPDATED: Changed from _onEmailChanged to _onUsernameChanged to handle the LoginUsernameChanged event.
    // This method is called when the user types in the username field.
    // It takes the event and an emitter that allows it to output new states.
    
    emit(state.copyWith(username: event.username));
    // ✅ UPDATED: Changed from email to username to update the username value in the state.
    // This creates a new state with the updated username value and emits it to the UI.
    // The copyWith method creates a copy of the current state but with the username field changed.
  }

  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    // ✅ This method handles the LoginPasswordChanged event, which occurs when the user types in the password field.
    
    emit(state.copyWith(password: event.password));
    // ✅ This creates a new state with the updated password value and emits it to the UI.
    // Similar to _onUsernameChanged, it uses copyWith to preserve other state values.
  }

  void _onRememberMeChanged(LoginRememberMeChanged event, Emitter<LoginState> emit) {
    // ✅ NEW: This method handles the LoginRememberMeChanged event, which occurs when the user toggles the "Remember Me" checkbox.
    // It updates the isRememberMe value in the state.
    
    emit(state.copyWith(isRememberMe: event.rememberMe));
    // ✅ NEW: This creates a new state with the updated remember me preference and emits it to the UI.
    // This allows the login form to track whether the user wants their credentials remembered.
  }

  Future<void> _onCheckSavedCredentials(
    LoginCheckSavedCredentials event, 
    Emitter<LoginState> emit
  ) async {
    // ✅ NEW: This method checks for previously saved login credentials when the login screen loads.
    // It retrieves username and "remember me" setting from SharedPreferences if available.
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberedUsername = prefs.getString('remembered_username');
      // ✅ UPDATED: Changed from 'remembered_email' to 'remembered_username' key.
      final rememberMe = prefs.getBool('remember_me') ?? false;
      
      if (rememberedUsername != null && rememberMe) {
        // If we have a saved username and remember me was enabled, update the state
        emit(state.copyWith(
          username: rememberedUsername,
          // ✅ UPDATED: Changed from email to username when setting the state.
          isRememberMe: true,
        ));
      }
      
      // Check if the user is already logged in
      final isLoggedIn = await _userService.isLoggedIn();
      if (isLoggedIn) {
        final currentUser = await _userService.getCurrentUser();
        if (currentUser != null) {
          // If user is logged in, update state with user data and success status
          emit(state.copyWith(
            user: currentUser,
            status: LoginStatus.success,
          ));
        }
      }
    } catch (e) {
      // If there's an error checking saved credentials, just continue with empty form
      // No need to show an error to the user in this case
    }
    // ✅ NEW: This code checks for both saved credentials (for form auto-fill) and active login sessions.
    // It enables a seamless experience where returning users don't need to log in again if their session is still valid.
  }

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    // ✅ This method handles the LoginSubmitted event, which occurs when the user taps the login button.
    // It's async because it makes an API call that returns a Future.
    
    if (event.username.isEmpty || event.password.isEmpty) {
      // ✅ UPDATED: Changed from event.email to event.username to check if the username is empty.
      // This checks if either the username or password is empty. If either is empty, login should not proceed.
      
      emit(state.copyWith(
        errorMessage: 'Username and password cannot be empty',
        // ✅ UPDATED: Changed from 'Email and password cannot be empty' to 'Username and password cannot be empty'.
        status: LoginStatus.failure,
      ));
      // ✅ This emits a failure state with an error message when validation fails.
      // The LoginStatus.failure enum value indicates the login attempt failed.
      
      return;
      // ✅ This exits the method early to prevent the rest of the login logic from executing.
    }

    emit(state.copyWith(status: LoginStatus.loading));
    // ✅ This emits a loading state to show a progress indicator in the UI while the login request is processing.

    try {
      // ✅ This starts a try-catch block to handle any errors that might occur during the login process.
      
      // ✅ NEW: Save the remember me preference and username if requested
      if (event.rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('remembered_username', event.username);
        // ✅ UPDATED: Changed from 'remembered_email' to 'remembered_username' and from event.email to event.username.
        await prefs.setBool('remember_me', true);
      } else {
        // Clear saved credentials if remember me is turned off
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('remembered_username');
        // ✅ UPDATED: Changed from 'remembered_email' to 'remembered_username'.
        await prefs.setBool('remember_me', false);
      }
      // ✅ NEW: This code saves or clears the user's username in SharedPreferences based on the "Remember Me" setting.
      // This persistence allows the app to pre-fill the username field when the user returns.
      
      // ✅ NEW: Verify login with Hive instead of simulated delay
      final user = await _userService.verifyLogin(event.username, event.password);
      // ✅ UPDATED: Changed from event.email to event.username when verifying login credentials.
      // This replaces the simulated API call with a real check against the Hive database.
      // It checks if the provided credentials match a stored user.
      
      if (user != null) {
        // ✅ NEW: If user is found and password matches, login is successful
        emit(state.copyWith(
          status: LoginStatus.success,
          user: user,
          errorMessage: null,
        ));
        // ✅ NEW: This emits a success state with the user data from Hive.
        // The UI can now access user details like username, email, etc.
      } else {
        // ✅ NEW: If credentials don't match any stored user
        emit(state.copyWith(
          errorMessage: 'Invalid username or password',
          // ✅ UPDATED: Changed from 'Invalid email or password' to 'Invalid username or password'.
          status: LoginStatus.invalidCredentials,
        ));
        // ✅ NEW: This emits a specific invalidCredentials status when login fails due to wrong credentials.
        // This helps the UI provide more specific feedback to the user.
      }
    } catch (e) {
      // ✅ This catch block handles any exceptions that might be thrown during the login process.
      
      emit(state.copyWith(
        errorMessage: 'An error occurred: ${e.toString()}',
        status: LoginStatus.failure,
      ));
      // ✅ This emits a failure state with a generic error message when an exception occurs.
      // This typically happens due to database issues or other unexpected errors.
    }
  }

  void _onClearError(LoginClearError event, Emitter<LoginState> emit) {
    // ✅ NEW: This method handles the LoginClearError event, which is used to clear error messages.
    // It's typically triggered when the user starts interacting with the form again after an error.
    
    emit(state.copyWith(
      errorMessage: null,
      status: state.status == LoginStatus.failure || 
              state.status == LoginStatus.invalidCredentials 
                ? LoginStatus.initial 
                : state.status,
    ));
    // ✅ NEW: This clears the error message and resets the status if it was an error status.
    // It keeps the current status if it wasn't an error status (like loading or success).
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<LoginState> emit) async {
    // ✅ NEW: This method handles the LogoutRequested event, which is triggered when the user logs out.
    // It clears the session data from Hive and resets the login state.
    
    try {
      // Clear session data from Hive
      await _userService.logout();
      
      // Reset the login state
      emit(const LoginState());
      // ✅ NEW: This returns the state to its initial values after logging out.
      // It clears any user data, username, password, and error messages.
    } catch (e) {
      // If logout fails, notify the user
      emit(state.copyWith(
        errorMessage: 'Logout failed: ${e.toString()}',
        status: LoginStatus.failure,
      ));
      // ✅ NEW: This handles any errors that might occur during logout.
      // It's rare but possible for database operations to fail.
    }
  }
}