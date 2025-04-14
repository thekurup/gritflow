import 'package:flutter_bloc/flutter_bloc.dart';
// ✅ This imports the flutter_bloc package, which provides the core BLoC functionality.
// BLoC stands for Business Logic Component and helps separate business logic from UI.

import 'package:gritflow/blocs/signup/signup_event.dart';
// ✅ This imports the SignupEvent classes we created earlier.
// These events represent the different actions users can take during signup.

import 'package:gritflow/blocs/signup/signup_state.dart';
// ✅ This imports the SignupState class we created earlier.
// This state holds all the data about the current signup form.

import 'package:gritflow/utils/signup_validator.dart'; // Fixed file name (singular)
// ✅ This imports the validation utilities to check form field values.
// It contains functions to validate usernames, emails, passwords, etc.

import 'dart:async';
// ✅ This imports Dart's async functionality for handling asynchronous operations.
// It's needed for the Future<void> method used when submitting the form.

import 'package:gritflow/hive/hive_crud.dart';
// ✅ NEW: This imports the HiveUserService that handles interactions with the Hive database.
// It provides methods to create, read, update, and delete user data in local storage.

import 'package:gritflow/models/user_model.dart';
// ✅ NEW: This imports the UserModel class that defines the data structure for user information.
// It's used to create new user objects that will be stored in the Hive database.

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  // ✅ This defines the SignupBloc class that extends the Bloc class.
  // It specifies that this BLoC handles SignupEvents and manages SignupState.
  // This class connects the events (user actions) to state changes (UI updates).
  
  final HiveUserService _userService = HiveUserService();
  // ✅ NEW: This creates an instance of HiveUserService to interact with the Hive database.
  // It will be used to check email uniqueness and store user data during signup.
  
  Timer? _debounce;
  // ✅ NEW: This declares a Timer variable for debouncing email checks.
  // It prevents too many database lookups when the user is typing rapidly in the email field.
  
  SignupBloc() : super(const SignupState()) {
    // ✅ This is the constructor for SignupBloc.
    // super(const SignupState()) initializes the BLoC with a default empty state.
    // When the signup screen first loads, it will have empty fields and initial status.
    
    on<SignupUsernameChanged>(_onUsernameChanged);
    on<SignupEmailChanged>(_onEmailChanged);
    on<SignupPhoneChanged>(_onPhoneChanged);
    on<SignupPasswordChanged>(_onPasswordChanged);
    on<SignupConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SignupSubmitted>(_onSubmitted);
    on<SignupCheckEmailUnique>(_onCheckEmailUnique);
    on<SignupClearError>(_onClearError);
    // ✅ These lines register event handlers for each type of event.
    // The 'on<EventType>(handler)' method connects each event to its handler function.
    // When an event is dispatched, the BLoC will call the corresponding handler function.
    // ✅ NEW: Added handlers for the new SignupCheckEmailUnique and SignupClearError events
    // to support email uniqueness checking and error management.
  }

  @override
  Future<void> close() {
    // ✅ NEW: This overrides the close method from the Bloc class.
    // It's called when the BLoC is no longer needed and should release resources.
    
    _debounce?.cancel();
    // ✅ NEW: This cancels any active debounce timer to prevent memory leaks.
    // It ensures that any pending email checks are cancelled when the BLoC is closed.
    
    return super.close();
    // ✅ NEW: This calls the parent class's close method to complete the cleanup.
    // It's important to call super.close() to properly dispose of the BLoC.
  }

  void _onUsernameChanged(
    SignupUsernameChanged event,
    Emitter<SignupState> emit,
  ) {
    // ✅ This is the handler function for the SignupUsernameChanged event.
    // It receives the event (containing the new username) and an emitter for updating the state.
    
    emit(state.copyWith(username: event.username));
    // ✅ This line updates the state with the new username value.
    // It creates a new state that's identical to the current state except for the username.
    // The 'emit' function sends this new state to all listeners (like the UI).
  }

  void _onEmailChanged(
    SignupEmailChanged event,
    Emitter<SignupState> emit,
  ) {
    // ✅ This is the handler function for the SignupEmailChanged event.
    // It works the same way as the username handler but for email updates.
    
    emit(state.copyWith(email: event.email));
    // ✅ This line updates the state with the new email value.
    // The UI will rebuild to reflect this change whenever the user types in the email field.
    
    // ✅ NEW: Debounce the email check to avoid too many database lookups
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // ✅ NEW: After 500ms of inactivity, check if the email is unique
      if (event.email.isNotEmpty && Validators.validateEmail(event.email) == null) {
        add(SignupCheckEmailUnique(email: event.email));
      }
    });
    // ✅ NEW: This adds debounce logic to delay checking email uniqueness.
    // It waits 500ms after the user stops typing before checking the database,
    // and only checks if the email is not empty and passes basic validation.
  }

  Future<void> _onCheckEmailUnique(
    SignupCheckEmailUnique event,
    Emitter<SignupState> emit,
  ) async {
    // ✅ NEW: This is the handler function for the SignupCheckEmailUnique event.
    // It asynchronously checks if the provided email already exists in the Hive database.
    
    try {
      // Check if the email exists in the database
      final existingUser = await _userService.getUserByEmail(event.email);
      
      // Update the state with the email uniqueness result
      emit(state.copyWith(
        isEmailUnique: existingUser == null,
        errorMessage: existingUser != null ? 'This email is already registered' : null,
      ));
    } catch (e) {
      // If there's an error checking the database, assume the email is unique
      emit(state.copyWith(
        isEmailUnique: true,
        errorMessage: null,
      ));
    }
    // ✅ NEW: This code queries the Hive database to see if the email already exists.
    // It updates the state's isEmailUnique flag and sets an error message if needed.
    // If an error occurs during the check, it assumes the email is unique to avoid blocking signup.
  }

  void _onClearError(
    SignupClearError event,
    Emitter<SignupState> emit,
  ) {
    // ✅ NEW: This is the handler function for the SignupClearError event.
    // It resets any error messages in the state, often used after the user makes corrections.
    
    emit(state.copyWith(
      errorMessage: null,
      status: SignupStatus.initial,
    ));
    // ✅ NEW: This clears the error message and resets the status to initial.
    // It's useful when transitioning between screens or after correcting validation errors.
  }

  void _onPhoneChanged(
    SignupPhoneChanged event,
    Emitter<SignupState> emit,
  ) {
    // ✅ This is the handler function for the SignupPhoneChanged event.
    // It updates the state whenever the user changes the phone number field.
    
    emit(state.copyWith(phone: event.phone));
    // ✅ This line updates the state with the new phone value.
    // Only the phone field is updated; all other state values remain the same.
  }

  void _onPasswordChanged(
    SignupPasswordChanged event,
    Emitter<SignupState> emit,
  ) {
    // ✅ This is the handler function for the SignupPasswordChanged event.
    // It updates the state whenever the user changes the password field.
    
    emit(state.copyWith(password: event.password));
    // ✅ This line updates the state with the new password value.
    // The password field in the state is updated while keeping other fields unchanged.
  }

  void _onConfirmPasswordChanged(
    SignupConfirmPasswordChanged event,
    Emitter<SignupState> emit,
  ) {
    // ✅ This is the handler function for the SignupConfirmPasswordChanged event.
    // It updates the state whenever the user changes the confirm password field.
    
    emit(state.copyWith(confirmPassword: event.confirmPassword));
    // ✅ This line updates the state with the new confirm password value.
    // This allows the app to check if both password fields match.
  }

  Future<void> _onSubmitted(
    SignupSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    // ✅ This is the handler function for the SignupSubmitted event.
    // It's marked as async because it performs asynchronous operations (like API calls).
    // This function handles the entire signup process when the user submits the form.
    
    // Validate inputs
    final usernameError = Validators.validateUsername(event.username);
    final emailError = Validators.validateEmail(event.email);
    final phoneError = Validators.validatePhone(event.phone);
    final passwordError = Validators.validatePassword(event.password);
    final confirmPasswordError = Validators.validateConfirmPassword(
      state.confirmPassword, 
      event.password
    );
    // ✅ These lines validate all form inputs using the validator functions.
    // Each function returns null if the input is valid, or an error message if it's invalid.
    // These results are stored in variables to check if any validation failed.
    
    // Check if there are any validation errors
    if (usernameError != null || 
        emailError != null || 
        phoneError != null || 
        passwordError != null ||
        confirmPasswordError != null) {
      // ✅ This conditional checks if any validation errors were found.
      // If any of the error variables is not null, at least one field is invalid.
      
      emit(state.copyWith(
        status: SignupStatus.failure,
        errorMessage: 'Please fix the form errors and try again.'
      ));
      // ✅ This updates the state to show a failure status and error message.
      // The UI will display this message to inform the user about the validation error.
      
      return;
      // ✅ This exits the function early without submitting the form.
      // If there are validation errors, we don't want to proceed with signup.
    }
    
    // ✅ NEW: Check if email is already registered
    final existingUser = await _userService.getUserByEmail(event.email);
    if (existingUser != null) {
      emit(state.copyWith(
        status: SignupStatus.userExists,
        errorMessage: 'This email is already registered. Please use a different email or log in.',
        isEmailUnique: false,
      ));
      return;
    }
    // ✅ NEW: This code performs a final check to make sure the email isn't already registered.
    // Even though we check during typing, this ensures no duplicates slip through.
    // If the email exists, it updates the state with a specific userExists status and error message.
    
    // Update state to loading
    emit(state.copyWith(status: SignupStatus.loading));
    // ✅ This updates the state to show a loading status.
    // The UI will display a loading indicator while waiting for the signup process.
    
    try {
      // ✅ This begins a try-catch block to handle potential errors during signup.
      // If anything goes wrong in this block, the catch clause will handle it.
      
      // ✅ NEW: Create a new user model with the form data
      final newUser = UserModel(
        username: event.username,
        email: event.email,
        phone: event.phone,
        password: event.password,
      );
      // ✅ NEW: This creates a new UserModel with the data from the form.
      // This object will be stored in the Hive database to represent the user.
      
      // ✅ NEW: Save the user to Hive database
      await _userService.createUser(newUser);
      // ✅ NEW: This calls the createUser method of the HiveUserService to save the user.
      // The user information is now stored locally and can be used for login.
      
      // Success!
      emit(state.copyWith(status: SignupStatus.success));
      // ✅ This updates the state to show a success status.
      // The UI will react to this by navigating to the next screen or showing a success message.
    } catch (e) {
      // ✅ This catch clause executes if an error occurs during the try block.
      // The error is stored in the variable 'e'.
      
      // Handle signup failure
      emit(state.copyWith(
        status: SignupStatus.failure,
        errorMessage: 'Registration failed: ${e.toString()}',
      ));
      // ✅ This updates the state to show a failure status and the error message.
      // The UI will display this message to inform the user about what went wrong.
      // ✅ NEW: Updated the error message to be more specific about registration failure.
    }
  }
}