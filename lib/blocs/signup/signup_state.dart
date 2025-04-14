import 'package:equatable/equatable.dart';
// ✅ This imports the Equatable package, which helps compare objects efficiently.
// It's used to optimize state management by avoiding unnecessary rebuilds when states are equal.

enum SignupStatus { initial, loading, success, failure, userExists }
// ✅ This creates an enum (a set of named constants) representing the possible states of the signup process.
// - initial: The default state when the form is first loaded
// - loading: When the form is being submitted and waiting for a response
// - success: When signup is successful
// - failure: When signup fails due to an error
// - userExists: When signup fails because the email is already registered in Hive
// ✅ NEW: Added 'userExists' status to specifically handle the case when a user tries to register with an email
// that already exists in the Hive database. This allows for more specific error messaging.
// The UI will display different content based on this status (like showing a loading indicator).

class SignupState extends Equatable {
  // ✅ This defines the SignupState class that extends Equatable.
  // This class holds all the data related to the signup form's current state.
  // It will be used by the BLoC to manage and update the UI.
  
  final String username;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final SignupStatus status;
  final String? errorMessage;
  final bool isEmailUnique;
  // ✅ These variables store all the information about the current state of the signup form:
  // - Field values (username, email, phone, password, confirmPassword)
  // - The current status of the form (initial, loading, success, failure, userExists)
  // - An optional error message (null if there's no error)
  // - NEW: A boolean to track if the email is unique in the Hive database
  // ✅ NEW: Added 'isEmailUnique' to track whether the email is already registered in Hive.
  // This helps the UI provide real-time feedback to the user about email availability.
  // The '?' after String indicates errorMessage can be null.

  const SignupState({
    this.username = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.confirmPassword = '',
    this.status = SignupStatus.initial,
    this.errorMessage,
    this.isEmailUnique = true,
    // ✅ NEW: Added isEmailUnique parameter with default value of true, assuming new emails
    // are unique until proven otherwise through a check against the Hive database.
  });
  // ✅ This is the constructor for the SignupState class.
  // It initializes a new state object with default values:
  // - Empty strings for all text fields
  // - 'initial' status
  // - No error message
  // - Email is unique by default
  // The default values make it easier to create new states without specifying every value.

  SignupState copyWith({
    String? username,
    String? email,
    String? phone,
    String? password,
    String? confirmPassword,
    SignupStatus? status,
    String? errorMessage,
    bool? isEmailUnique,
    // ✅ NEW: Added isEmailUnique to the copyWith method parameters to allow updating
    // the email uniqueness status when we check against the Hive database.
  }) {
    // ✅ This is the 'copyWith' method, a common pattern in immutable state management.
    // It creates a new state object that copies the current state but allows changing specific properties.
    // The '?' after each type means the parameters are optional - you only need to provide values you want to change.
    
    return SignupState(
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isEmailUnique: isEmailUnique ?? this.isEmailUnique,
      // ✅ NEW: Added isEmailUnique to the return statement to include it in the new state object.
      // This follows the same pattern as the other properties, using the provided value or the current one.
    );
    // ✅ This creates and returns a new SignupState with updated values.
    // The '??' operator is the "null-coalescing" operator:
    // - If the left side (parameter) is not null, use that value
    // - If the left side is null, use the right side (current state value)
    // This means "only change values that were explicitly provided".
  }

  @override
  List<Object?> get props => [
        username,
        email,
        phone,
        password,
        confirmPassword,
        status,
        errorMessage,
        isEmailUnique,
        // ✅ NEW: Added isEmailUnique to props list so that Equatable will consider it when comparing states.
        // This ensures that state changes related to email uniqueness will trigger UI updates.
      ];
  // ✅ This overrides the 'props' getter from Equatable.
  // It lists all the properties that should be used when comparing two SignupState objects.
  // Two states with identical values for all these properties will be considered equal.
  // The 'Object?' type with '?' means the list can include null values (for errorMessage).
  // This helps the BLoC avoid unnecessary rebuilds when the state hasn't actually changed.
}