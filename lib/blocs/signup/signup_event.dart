import 'package:equatable/equatable.dart';
// ✅ This imports the Equatable package, which helps compare objects more efficiently. 
// It's used to make it easier to check if two events are the same, which is important in BLoC pattern.

abstract class SignupEvent extends Equatable {
  // ✅ This creates an abstract class called SignupEvent that extends Equatable.
  // Abstract classes can't be instantiated directly but serve as blueprints for other classes.
  // All signup events will inherit from this base class.
  
  const SignupEvent();
  // ✅ This is a constructor for the abstract class.
  // The 'const' keyword makes it a compile-time constant, which improves performance.

  @override
  List<Object> get props => [];
  // ✅ This overrides the 'props' getter from Equatable.
  // It returns an empty list by default, but child classes will override this.
  // The 'props' list tells Equatable which properties to use when comparing objects.
}

class SignupUsernameChanged extends SignupEvent {
  // ✅ This is a concrete event class that extends the abstract SignupEvent.
  // It represents when the user changes their username in the signup form.
  
  final String username;
  // ✅ This declares a final variable to store the username value.
  // 'final' means it can't be changed after it's set.

  const SignupUsernameChanged({required this.username});
  // ✅ This is the constructor that requires a username parameter.
  // The 'required' keyword enforces that a username must be provided when creating this event.

  @override
  List<Object> get props => [username];
  // ✅ This overrides the 'props' getter from the parent class.
  // It includes the username in the list, so two SignupUsernameChanged events with the same username will be considered equal.
  // This helps BLoC avoid unnecessary rebuilds if the same event is dispatched multiple times.
}

class SignupEmailChanged extends SignupEvent {
  // ✅ This is another concrete event class for when the email field changes.
  // Like the username event, it extends SignupEvent and follows the same pattern.
  
  final String email;
  // ✅ This declares a final variable to store the email value.
  // It will hold the current text in the email input field.

  const SignupEmailChanged({required this.email});
  // ✅ This constructor requires an email parameter.
  // When the user types in the email field, a new instance of this class is created with that value.

  @override
  List<Object> get props => [email];
  // ✅ This includes the email in the props list, making events with the same email equal.
  // The BLoC will use this to determine if the state needs to be updated.
}

class SignupCheckEmailUnique extends SignupEvent {
  // ✅ NEW: This is a new event class for checking if an email is unique in the Hive database.
  // It will be triggered after a delay when the user enters an email, to avoid too many checks.
  
  final String email;
  // ✅ NEW: This variable stores the email value to check against the Hive database.
  // The email will be searched in the database to see if it already exists.

  const SignupCheckEmailUnique({required this.email});
  // ✅ NEW: This constructor requires an email parameter.
  // This event will be created when we want to validate email uniqueness against Hive.

  @override
  List<Object> get props => [email];
  // ✅ NEW: The props list includes the email for equality comparison.
  // This prevents duplicate checks for the same email.
}

class SignupPhoneChanged extends SignupEvent {
  // ✅ This event class handles changes to the phone number field.
  // It follows the same pattern as the username and email events.
  
  final String phone;
  // ✅ This variable stores the phone number value from the input field.
  // It will be used by the BLoC to update the signup state.

  const SignupPhoneChanged({required this.phone});
  // ✅ The constructor requires a phone parameter to create this event.
  // This event will be created each time the user modifies the phone input field.

  @override
  List<Object> get props => [phone];
  // ✅ The props list includes the phone number for equality comparison.
  // This helps optimize BLoC by preventing duplicate state updates.
}

class SignupPasswordChanged extends SignupEvent {
  // ✅ This event class handles changes to the password field.
  // It follows the same pattern as the other field change events.
  
  final String password;
  // ✅ This variable stores the current password value.
  // It will be passed to the BLoC when the password field changes.

  const SignupPasswordChanged({required this.password});
  // ✅ The constructor requires a password parameter.
  // This enforces that a password value must be provided when creating this event.

  @override
  List<Object> get props => [password];
  // ✅ The props list includes the password for equality comparison.
  // This helps the BLoC identify unique password change events.
}

class SignupConfirmPasswordChanged extends SignupEvent {
  // ✅ This event class handles changes to the confirm password field.
  // It allows the BLoC to validate if both password fields match.
  
  final String confirmPassword;
  // ✅ This variable stores the confirm password value.
  // It will be compared with the password value in the BLoC.

  const SignupConfirmPasswordChanged({required this.confirmPassword});
  // ✅ The constructor requires a confirmPassword parameter.
  // This event is created when the user types in the confirm password field.

  @override
  List<Object> get props => [confirmPassword];
  // ✅ The props list includes the confirm password for equality comparison.
  // This prevents unnecessary state updates if the same value is entered multiple times.
}

class SignupSubmitted extends SignupEvent {
  // ✅ This event class represents the form submission action.
  // It's triggered when the user clicks the signup button.
  
  final String username;
  final String email;
  final String phone;
  final String password;
  // ✅ These variables store all the form field values needed for signup.
  // They will be used by the BLoC to process the signup request.

  const SignupSubmitted({
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
  });
  // ✅ This constructor requires all form field values as parameters.
  // When the user submits the form, all these values are collected and sent together.

  @override
  List<Object> get props => [username, email, phone, password];
  // ✅ The props list includes all form field values for equality comparison.
  // This ensures that duplicate submission events with the same values are treated as equal.
}

class SignupClearError extends SignupEvent {
  // ✅ NEW: This event class is used to clear any error messages in the signup state.
  // It can be triggered after the user makes corrections or when navigating away from error screens.
  
  const SignupClearError();
  // ✅ NEW: This constructor takes no parameters since it's just a signal to clear errors.
  // It will be used to reset the error state in the BLoC.

  @override
  List<Object> get props => [];
  // ✅ NEW: The props list is empty since this event doesn't carry any data.
  // All instances of this event are considered equal.
}