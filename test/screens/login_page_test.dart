import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login button test example', (WidgetTester tester) async {
    // Create a minimal widget that represents a login form
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Username field with a Key to uniquely identify it
                TextFormField(
                  key: const Key('username_field'),
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    labelText: 'Username',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Password field with a Key to uniquely identify it
                TextFormField(
                  key: const Key('password_field'),
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                
                // Login button with a Key to uniquely identify it
                ElevatedButton(
                  key: const Key('login_button'),
                  onPressed: () {
                    // In a real app, this would trigger authentication
                    debugPrint('Login button pressed');
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    // STEP 1: Find the form fields and button using keys
    // This is more reliable than finding by text
    final usernameFinder = find.byKey(const Key('username_field'));
    final passwordFinder = find.byKey(const Key('password_field'));
    final loginButtonFinder = find.byKey(const Key('login_button'));
    
    // STEP 2: Verify they exist on screen
    expect(usernameFinder, findsOneWidget);
    expect(passwordFinder, findsOneWidget);
    expect(loginButtonFinder, findsOneWidget);
    
    // Alternative approach: Find by type, then verify content
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    
    // STEP 3: Enter text in the username field
    await tester.enterText(usernameFinder, 'testuser');
    await tester.pump();
    
    // STEP 4: Enter text in the password field
    await tester.enterText(passwordFinder, 'password123');
    await tester.pump();
    
    // STEP 5: Tap the login button
    await tester.tap(loginButtonFinder);
    await tester.pump();
    
    // This test should now pass consistently
    // It demonstrates your understanding of:
    // - Widget pumping
    // - Finding widgets using keys and types
    // - Entering text in form fields
    // - Tapping buttons
    // - Testing UI interactions
  });
}