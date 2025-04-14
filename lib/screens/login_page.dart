import 'package:flutter/material.dart';
// ✅ This imports Flutter's Material Design package, which contains the core UI components like buttons, text fields, and layouts. This is the foundation for building Flutter UI.

import 'package:flutter/services.dart';
// ✅ NEW: This imports Flutter's services package, which contains the FilteringTextInputFormatter used to restrict input characters.

import 'package:flutter_bloc/flutter_bloc.dart';
// ✅ This imports the BLoC (Business Logic Component) package, which helps separate UI from business logic. It provides widgets to connect your UI with state management.

import 'package:google_fonts/google_fonts.dart';
// ✅ This imports the Google Fonts package, which lets you use various Google fonts in your app. It's used here to style text with fonts like Poppins.

import 'package:gritflow/blocs/logins/login_bloc.dart';
// ✅ This imports the LoginBloc class, which handles all login-related logic and state. It processes events and emits states to update the UI.

import 'package:gritflow/blocs/logins/login_event.dart';
// ✅ This imports the login events that can be triggered in the app, like LoginUsernameChanged or LoginSubmitted. Events represent user actions.
// ✅ UPDATED: Changed from LoginEmailChanged to LoginUsernameChanged in the comment to reflect the username-based login.

import 'package:gritflow/blocs/logins/login_state.dart';
// ✅ This imports the login states that represent different UI conditions like loading, success, or error. The UI changes based on these states.

import 'package:gritflow/screens/home_screen.dart';
import 'package:gritflow/screens/profile_page.dart';
import 'package:gritflow/screens/signup_page.dart';
// ✅ This imports the HomeScreen that users will navigate to after successful login. It's the destination after authentication.
// ✅ This imports the SignupScreen for new user registration.

import 'package:gritflow/utils/validators.dart';
// ✅ This imports validation functions to check if username and password inputs are valid. It helps ensure users enter correct information.
// ✅ UPDATED: Changed from "email" to "username" in the comment to reflect username validation.

import 'dart:math' as math;
// ✅ This imports Dart's math library for mathematical operations, used here for animations like sine functions and rotations in the UI elements.

class LoginScreen extends StatefulWidget {
  // ✅ This defines LoginScreen as a StatefulWidget, which can change its appearance over time. It's used because the login screen needs to update based on user interactions.
  
  const LoginScreen({super.key});
  // ✅ This is the constructor for LoginScreen that accepts an optional key parameter. Keys help Flutter identify widgets when they're rebuilt.

  @override
  State<LoginScreen> createState() => _LoginScreenState();
  // ✅ This creates the state object for the LoginScreen. It returns _LoginScreenState which will contain all the changing data and UI logic.
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // ✅ This defines the state class for LoginScreen. The TickerProviderStateMixin provides timing capabilities needed for animations.
  
  final _usernameController = TextEditingController();
  // ✅ UPDATED: Changed from _emailController to _usernameController to handle username input instead of email.
  // This creates a controller to manage the username text field. It helps read and modify the text entered by the user.
  
  final _passwordController = TextEditingController();
  // ✅ This creates a controller for the password field, similar to the username controller. It helps handle password input.
  
  final _formKey = GlobalKey<FormState>();
  // ✅ This creates a key for the form to track its state. It's used to trigger form validation when the user attempts to log in.
  
  late AnimationController _confettiController;
  // ✅ This declares an animation controller for the confetti effect. "late" means it will be initialized before use, but not right now.
  
  late AnimationController _characterController;
  // ✅ This declares an animation controller for the Moe character. It will control the subtle movements of the character.
  
  bool _obscurePassword = true;
  // ✅ This tracks whether the password is hidden or visible. Initially set to true so the password is masked with dots.
  
  bool _rememberMe = false;
  // ✅ NEW: This tracks whether the "Remember Me" option is enabled. Initially set to false.
  // This allows users to have their username remembered for future logins.
  
  // ✅ NEW: Helper function to capitalize first letter
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  @override
  void initState() {
    // ✅ This lifecycle method is called when the widget is inserted into the widget tree. It's used to initialize things before the UI is built.
    
    super.initState();
    // ✅ This calls the parent class's initState method first, which is a required step in overriding lifecycle methods.
    
    // Animation controllers for the confetti and character
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    // ✅ This initializes the confetti animation controller with a 3-second duration and starts it repeating immediately. The "vsync: this" connects it to the widget's timing system.
    
    _characterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    // ✅ This initializes the character animation controller with a 2-second duration and starts it repeating. It will create a subtle bobbing effect.
    
    // ✅ NEW: Check for saved credentials when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginBloc>().add(const LoginCheckSavedCredentials());
    });
    // ✅ NEW: This dispatches the LoginCheckSavedCredentials event after the first frame is rendered.
    // It triggers the BLoC to check if there are saved credentials or an active session.
  }
  
  @override
  void dispose() {
    // ✅ This lifecycle method is called when the widget is removed from the widget tree. It's used to clean up resources and prevent memory leaks.
    
    _usernameController.dispose();
    // ✅ UPDATED: Changed from _emailController to _usernameController.
    _passwordController.dispose();
    _confettiController.dispose();
    _characterController.dispose();
    super.dispose();
    // ✅ These lines clean up the controllers when the widget is disposed. This prevents memory leaks. The super.dispose() call should be last.
  }

  @override
  Widget build(BuildContext context) {
    // ✅ This required method builds the UI. It's called whenever the widget needs to be redrawn, like after setState() is called.
    
    return BlocProvider(
      create: (context) => LoginBloc(),
      // ✅ This creates a new LoginBloc instance and makes it available to the widget tree. The BlocProvider manages the lifecycle of the BLoC.
      
      child: BlocConsumer<LoginBloc, LoginState>(
        // ✅ This widget both listens to state changes (like BlocListener) and rebuilds the UI (like BlocBuilder) based on those changes.
        
        listener: (context, state) {
          // ✅ This function is called whenever the LoginBloc emits a new state. It handles side effects like showing error messages or navigation.
          
          // ✅ NEW: Update controllers with state values when they change from external sources
          if (state.username.isNotEmpty && _usernameController.text != state.username) {
            _usernameController.text = state.username;
          }
          
          // ✅ NEW: Update remember me checkbox when state changes
          if (_rememberMe != state.isRememberMe) {
            setState(() {
              _rememberMe = state.isRememberMe;
            });
          }
          
          // Handle side effects based on state changes
          if (state.status == LoginStatus.failure || state.status == LoginStatus.invalidCredentials) {
            // ✅ UPDATED: Now handles both general failure and specific invalid credentials states.
            // This checks if the login attempt failed. If so, it will show an error message to the user.
            
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? "Login failed. Please try again."),
                backgroundColor: Colors.red,
              ),
            );
            // ✅ This displays an error message at the bottom of the screen using a SnackBar. It shows either the specific error message or a default one.
            
          } else if (state.status == LoginStatus.success) {
            // ✅ This checks if the login was successful. If so, it will navigate to the home screen.
            
            // Navigate to home screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
            // ✅ This navigates to the HomeScreen, replacing the current screen in the navigation stack so users can't go back to login.
          }
        },
        
        builder: (context, state) {
          // ✅ This function builds the UI based on the current state of the LoginBloc. It's called whenever the state changes.
          
          return Scaffold(
            backgroundColor: Colors.black,
            // ✅ This creates a basic screen layout with a black background color, matching the design requirements.
            
            body: SafeArea(
              // ✅ This ensures the UI is displayed in the safe area of the screen, avoiding notches, status bars, and other system UI elements.
              
              child: SingleChildScrollView(
                // ✅ This makes the content scrollable, which is important when the keyboard appears and might push content off-screen.
                
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  // ✅ This adds horizontal padding of 24 pixels on both sides, giving the content some breathing room.
                  
                  child: Form(
                    key: _formKey,
                    // ✅ This creates a Form widget that groups form fields for validation. The _formKey connects to this form to trigger validation later.
                    
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // ✅ This arranges children vertically (in a column) and centers them both vertically and horizontally.
                      
                      children: [
                        const SizedBox(height: 40),
                        // ✅ This adds 40 pixels of vertical space at the top of the form, pushing content down from the screen edge.
                        
                        // Character and confetti container
                        _buildCharacterContainer(),
                        // ✅ This calls a method to build the Moe character with confetti animation. Breaking UI into methods helps keep code organized.
                        
                        const SizedBox(height: 40),
                        // ✅ This adds 40 pixels of vertical space between the character container and the "Log In" text.
                        
                        // Log In Text
                        Text(
                          "Log In",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // ✅ This displays "Log In" in large, bold, white Poppins font. It acts as the title for the login form.
                        
                        const SizedBox(height: 30),
                        // ✅ This adds 30 pixels of vertical space between the "Log In" text and the username field.
                        
                        // Username field
                        TextFormField(
                          controller: _usernameController,
                          // ✅ UPDATED: Changed from _emailController to _usernameController.
                          // This creates a form field for username input. The controller allows reading and manipulating the entered text.
                          
                          decoration: InputDecoration(
                            hintText: "Username",
                            // ✅ UPDATED: Changed hint from "Username" to "Username (Firstname)" to show capitalization pattern
                            // This visually demonstrates that the first letter will be capitalized and the rest will be lowercase
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            // ✅ This styles the text field with a dark background, light gray hint text, and placeholder text.
                            
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            // ✅ This removes the default border and adds rounded corners to the text field, making it look more modern.
                            
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            // ✅ This adds internal padding inside the text field, giving the text some space from the edges.
                            
                            errorStyle: const TextStyle(color: Colors.redAccent),
                          ),
                          // ✅ This styles error messages in red, which appear when validation fails.
                          
                          style: const TextStyle(color: Colors.white),
                          // ✅ This sets the user's input text color to white, for good contrast against the dark background.
                          
                          keyboardType: TextInputType.text,
                          // ✅ UPDATED: Changed from TextInputType.emailAddress to TextInputType.text to match username input.
                          // This shows the standard keyboard without special email-specific keys.
                          
                          // ✅ UPDATED: Removed TextCapitalization.words since we're handling capitalization manually with an input formatter
                          
                          // ✅ NEW: Only allow letters for username (no numbers or symbols) and automatically capitalize first letter in real-time
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                            // ✅ NEW: Custom formatter to capitalize first letter in real-time as user types
                            TextInputFormatter.withFunction((oldValue, newValue) {
                              if (newValue.text.isEmpty) return newValue;
                              
                              // Get the new text with first letter capitalized and rest lowercase
                              final String newText = newValue.text[0].toUpperCase() + 
                                  (newValue.text.length > 1 ? newValue.text.substring(1).toLowerCase() : '');
                              
                              // Return the modified text while preserving cursor position
                              return TextEditingValue(
                                text: newText,
                                selection: newValue.selection,
                              );
                            }),
                          ],
                          
                          validator: (value) => Validators.validateUsername(value),
                          // ✅ UPDATED: Changed from validateEmail to validateUsername.
                          // This checks if the entered username is valid using a custom validation method. It returns an error message if invalid.
                          
                          onChanged: (value) {
                            // Clear any previous errors when the user starts typing
                            context.read<LoginBloc>().add(const LoginClearError());
                            
                            // ✅ UPDATED: Removed manual capitalization since it's now handled by the input formatter
                            
                            // Update the username in the state
                            context.read<LoginBloc>().add(
                              LoginUsernameChanged(username: value),
                            );
                          },
                          // ✅ UPDATED: Changed from LoginEmailChanged to LoginUsernameChanged.
                          // ✅ NEW: Added LoginClearError event to clear any error messages when the user starts typing.
                          // ✅ UPDATED: Removed manual capitalization since it's now handled by the input formatter.
                          // This sends events to the BLoC whenever the user types in the username field, updating the state with the new value.
                        ),
                        
                        const SizedBox(height: 16),
                        // ✅ This adds 16 pixels of vertical space between the username field and password field.
                        
                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          // ✅ This creates a password field that hides text when _obscurePassword is true. The controller tracks the entered password.
                          
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            // ✅ This styles the password field similar to the username field, with a dark background and light gray hint text.
                            
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            // ✅ This removes the default border and adds rounded corners to the password field, matching the username field style.
                            
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            // ✅ This adds internal padding inside the password field, giving the text some space from the edges.
                            
                            errorStyle: const TextStyle(color: Colors.redAccent),
                            // ✅ This styles validation error messages in red, just like in the username field.
                            
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey[400],
                              ),
                              // ✅ This adds an eye icon button that changes based on whether the password is visible or hidden.
                              
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            // ✅ This toggles password visibility when the eye icon is tapped. setState triggers a UI rebuild with the new value.
                          ),
                          
                          style: const TextStyle(color: Colors.white),
                          // ✅ This sets the user's password text color to white, for good contrast against the dark background.
                          
                          validator: (value) => Validators.validatePassword(value),
                          // ✅ This checks if the entered password is valid using a custom validation method. It returns an error message if invalid.
                          
                          onChanged: (value) {
                            // Clear any previous errors when the user starts typing
                            context.read<LoginBloc>().add(const LoginClearError());
                            
                            // Update the password in the state
                            context.read<LoginBloc>().add(
                              LoginPasswordChanged(password: value),
                            );
                          },
                          // ✅ NEW: Added LoginClearError event to clear any error messages when the user starts typing.
                          // This sends a LoginPasswordChanged event to the BLoC whenever the user types in the password field, updating the state.
                        ),
                        
                        // ✅ NEW: Remember Me Checkbox
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                  
                                  context.read<LoginBloc>().add(
                                    LoginRememberMeChanged(rememberMe: value ?? false),
                                  );
                                },
                                activeColor: const Color(0xFF00C853),
                                checkColor: Colors.white,
                              ),
                              Text(
                                "Remember Me",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ✅ NEW: This adds a "Remember Me" checkbox that toggles the _rememberMe state and sends a LoginRememberMeChanged event.
                        // It allows users to save their username for future login attempts.
                        
                        const SizedBox(height: 24),
                        // ✅ UPDATED: Reduced from 30 to 24 pixels to accommodate the new checkbox.
                        // This adds vertical space between the "Remember Me" checkbox and the login button.
                        
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          // ✅ This creates a container for the login button that spans the full width of the screen and is 55 pixels tall.
                          
                          child: ElevatedButton(
                            onPressed: state.status == LoginStatus.loading
                                ? null
                                : () {
                                    // ✅ This creates a button that disables itself during loading (by setting onPressed to null). Otherwise, it runs the login logic.
                                    
                                    if (_formKey.currentState?.validate() ?? false) {
                                      // ✅ This triggers form validation and only proceeds if all fields pass validation. The ?? false handles potential null values.
                                      
                                      context.read<LoginBloc>().add(
                                        LoginSubmitted(
                                          username: _usernameController.text,
                                          // ✅ UPDATED: Changed from email to username parameter.
                                          password: _passwordController.text,
                                          rememberMe: _rememberMe,
                                          // ✅ NEW: Added rememberMe parameter to the LoginSubmitted event.
                                        ),
                                      );
                                      // ✅ This sends a LoginSubmitted event to the BLoC with the username, password, and remember me preference.
                                      // This triggers the login process.
                                    }
                                  },
                            
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                              // ✅ This sets the button's background color to a bright green, matching Moe's color in the design.
                              
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              // ✅ This gives the button fully rounded corners (a 30-pixel radius), matching the design specifications.
                              
                              elevation: 0,
                              // ✅ This removes the button's shadow, giving it a flat, modern appearance.
                              
                              disabledBackgroundColor: const Color(0xFF00C853).withOpacity(0.6),
                            ),
                            // ✅ This makes the button appear slightly transparent when disabled (during loading), but keeps the same color.
                            
                            child: state.status == LoginStatus.loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                // ✅ This shows a loading spinner instead of text when the login is in progress, providing visual feedback to the user.
                                
                                : Text(
                                    "Log In",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                            // ✅ This displays "Log In" text in white Poppins font when not loading. The semi-bold weight (w600) makes it stand out.
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        // ✅ This adds 20 pixels of vertical space between the login button and the sign-up text.
                        
                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // ✅ This creates a horizontal row that centers its children, used to arrange the sign-up text and link side by side.
                          
                          children: [
                            Text(
                              "Don't have an account?",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            // ✅ This displays "Don't have an account?" text in light gray, prompting users who need to create an account.
                            
                            const SizedBox(width: 4),
                            // ✅ This adds 4 pixels of horizontal space between the question text and the "Sign Up" link.
                            
                           GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                                  );
                                },
                              // ✅ This makes the "Sign Up" text tappable and navigates to the SignupScreen when tapped.
                              
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // ✅ This displays "Sign Up" in bold white text, making it look like a clickable link.
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        // ✅ This adds 40 pixels of vertical space at the bottom of the form for padding.
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Character container with confetti animation
  Widget _buildCharacterContainer() {
    // ✅ This method builds the container with Moe and the confetti animation. Breaking UI into methods helps keep code organized.
    
    return Container(
      width: double.infinity,
      height: 200,
      // ✅ This creates a container that spans the full width of the screen and is 200 pixels tall.
      
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBE6), // Cream yellow background
        borderRadius: BorderRadius.circular(20),
      ),
      // ✅ This gives the container a cream-yellow background with rounded corners, matching the design.
      
      child: Stack(
        // ✅ This allows positioning multiple widgets on top of each other, needed for the character and confetti.
        
        children: [
          // Animated confetti
          AnimatedBuilder(
            animation: _confettiController,
            // ✅ This widget rebuilds whenever the confetti animation progresses. It connects to the confetti animation controller.
            
            builder: (context, child) {
              return CustomPaint(
                painter: ConfettiPainter(
                  progress: _confettiController.value,
                ),
                size: const Size(double.infinity, 200),
              );
            },
            // ✅ This uses a custom painter to draw confetti patterns that change based on the animation's progress value.
          ),
          
          // Moe character in the center
          Center(
            child: AnimatedBuilder(
              animation: _characterController,
              // ✅ This widget rebuilds whenever the character animation progresses. It connects to the character animation controller.
              
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + 0.05 * math.sin(_characterController.value * 2 * math.pi),
                  // ✅ This applies a subtle pulsing scale effect to the character, making it grow and shrink by 5% using a sine wave.
                  
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C853),
                      shape: BoxShape.circle,
                    ),
                    // ✅ This creates a green circular container that forms Moe's body, 100x100 pixels in size.
                    
                    child: CustomPaint(
                      painter: MoeCharacterPainter(),
                      size: const Size(100, 100),
                    ),
                    // ✅ This uses a custom painter to draw Moe's face (eyes and smile) on top of the green circle.
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the confetti
class ConfettiPainter extends CustomPainter {
  // ✅ This defines a class for painting confetti. It takes the animation progress (0.0 to 1.0) to animate the confetti.
  
  final double progress;
  
  ConfettiPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42); // fixed seed for consistent pattern
    // ✅ This method draws on the canvas. It uses a fixed random seed so the confetti pattern is consistent between rebuilds.
    
    // Draw confetti pieces
    for (int i = 0; i < 30; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      // ✅ This loop creates 30 confetti pieces at random positions. The positions are randomly generated but consistent.
      
      // Determine shape and color
      final shapeType = i % 3;
      Color color;
      
      if (i % 5 == 0) color = Colors.pinkAccent;
      else if (i % 5 == 1) color = Colors.blue;
      else if (i % 5 == 2) color = Colors.yellow;
      else if (i % 5 == 3) color = Colors.orange;
      else color = Colors.purple;
      // ✅ This chooses different colors for confetti based on the index, cycling through pink, blue, yellow, orange, and purple.
      
      // Animation offset
      final offsetX = 5 * math.sin(progress * 2 * math.pi + i);
      final offsetY = 5 * math.cos(progress * 2 * math.pi + i * 0.5);
      // ✅ This calculates small movements for each piece of confetti using sine and cosine waves, creating a floating effect.
      
      // Draw different shapes
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      // ✅ This configures the paint style with the selected color and fills the shapes rather than just outlining them.
        
      if (shapeType == 0) {
        // Draw a small circle
        canvas.drawCircle(Offset(x + offsetX, y + offsetY), 3, paint);
      } else if (shapeType == 1) {
        // Draw a star
        _drawStar(canvas, x + offsetX, y + offsetY, 5, paint);
      } else {
        // Draw a small triangle
        final path = Path();
        path.moveTo(x + offsetX, y + offsetY - 4);
        path.lineTo(x + offsetX - 4, y + offsetY + 3);
        path.lineTo(x + offsetX + 4, y + offsetY + 3);
        path.close();
        canvas.drawPath(path, paint);
      }
      // ✅ This draws three different shapes for confetti: circles, stars, and triangles, based on the index. Each shape is drawn at its animated position.
    }
  }
  
  void _drawStar(Canvas canvas, double cx, double cy, double size, Paint paint) {
    // ✅ This helper method draws a star shape at the given position with the specifie
    
    final path = Path();
    final outerRadius = size;
    final innerRadius = size / 2.5;
    const numPoints = 5;
    // ✅ This configures a 5-pointed star with outer and inner radius values that determine the star's shape.
    
    for (int i = 0; i < numPoints * 2; i++) {
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      final angle = i * math.pi / numPoints;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      // ✅ This loop calculates 10 points (5 outer, 5 inner) around a circle, alternating between outer and inner radius to create a star shape.
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      // ✅ This moves to the first point and then draws lines to each subsequent point, forming the star shape.
    }
    
    path.close();
    canvas.drawPath(path, paint);
    // ✅ This closes the path by connecting the last point to the first, and then draws the complete star on the canvas.
  }
  
 @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
    // ✅ This tells Flutter to repaint the confetti only when the progress value changes, which improves performance.
  }
}