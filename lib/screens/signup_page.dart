import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gritflow/blocs/signup/signup_bloc.dart';
import 'package:gritflow/blocs/signup/signup_event.dart';
import 'package:gritflow/blocs/signup/signup_state.dart';
import 'package:gritflow/screens/login_page.dart';
import 'package:gritflow/utils/signup_validator.dart';
import 'dart:math' as math;

class GlowingTextFieldContainer extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Color glowColor;

  const GlowingTextFieldContainer({
    Key? key,
    required this.child,
    required this.isActive,
    this.glowColor = const Color(0xFF00C853),
  }) : super(key: key);

  @override
  State<GlowingTextFieldContainer> createState() => _GlowingTextFieldContainerState();
}

class _GlowingTextFieldContainerState extends State<GlowingTextFieldContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _glowAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.6),
                      blurRadius: _glowAnimation.value,
                      spreadRadius: _glowAnimation.value / 2,
                    )
                  ]
                : [],
          ),
          child: widget.child,
        );
      },
    );
  }
}

class SparkleAnimation extends StatefulWidget {
  final Widget child;
  final bool animate;

  const SparkleAnimation({
    Key? key, 
    required this.child, 
    required this.animate,
  }) : super(key: key);

  @override
  State<SparkleAnimation> createState() => _SparkleAnimationState();
}

class _SparkleAnimationState extends State<SparkleAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Sparkle> _sparkles = [];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
    
    // Create random sparkles
    for (int i = 0; i < 10; i++) {
      _sparkles.add(Sparkle(
        position: math.Random().nextDouble(),
        size: math.Random().nextDouble() * 4 + 2,
        color: Colors.primaries[math.Random().nextInt(Colors.primaries.length)],
      ));
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.animate) 
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: SparklePainter(
                  sparkles: _sparkles,
                  progress: _controller.value,
                ),
              );
            },
          ),
      ],
    );
  }
}

class Sparkle {
  final double position; // 0.0 to 1.0 position horizontally
  final double size;
  final Color color;
  
  Sparkle({
    required this.position,
    required this.size,
    required this.color,
  });
}

class SparklePainter extends CustomPainter {
  final List<Sparkle> sparkles;
  final double progress;
  
  SparklePainter({
    required this.sparkles,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var sparkle in sparkles) {
      final x = sparkle.position * size.width;
      // Animation moves the sparkles up and fades them
      final y = size.height * 0.8 - (progress * size.height * 0.7);
      final opacity = 1.0 - progress;
      
      final paint = Paint()
        ..color = sparkle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      // Draw star shape
      final path = Path();
      for (int i = 0; i < 10; i++) {
        final radius = i.isEven ? sparkle.size : sparkle.size * 0.4;
        final angle = i * math.pi / 5;
        final px = x + radius * math.cos(angle);
        final py = y + radius * math.sin(angle);
        
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(SparklePainter oldDelegate) {
    return true; // Always repaint for continuous animation
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _confettiController;
  late AnimationController _characterController;
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Track which field is currently being edited
  int _activeFieldIndex = -1;
  
  // Map to store field colors
  Map<int, Color> fieldColors = {
    0: Colors.purple,
    1: Colors.blue,
    2: Colors.orange,
    3: Colors.pink,
    4: Colors.teal,
  };
  
  @override
  void initState() {
    super.initState();
    
    // Animation controllers for the confetti and character
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    
    _characterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _confettiController.dispose();
    _characterController.dispose();
    super.dispose();
  }

  // Helper function to capitalize first letter
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupBloc(),
      child: BlocConsumer<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state.status == SignupStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? "Signup failed. Please try again."),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == SignupStatus.success) {
            // Navigate to login screen after successful signup
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Account created successfully! Please log in."),
                backgroundColor: Colors.green,
              ),
            );
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        
                        // "Let's get you signed up!" text
                        Text(
                          "Let's get you signed up!",
                          style: GoogleFonts.pacifico(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Username field
                        GlowingTextFieldContainer(
                          isActive: _activeFieldIndex == 0,
                          glowColor: fieldColors[0]!,
                          child: SparkleAnimation(
                            animate: _activeFieldIndex == 0,
                            child: Focus(
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _activeFieldIndex = hasFocus ? 0 : -1;
                                });
                              },
                              child: TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  hintText: "Enter your username (letters only)",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  filled: true,
                                  fillColor: const Color(0xFF1E1E1E),
                                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  errorStyle: const TextStyle(color: Colors.redAccent),
                                  labelText: "User Name",
                                  labelStyle: TextStyle(color: Colors.grey[400]),
                                ),
                                style: const TextStyle(color: Colors.white),
                                textCapitalization: TextCapitalization.words, // Auto-capitalize words
                                // Only allow letters for username (no numbers or symbols)
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                                ],
                                onChanged: (value) {
                                  // Capitalize first letter, keep rest lowercase
                                  if (value.isNotEmpty) {
                                    final formattedText = capitalizeFirstLetter(value);
                                    if (formattedText != value) {
                                      _usernameController.value = TextEditingValue(
                                        text: formattedText,
                                        selection: TextSelection.collapsed(offset: formattedText.length),
                                      );
                                    }
                                  }
                                  
                                  context.read<SignupBloc>().add(
                                    SignupUsernameChanged(username: value),
                                  );
                                },
                                validator: (value) => Validators.validateUsername(value),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Email field
                        GlowingTextFieldContainer(
                          isActive: _activeFieldIndex == 1,
                          glowColor: fieldColors[1]!,
                          child: SparkleAnimation(
                            animate: _activeFieldIndex == 1,
                            child: Focus(
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _activeFieldIndex = hasFocus ? 1 : -1;
                                });
                              },
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: "demo@email.com",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  filled: true,
                                  fillColor: const Color(0xFF1E1E1E),
                                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  errorStyle: const TextStyle(color: Colors.redAccent),
                                  labelText: "Email",
                                  labelStyle: TextStyle(color: Colors.grey[400]),
                                ),
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                validator: (value) => Validators.validateEmail(value),
                                onChanged: (value) => context.read<SignupBloc>().add(
                                  SignupEmailChanged(email: value),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Phone field
                        GlowingTextFieldContainer(
                          isActive: _activeFieldIndex == 2,
                          glowColor: fieldColors[2]!,
                          child: SparkleAnimation(
                            animate: _activeFieldIndex == 2,
                            child: Focus(
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _activeFieldIndex = hasFocus ? 2 : -1;
                                });
                              },
                              child: TextFormField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  hintText: "+00 000-0000-000",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  filled: true,
                                  fillColor: const Color(0xFF1E1E1E),
                                  prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  errorStyle: const TextStyle(color: Colors.redAccent),
                                  labelText: "Phone no",
                                  labelStyle: TextStyle(color: Colors.grey[400]),
                                ),
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.phone,
                                // Allow only numbers, plus sign, hyphens, parentheses, and spaces
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\+\-\(\)\s]')),
                                ],
                                validator: (value) => Validators.validatePhone(value),
                                onChanged: (value) => context.read<SignupBloc>().add(
                                  SignupPhoneChanged(phone: value),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Password field
                        GlowingTextFieldContainer(
                          isActive: _activeFieldIndex == 3,
                          glowColor: fieldColors[3]!,
                          child: SparkleAnimation(
                            animate: _activeFieldIndex == 3,
                            child: Focus(
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _activeFieldIndex = hasFocus ? 3 : -1;
                                });
                              },
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: "enter your password",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  filled: true,
                                  fillColor: const Color(0xFF1E1E1E),
                                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  errorStyle: const TextStyle(color: Colors.redAccent),
                                  labelText: "Password",
                                  labelStyle: TextStyle(color: Colors.grey[400]),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.grey[400],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  helperText: "Include at least one number or symbol",
                                  helperStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  // Check for at least one number or special character
                                  if (!RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                                    return 'Password must contain at least one number or symbol';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  context.read<SignupBloc>().add(
                                    SignupPasswordChanged(password: value),
                                  );
                                  // Validate confirm password when password changes
                                  if (_confirmPasswordController.text.isNotEmpty) {
                                    _formKey.currentState?.validate();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Confirm Password field
                        GlowingTextFieldContainer(
                          isActive: _activeFieldIndex == 4,
                          glowColor: fieldColors[4]!,
                          child: SparkleAnimation(
                            animate: _activeFieldIndex == 4,
                            child: Focus(
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _activeFieldIndex = hasFocus ? 4 : -1;
                                });
                              },
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  hintText: "Confirm your password",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  filled: true,
                                  fillColor: const Color(0xFF1E1E1E),
                                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  errorStyle: const TextStyle(color: Colors.redAccent),
                                  labelText: "Confirm Password",
                                  labelStyle: TextStyle(color: Colors.grey[400]),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.grey[400],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (value) => Validators.validateConfirmPassword(
                                  value, 
                                  _passwordController.text
                                ),
                                onChanged: (value) => context.read<SignupBloc>().add(
                                  SignupConfirmPasswordChanged(confirmPassword: value),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Create account Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: state.status == SignupStatus.loading
                                ? null
                                : () {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      context.read<SignupBloc>().add(
                                        SignupSubmitted(
                                          username: _usernameController.text,
                                          email: _emailController.text,
                                          phone: _phoneController.text,
                                          password: _passwordController.text,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: const Color(0xFF00C853).withOpacity(0.6),
                            ),
                            child: state.status == SignupStatus.loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Create an account",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              child: Text(
                                "Log In",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Star character with confetti animation
                        _buildStarCharacterContainer(),
                        
                        const SizedBox(height: 40),
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
  
  // Star character container with confetti animation
  Widget _buildStarCharacterContainer() {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated confetti
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: ConfettiPainter(
                  progress: _confettiController.value,
                ),
                size: const Size(double.infinity, 150),
              );
            },
          ),
          
          // Star character in the center
          Center(
            child: AnimatedBuilder(
              animation: _characterController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + 0.05 * math.sin(_characterController.value * 2 * math.pi),
                  child: Container(
                    width: 80,
                    height: 80,
                    child: CustomPaint(
                      painter: StarCharacterPainter(),
                      size: const Size(80, 80),
                    ),
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
  final double progress;
  
  ConfettiPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42); // fixed seed for consistent pattern
    
    // Draw confetti pieces
    for (int i = 0; i < 30; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      
      // Determine shape and color
      final shapeType = i % 3;
      Color color;
      
      if (i % 5 == 0) color = Colors.pinkAccent;
      else if (i % 5 == 1) color = Colors.blue;
      else if (i % 5 == 2) color = Colors.yellow;
      else if (i % 5 == 3) color = Colors.orange;
      else color = Colors.purple;
      
      // Animation offset
      final offsetX = 5 * math.sin(progress * 2 * math.pi + i);
      final offsetY = 5 * math.cos(progress * 2 * math.pi + i * 0.5);
      
      // Draw different shapes
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
        
      if (shapeType == 0) {
        // Draw a small circle
        canvas.drawCircle(Offset(x + offsetX, y + offsetY), 3, paint);
      } else if (shapeType == 1) {
        // Draw a star
        _drawTinyStar(canvas, x + offsetX, y + offsetY, 4, paint);
      } else {
        // Draw a small triangle
        final path = Path();
        path.moveTo(x + offsetX, y + offsetY - 3);
        path.lineTo(x + offsetX - 3, y + offsetY + 2);
        path.lineTo(x + offsetX + 3, y + offsetY + 2);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }
  
  void _drawTinyStar(Canvas canvas, double cx, double cy, double size, Paint paint) {
    final path = Path();
    final outerRadius = size;
    final innerRadius = size / 2.5;
    const numPoints = 5;
    
    for (int i = 0; i < numPoints * 2; i++) {
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      final angle = i * math.pi / numPoints;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Custom painter for Star character
class StarCharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw star base
    final starPath = Path();
    final outerRadius = size.width / 2;
    final innerRadius = size.width / 5;
    const numPoints = 5;
    
    for (int i = 0; i < numPoints * 2; i++) {
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      // Rotate to make star point upward
      final angle = (i * math.pi / numPoints) - math.pi / 2;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    
    starPath.close();
    
     // Fill star with green color
    final starPaint = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(starPath, starPaint);
    
    // Draw face
    // Eyes (happy closed eyes)
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Left eye
    final leftEyePath = Path();
    leftEyePath.moveTo(centerX - 15, centerY - 5);
    leftEyePath.quadraticBezierTo(centerX - 10, centerY - 12, centerX - 5, centerY - 5);
    canvas.drawPath(leftEyePath, eyePaint);
    
    // Right eye
    final rightEyePath = Path();
    rightEyePath.moveTo(centerX + 5, centerY - 5);
    rightEyePath.quadraticBezierTo(centerX + 10, centerY - 12, centerX + 15, centerY - 5);
    canvas.drawPath(rightEyePath, eyePaint);
    
    // Draw smile
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final smilePath = Path();
    smilePath.moveTo(centerX - 10, centerY + 5);
    smilePath.quadraticBezierTo(centerX, centerY + 15, centerX + 10, centerY + 5);
    smilePath.quadraticBezierTo(centerX, centerY + 8, centerX - 10, centerY + 5);
    smilePath.close();
    
    canvas.drawPath(smilePath, smilePaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}