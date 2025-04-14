import 'package:flutter_test/flutter_test.dart';
// ✅ This imports Flutter's testing framework with essential tools like 'test', 'expect', etc.
// ✅ This package is the foundation for all Flutter unit tests.

import 'package:bloc_test/bloc_test.dart';
// ✅ This imports the bloc_test package which provides specialized testing tools for BLoCs.
// ✅ It includes the blocTest function which makes testing BLoCs much easier.

import 'package:gritflow/blocs/logins/login_bloc.dart';
import 'package:gritflow/blocs/logins/login_event.dart';
import 'package:gritflow/blocs/logins/login_state.dart';
// ✅ These import your login-related BLoC files from your project.
// ✅ They make the BLoC, events, and state classes available to your test.

void main() {
  // ✅ This is the entry point for your test file.
  // ✅ All test code runs inside this main function when the test is executed.
  
  late LoginBloc loginBloc;
  // ✅ This declares a variable to hold the LoginBloc instance used in tests.
  // ✅ The 'late' keyword means it will be initialized before use, but not immediately.
  
  setUp(() {
    loginBloc = LoginBloc();
  });
  // ✅ This function runs before each test case.
  // ✅ It creates a fresh LoginBloc instance to ensure each test starts with a clean state.
  // ✅ This helps prevent tests from affecting each other.
  
  tearDown(() {
    loginBloc.close();
  });
  // ✅ This function runs after each test case.
  // ✅ It properly disposes of the LoginBloc to prevent memory leaks.
  // ✅ This is important as BLoCs use streams that need to be closed.
  
  group('Username Tests', () {
    // ✅ This creates a logical group of related tests.
    // ✅ Groups help organize tests and make test reports easier to read.
    
    blocTest<LoginBloc, LoginState>(
      // ✅ This creates a specialized test for BLoCs.
      // ✅ It takes generic type parameters to specify which BLoC and state types we're testing.
      
      'emits [updated username] when LoginUsernameChanged is added',
      // ✅ This is a description of what the test is checking.
  
      
      build: () => loginBloc,
      // ✅ This provides the test with the BLoC instance to use.
      // ✅ It returns the LoginBloc we created in setUp.
      
      act: (bloc) => bloc.add(const LoginUsernameChanged(username: 'Arjun')),
      // ✅ This defines the action to perform on the BLoC.
      // ✅ It adds a username change event with the value 'Arjun'.
      // ✅ This simulates a user typing in the username field.
      
      expect: () => [
        const LoginState(username: 'Arjun'),
      ],
      // ✅ This defines what states we expect the BLoC to emit after the action.
      // ✅ We expect a single state with the username updated to 'Arjun'.
      // ✅ The test passes if the BLoC emits exactly these states in this order.
    );
  });
}