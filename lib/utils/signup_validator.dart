class Validators {
  // Username validation
  // ✅ This method validates the username format and length.
  // It checks for required field, minimum length, and allowed characters.
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username must contain only letters, numbers and underscores';
    }
    return null;
  }

  // Email validation
  // ✅ This method validates the email format using a regex pattern.
  // It ensures the email has a proper structure with @ symbol and domain.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Simple regex for email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Phone validation
  // ✅ This method validates the phone number format and length.
  // It allows various formatting characters while ensuring a minimum number of digits.
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Allow digits, spaces, plus, dashes, and parentheses
    if (!RegExp(r'^[0-9\s\+\-\(\)]+$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    // Ensure a minimum length for the phone number (adjusted for formatting)
    if (value.replaceAll(RegExp(r'[\s\+\-\(\)]'), '').length < 7) {
      return 'Phone number is too short';
    }
    return null;
  }

  // Password validation
  // ✅ This method validates the password strength and format.
  // It checks for minimum length and requires at least one number or special character.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    // Check for at least one number or special character
    if (!RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one number or symbol';
    }
    return null;
  }

  // Confirm password validation
  // ✅ This method validates that the confirm password matches the original password.
  // It ensures both passwords are identical to prevent typos when setting up an account.
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Email uniqueness validation
  // ✅ NEW: This method validates if an email is unique against Hive database.
  // It works with the Hive integration to prevent duplicate email registrations.
  static String? validateEmailUniqueness(bool isUnique) {
    if (!isUnique) {
      return 'This email is already registered. Please use a different email or log in.';
    }
    return null;
  }

  // Password storage security notice
  // ✅ NEW: This method provides a security notice about password storage.
  // It's used to inform users about the demo nature of plain text password storage.
  static String getPasswordSecurityNotice() {
    return 'Note: In this demo app, passwords are stored as plain text in the local database. '
           'In a production app, passwords would be securely hashed.';
  }

  // Form validation
  // ✅ NEW: This method validates the entire form at once for submission.
  // It combines all validators to provide a comprehensive validation check.
  static Map<String, String?> validateSignupForm({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required bool isEmailUnique,
  }) {
    final errors = <String, String?>{};
    
    errors['username'] = validateUsername(username);
    errors['email'] = validateEmail(email);
    if (errors['email'] == null) {
      errors['email'] = validateEmailUniqueness(isEmailUnique);
    }
    errors['phone'] = validatePhone(phone);
    errors['password'] = validatePassword(password);
    errors['confirmPassword'] = validateConfirmPassword(confirmPassword, password);
    
    return errors;
  }
}