// These are user actions like changing username, password, or submitting the form.
// ✅ UPDATED: Changed from "email" to "username" in the comment to reflect the change to username-based login.

import 'package:equatable/equatable.dart';
// ✅ This imports the Equatable package, which helps compare objects based on their values rather than their references.
// It's useful for comparing events to avoid unnecessary UI rebuilds.

abstract class LoginEvent extends Equatable {
  // ✅ This creates an abstract base class for all login events. It extends Equatable to make events comparable.
  // Abstract means you can't create an instance of LoginEvent directly - you must use a subclass.
  
  const LoginEvent();
  // ✅ This is the constructor for the base class. The "const" keyword allows instances to be compile-time constants,
  // which improves performance and enables efficient caching.

  @override
  List<Object> get props => [];
  // ✅ This overrides the props getter from Equatable. Each subclass will override this to specify
  // which properties should be used for comparison. By default, it returns an empty list,
  // meaning events with no properties are equal.
}

class LoginUsernameChanged extends LoginEvent {
  // ✅ UPDATED: Renamed from LoginEmailChanged to LoginUsernameChanged to reflect the switch to username-based login.
  // This defines an event that's fired when the user types in the username field.
  // It extends LoginEvent to inherit its properties and be recognizable by the BLoC.
  
  final String username;
  // ✅ UPDATED: Changed field name from email to username to store the username input value.
  // This field holds the new username value that the user has entered. It's marked final
  // because events are immutable (their values don't change after creation).

  const LoginUsernameChanged({required this.username});
  // ✅ UPDATED: Changed parameter name from email to username in the constructor.
  // This constructor requires a username parameter. The "required" keyword ensures that
  // you can't create this event without providing a username value.

  @override
  List<Object> get props => [username];
  // ✅ UPDATED: Changed from email to username in the props list.
  // This overrides the props getter to include the username field in equality comparisons.
  // This means two LoginUsernameChanged events with the same username value will be considered equal.
}

class LoginPasswordChanged extends LoginEvent {
  // ✅ This defines an event that's fired when the user types in the password field.
  // Similar to LoginUsernameChanged, it extends LoginEvent.
  
  final String password;
  // ✅ This field holds the new password value that the user has entered. It's also marked
  // final for immutability.

  const LoginPasswordChanged({required this.password});
  // ✅ This constructor requires a password parameter, ensuring that you can't create
  // this event without providing a password value.

  @override
  List<Object> get props => [password];
  // ✅ This overrides the props getter to include the password field in equality comparisons.
  // This means two LoginPasswordChanged events with the same password value will be considered equal.
}

class LoginRememberMeChanged extends LoginEvent {
  // ✅ NEW: This defines an event that's fired when the user toggles the "Remember Me" checkbox.
  // It extends LoginEvent to fit into the same BLoC pattern.
  
  final bool rememberMe;
  // ✅ NEW: This field holds the new state of the "Remember Me" checkbox (true or false).
  // It will be used to update the LoginState and potentially store preferences in Hive.

  const LoginRememberMeChanged({required this.rememberMe});
  // ✅ NEW: This constructor requires a rememberMe parameter to ensure the event
  // always contains the current state of the checkbox.

  @override
  List<Object> get props => [rememberMe];
  // ✅ NEW: This overrides the props getter to include the rememberMe field in equality comparisons.
  // This ensures that toggling the checkbox will be recognized as a unique event.
}

class LoginSubmitted extends LoginEvent {
  // ✅ This defines an event that's fired when the user taps the login button.
  // It represents the user's intent to log in with the current username and password.
  // ✅ UPDATED: Changed description from "email and password" to "username and password".
  
  final String username;
  final String password;
  final bool rememberMe;
  // ✅ UPDATED: Changed field from email to username.
  // These fields hold the username and password values from the form when the login attempt is made.
  // They're needed so the BLoC can access the values for authentication.
  // ✅ NEW: Added rememberMe field to track whether the user wants their session remembered.
  // This will be used for persistent login with Hive.

  const LoginSubmitted({
    required this.username,
    // ✅ UPDATED: Changed parameter from email to username.
    required this.password,
    this.rememberMe = false,
    // ✅ NEW: Added rememberMe parameter with a default value of false.
    // This means it's optional when creating the event but will always have a value.
  });
  // ✅ This constructor requires both username and password parameters, ensuring that you
  // can't submit a login attempt without both values.
  // ✅ UPDATED: Changed from "email and password" to "username and password" in comment.

  @override
  List<Object> get props => [username, password, rememberMe];
  // ✅ This overrides the props getter to include both username and password fields in equality comparisons.
  // This means two LoginSubmitted events with the same username and password values will be considered equal.
  // ✅ NEW: Added rememberMe to the props list to include it in equality comparisons.
  // ✅ UPDATED: Changed from email to username in the props list.
}

class LoginCheckSavedCredentials extends LoginEvent {
  // ✅ NEW: This defines an event that's fired when the app starts or navigates to the login screen.
  // It triggers a check for previously saved credentials in Hive storage.
  
  const LoginCheckSavedCredentials();
  // ✅ NEW: This constructor takes no parameters since it's just a signal to check for saved credentials.
  // It will be dispatched automatically when the login screen initializes.

  @override
  List<Object> get props => [];
  // ✅ NEW: This overrides the props getter with an empty list since this event doesn't have any properties.
  // All instances of this event are considered equal.
}

class LoginClearError extends LoginEvent {
  // ✅ NEW: This defines an event for clearing error messages in the login state.
  // It can be triggered when the user starts typing again after seeing an error.
  
  const LoginClearError();
  // ✅ NEW: This constructor takes no parameters since it's just a signal to clear errors.
  // It will be dispatched when the user interacts with the form after an error.

  @override
  List<Object> get props => [];
  // ✅ NEW: This overrides the props getter with an empty list since this event doesn't have properties.
  // All instances of this event are considered equal.
}

class LogoutRequested extends LoginEvent {
  // ✅ NEW: This defines an event that's fired when the user wants to log out.
  // It will trigger the removal of authentication data from Hive storage.
  
  const LogoutRequested();
  // ✅ NEW: This constructor takes no parameters since it's just a signal to log out.
  // It will be dispatched when the user taps the logout button.

  @override
  List<Object> get props => [];
  // ✅ NEW: This overrides the props getter with an empty list since this event doesn't have properties.
  // All instances of this event are considered equal.
}