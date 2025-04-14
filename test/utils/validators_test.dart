import 'package:flutter_test/flutter_test.dart';
import 'package:gritflow/utils/validators.dart'; // Assuming this is where your validators are

void main() {
  // Username validation tests
  group('Username Validation', () {
    // ✅ This creates a group of related tests for username validation.
    // ✅ It helps organize tests by functionality for better readability in test reports.
    // ✅ When executed, it groups all username tests together in the output.
    // ✅ This connects to login form validation by focusing on the username field specifically.

    test('Valid usernames should return null', () {
      // ✅ This defines a specific test case for valid usernames.
      // ✅ It's used to verify that valid input doesn't produce error messages.
      // ✅ When executed, it runs all the expectations inside and reports success/failure.
      // ✅ This connects to login form by testing the happy path of username validation.

      // Test case 1: Standard valid username
      expect(Validators.validateUsername('John'), null);
      // ✅ This verifies that 'John' is considered a valid username.
      // ✅ It's used to check that standard names pass validation.
      // ✅ When executed, it calls validateUsername() and confirms the result is null (meaning valid).
      // ✅ This connects to login form by ensuring names like "John" will be accepted.

      // Test case 2: Longer username
      expect(Validators.validateUsername('Alexander'), null);
      // ✅ This verifies that longer names like 'Alexander' are valid.
      // ✅ It's used to ensure there's no upper limit problem in username validation.
      // ✅ When executed, it confirms that longer names return null (valid).
      // ✅ This connects to login form by ensuring users with longer names can register successfully.

      // Test case 3: Exactly 3 characters
      expect(Validators.validateUsername('Bob'), null);
      // ✅ This tests the username at the minimum length boundary (3 characters).
      // ✅ It's used to verify edge cases at the minimum acceptable length.
      // ✅ When executed, it confirms that 3-character names are considered valid.
      // ✅ This connects to login form by ensuring usernames like "Bob" pass validation.
    });

    test('Invalid usernames should return error messages', () {
      // ✅ This defines a test case for invalid username scenarios.
      // ✅ It's used to verify that improper input produces appropriate error messages.
      // ✅ When executed, it runs all the expectations and reports if any fail.
      // ✅ This connects to login form by testing error handling for username validation.

      // Test case 1: Empty username
      expect(Validators.validateUsername(''), 'Please enter your username');
      // ✅ This verifies that an empty username returns an error message.
      // ✅ It's used to check that users can't submit without entering a username.
      // ✅ When executed, it confirms the exact error message returned for empty input.
      // ✅ This connects to login form by testing the empty field validation.

      // Test case 2: Too short (less than 3 characters)
      expect(Validators.validateUsername('Jo'), 'Username must be at least 3 characters');
      // ✅ This tests a username that's too short (2 characters).
      // ✅ It's used to verify that the minimum length requirement is enforced.
      // ✅ When executed, it confirms the proper error message for short usernames.
      // ✅ This connects to login form by enforcing reasonable username length standards.

      // Test case 3: Contains numbers or special characters
      expect(Validators.validateUsername('John123'), 'Username must contain only letters');
      // ✅ This tests a username with non-letter characters.
      // ✅ It's used to verify that only alphabetic characters are allowed.
      // ✅ When executed, it confirms the error message for usernames with numbers.
      // ✅ This connects to login form by enforcing the letters-only username policy.

      // Test case 4: With special characters
      expect(Validators.validateUsername('John@!'), 'Username must contain only letters');
      // ✅ This tests a username with special characters.
      // ✅ It's used to ensure that special characters are properly rejected.
      // ✅ When executed, it confirms that the proper error message is shown.
      // ✅ This connects to login form by maintaining consistent validation rules.
    });
  });

  // Password validation tests
  group('Password Validation', () {
    // ✅ This creates a group of related tests for password validation.
    // ✅ It helps organize tests logically, separating password tests from username tests.
    // ✅ When executed, it groups all password tests together in the test report.
    // ✅ This connects to login form validation by focusing on the password field specifically.

    test('Valid passwords should return null', () {
      // ✅ This defines a test case for valid password scenarios.
      // ✅ It's used to verify that acceptable passwords pass validation.
      // ✅ When executed, it runs all the expectations inside and reports results.
      // ✅ This connects to login form by testing the happy path of password validation.

      // Test case 1: Password with letters and numbers
      expect(Validators.validatePassword('Password123'), null);
      // ✅ This tests a password with letters and numbers.
      // ✅ It's used to verify that passwords with sufficient complexity are accepted.
      // ✅ When executed, it confirms that valid passwords return null (valid).
      // ✅ This connects to login form by ensuring properly formatted passwords are accepted.

      // Test case 2: Minimum length password (6 chars) with required elements
      expect(Validators.validatePassword('Pass1!'), null);
      // ✅ This tests a password at the minimum length with required elements.
      // ✅ It's used to verify the lower boundary of acceptable password complexity.
      // ✅ When executed, it confirms that minimum-requirement passwords are valid.
      // ✅ This connects to login form by defining the minimum acceptable password.

      // Test case 3: Password with special characters
      expect(Validators.validatePassword('Pass@#!'), null);
      // ✅ This tests a password with special characters.
      // ✅ It's used to verify that special characters satisfy the complexity requirement.
      // ✅ When executed, it confirms that passwords with symbols are considered valid.
      // ✅ This connects to login form by ensuring different types of valid passwords are accepted.
    });

    test('Invalid passwords should return error messages', () {
      // ✅ This defines a test case for invalid password scenarios.
      // ✅ It's used to verify that improper passwords produce appropriate error messages.
      // ✅ When executed, it runs all the expectations inside and reports any failures.
      // ✅ This connects to login form by testing error handling for password validation.

      // Test case 1: Empty password
      expect(Validators.validatePassword(''), 'Please enter your password');
      // ✅ This verifies that an empty password returns an error message.
      // ✅ It's used to check that users can't submit without entering a password.
      // ✅ When executed, it confirms the exact error message for empty passwords.
      // ✅ This connects to login form by preventing submission with empty passwords.

      // Test case 2: Too short password
      expect(Validators.validatePassword('Pass'), 'Password must be at least 6 characters');
      // ✅ This tests a password that's too short (4 characters).
      // ✅ It's used to verify that the minimum length requirement is enforced.
      // ✅ When executed, it confirms the proper error message for short passwords.
      // ✅ This connects to login form by enforcing minimum password length for security.

      // Test case 3: Missing number and special character
      expect(Validators.validatePassword('Password'), 'Password must contain at least one number or symbol');
      // ✅ This tests a password without any numbers or special characters.
      // ✅ It's used to verify that the complexity requirement is enforced.
      // ✅ When executed, it confirms the exact error message for this requirement.
      // ✅ This connects to login form by enforcing password complexity rules.
    });
  });

  // Email validation tests
  group('Email Validation', () {
    // ✅ This creates a group of related tests for email validation.
    // ✅ It helps organize tests by functionality for better test reporting.
    // ✅ When executed, it groups all email tests together in the output.
    // ✅ This connects to form validation by focusing on the email field specifically.

    test('Valid emails should return null', () {
      // ✅ This defines a test case for valid email scenarios.
      // ✅ It's used to verify that proper email formats are accepted.
      // ✅ When executed, it runs all the expectations inside and reports results.
      // ✅ This connects to form by testing the happy path of email validation.

      // Test case 1: Standard email
      expect(Validators.validateEmail('john@example.com'), null);
      
      // Test case 2: Email with subdomain
      expect(Validators.validateEmail('john@mail.example.com'), null);
      
      // Test case 3: Email with numbers
      expect(Validators.validateEmail('john123@example.com'), null);
      
      // Test case 4: Email with dots in username
      expect(Validators.validateEmail('john.doe@example.com'), null);
    });

    test('Invalid emails should return error messages', () {
      // ✅ This defines a test case for invalid email scenarios.
      // ✅ It's used to verify that improper email formats produce appropriate error messages.
      // ✅ When executed, it runs all the expectations and reports any failures.
      // ✅ This connects to form by testing error handling for email validation.

      // Test case 1: Empty email
      expect(Validators.validateEmail(''), 'Please enter your email address');
      
      // Test case 2: Missing @ symbol
      expect(Validators.validateEmail('johndoeexample.com'), 'Please enter a valid email address');
      
      // Test case 3: Missing domain
      expect(Validators.validateEmail('john@'), 'Please enter a valid email address');
      
      // Test case 4: Missing username
      expect(Validators.validateEmail('@example.com'), 'Please enter a valid email address');
    });
  });

  // Phone validation tests
  group('Phone Validation', () {
    // ✅ This creates a group of related tests for phone validation.
    // ✅ It helps organize tests by functionality for better test reporting.
    // ✅ When executed, it groups all phone tests together in the output.
    // ✅ This connects to form validation by focusing on the phone field specifically.

    test('Valid phone numbers should return null', () {
      // ✅ This defines a test case for valid phone scenarios.
      // ✅ It's used to verify that acceptable phone formats are accepted.
      // ✅ When executed, it runs all the expectations inside and reports results.
      // ✅ This connects to form by testing the happy path of phone validation.

      // Test case 1: 10-digit number
      expect(Validators.validatePhone('1234567890'), null);
      
      // Test case 2: Formatted number with dashes
      expect(Validators.validatePhone('123-456-7890'), null);
      
      // Test case 3: Formatted number with spaces
      expect(Validators.validatePhone('123 456 7890'), null);
      
      // Test case 4: Formatted number with parentheses
      expect(Validators.validatePhone('(123) 456-7890'), null);
    });

    test('Invalid phone numbers should return error messages', () {
      // ✅ This defines a test case for invalid phone scenarios.
      // ✅ It's used to verify that improper phone formats produce appropriate error messages.
      // ✅ When executed, it runs all the expectations and reports any failures.
      // ✅ This connects to form by testing error handling for phone validation.

      // Test case 1: Empty phone number
      expect(Validators.validatePhone(''), 'Please enter your phone number');
      
      // Test case 2: Too short
      expect(Validators.validatePhone('123456789'), 'Phone number must have at least 10 digits');
      
      // Test case 3: Non-digits only
      expect(Validators.validatePhone('abc-def-ghij'), 'Phone number must have at least 10 digits');
      
      // Test case 4: Mixed but too short
      expect(Validators.validatePhone('12-abc-345'), 'Phone number must have at least 10 digits');
    });
  });

  // Confirm password validation tests
  group('Confirm Password Validation', () {
    // ✅ This creates a group of related tests for confirm password validation.
    // ✅ It helps organize tests by functionality for better test reporting.
    // ✅ When executed, it groups all confirm password tests together in the output.
    // ✅ This connects to form validation by focusing on password confirmation specifically.

    const testPassword = 'Password123!';

    test('Matching password confirmation should return null', () {
      // ✅ This defines a test case for matching confirmation scenarios.
      // ✅ It's used to verify that matching passwords are accepted.
      // ✅ When executed, it runs the expectation and reports results.
      // ✅ This connects to form by testing the happy path of password confirmation.

      expect(Validators.validateConfirmPassword(testPassword, testPassword), null);
    });

    test('Non-matching password confirmation should return error message', () {
      // ✅ This defines a test case for non-matching confirmation scenarios.
      // ✅ It's used to verify that mismatched passwords produce appropriate error messages.
      // ✅ When executed, it runs the expectations and reports any failures.
      // ✅ This connects to form by testing error handling for password confirmation.

      // Test case 1: Empty confirmation
      expect(Validators.validateConfirmPassword('', testPassword), 'Please confirm your password');
      
      // Test case 2: Different confirmation
      expect(Validators.validateConfirmPassword('DifferentPassword123!', testPassword), 'Passwords do not match');
    });
  });
}