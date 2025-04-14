import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'package:gritflow/screens/login_page.dart';
import 'package:gritflow/screens/home_screen.dart';
import 'package:gritflow/hive/hive_crud.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _entranceController;
  late AnimationController _exitController;
  late AnimationController _shrinkController;
  late AnimationController _starController;
  late AnimationController _confettiController;
  
  // Movement animations
  late Animation<Offset> _entranceAnimation;
  late Animation<Offset> _exitAnimation;
  
  // Black hole transition effect
  late Animation<double> _shrinkAnimation;
  
  // Star animation
  late Animation<double> _starScaleAnimation;
  
  // Hive service
  final HiveUserService _userService = HiveUserService();

  // Flag to track if user is already logged in
  bool _isUserLoggedIn = false;
  
  @override
  void initState() {
    super.initState();
    
    // Check if user is already logged in
    _checkLoginStatus();
    
    // Snake entrance motion controller (2 seconds)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Snake exit motion controller (1.5 seconds)
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Screen shrink effect controller (1 second)
    _shrinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Star animation controller
    _starController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 2000),
    );
    
    // Confetti animation controller
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    
    // Define entrance movement: right bottom to center
    _entranceAnimation = TweenSequence<Offset>([
      // Start off screen at right bottom
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(1.0, 0.8),
          end: const Offset(0.0, 0.0),
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 60,
      ),
      // Move slightly beyond target
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: const Offset(-0.08, 0.08),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      // Settle into final position
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-0.08, 0.08),
          end: const Offset(0.0, 0.0),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_entranceController);
    
    // Define exit movement: center to left bottom
    _exitAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(-1.0, 0.8),
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInQuad,
    ));
    
    // Define shrink animation for black hole effect
    _shrinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _shrinkController,
      curve: Curves.easeInExpo,
    ));
    
    // Define star scale animation
    _starScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0),
        weight: 50,
      ),
    ]).animate(_starController);
    
    // Start the entrance animation
    _entranceController.forward();
    
    // Start the star animation with repeat
    _starController.repeat();
    
    // Start confetti animation with repeat
    _confettiController.repeat();
    
    // Animation sequence with appropriate timing
    Future.delayed(const Duration(seconds: 3), () {
      // Update the speech bubble text
      setState(() {
        _speechBubbleText = "It's more fun together!";
      });
      
      // Wait for a moment after showing the new text
      Future.delayed(const Duration(milliseconds: 1500), () {
        // Start exit animation
        _exitController.forward();
        
        // When exit animation is nearly done, start the shrink effect
        Future.delayed(const Duration(milliseconds: 1200), () {
          _shrinkController.forward().then((_) {
            // Navigate to the appropriate screen based on login status
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => _isUserLoggedIn
                  ? const HomeScreen()  // Navigate to home if logged in
                  : const LoginScreen(), // Navigate to login if not logged in
              ),
            );
          });
        });
      });
    });
  }
  
  // Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await _userService.isLoggedIn();
      setState(() {
        _isUserLoggedIn = isLoggedIn;
      });
      
      // If user is logged in, customize the message shown
      if (isLoggedIn) {
        final user = await _userService.getCurrentUser();
        if (user != null) {
          setState(() {
            _initialBubbleText = "Welcome back,\n${user.username}!";
          });
        }
      }
    } catch (e) {
      // If there's an error checking login status, default to not logged in
      setState(() {
        _isUserLoggedIn = false;
      });
    }
  }
  
  @override
  void dispose() {
    _entranceController.dispose();
    _exitController.dispose();
    _shrinkController.dispose();
    _starController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // Initial speech bubble text
  String _initialBubbleText = "Today's a perfect\nday to grow!";
  // Speech bubble text that will change
  String _speechBubbleText = "Today's a perfect\nday to grow!";

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _shrinkController,
        builder: (context, child) {
          return Transform.scale(
            scale: _shrinkAnimation.value,
            alignment: Alignment.center,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            // Main content column
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top section with text
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.12),
                  child: _buildAppTitle(),
                ),
                
                // Bottom section with star character
                _buildStarSection(size),
              ],
            ),
            
            // Animated capsule character with speech bubble
            Positioned(
              right: 0,
              top: size.height * 0.38,
              child: AnimatedBuilder(
                animation: Listenable.merge([_entranceController, _exitController]),
                builder: (context, child) {
                  // Use entrance animation until it's complete
                  if (!_entranceController.isCompleted || !_exitController.isAnimating) {
                    return SlideTransition(
                      position: _entranceAnimation,
                      child: child,
                    );
                  } 
                  // Then use exit animation
                  else {
                    return SlideTransition(
                      position: _exitAnimation,
                      child: child,
                    );
                  }
                },
                child: _buildSnakeWithSpeechBubble(size),
              ),
            ),
            
            // Decorative elements (confetti/stars/shapes)
            ..._buildDecorations(size),
          ],
        ),
      ),
    );
  }

  // App title text with alternating colors
  Widget _buildAppTitle() {
    const greenColor = Color(0xFF00C853);
    
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            children: const [
              TextSpan(text: "GO FOR\n"),
              TextSpan(
                text: "BETTER\nHABITS\n",
                style: TextStyle(color: greenColor),
              ),
              TextSpan(text: "WITH\nMOE"),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Heartbeat line
        Image.asset(
          'assets/images/heartbeat_line.png',
          width: 100,
          height: 20,
          // If asset is missing, use a placeholder
          errorBuilder: (context, error, stackTrace) => Container(
            width: 100,
            height: 20,
            alignment: Alignment.center,
            child: const Text('~~~~~', style: TextStyle(color: greenColor)),
          ),
        ),
      ],
    );
  }

  // Snake character with speech bubble
  Widget _buildSnakeWithSpeechBubble(Size size) {
    return SizedBox(
      width: size.width * 0.8,
      child: Stack(
        children: [
          // Snake character - larger size
          Transform.rotate(
            angle: -0.1, // Slight tilt
            child: Container(
              width: size.width * 0.75,
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFF00C853),
                borderRadius: BorderRadius.all(Radius.circular(70)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Eyes and smile
                  Container(
                    margin: const EdgeInsets.only(right: 40, top: 35),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Smile
                        Container(
                          width: 40,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black,
                                width: 3,
                              ),
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Speech bubble with dynamic text
          Positioned(
            bottom: 0,
            left: 10,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey<String>(_speechBubbleText),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _speechBubbleText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Star character at bottom with confetti
  Widget _buildStarSection(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * 0.3,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Star with confetti effect
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Confetti around the star
                AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ConfettiPainter(
                        progress: _confettiController.value,
                      ),
                      size: const Size(140, 140),
                    );
                  },
                ),
                
                // Star character with smile
                AnimatedBuilder(
                  animation: _starController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _starScaleAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 65,
                    height: 65,
                    child: CustomPaint(
                      painter: SmileStarPainter(),
                      size: const Size(65, 65),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation dots
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Background decorations (stars, dots, triangles)
  List<Widget> _buildDecorations(Size size) {
    return [
      // Green triangle decoration at top right
      Positioned(
        right: size.width * 0.1,
        top: size.height * 0.1,
        child: Transform.rotate(
          angle: 0.5,
          child: CustomPaint(
            size: const Size(20, 20),
            painter: TrianglePainter(color: const Color(0xFF00C853)),
          ),
        ),
      ),
      
      // Pink stars
      Positioned(
        left: size.width * 0.15,
        top: size.height * 0.25,
        child: const Icon(Icons.star, color: Colors.pinkAccent, size: 18),
      ),
      Positioned(
        right: size.width * 0.25,
        top: size.height * 0.35,
        child: const Icon(Icons.star, color: Colors.pinkAccent, size: 15),
      ),
      Positioned(
        left: size.width * 0.15,
        bottom: size.height * 0.1,
        child: const Icon(Icons.star, color: Colors.pinkAccent, size: 16),
      ),
      
      // Yellow dots and stars
      Positioned(
        left: size.width * 0.08,
        top: size.height * 0.45,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        right: size.width * 0.1,
        bottom: size.height * 0.18,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        right: size.width * 0.3,
        bottom: size.height * 0.15,
        child: const Icon(Icons.star, color: Colors.amber, size: 14),
      ),
      
      // Blue triangles and dots
      Positioned(
        left: size.width * 0.3,
        top: size.height * 0.4,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        left: size.width * 0.12,
        bottom: size.height * 0.3,
        child: Transform.rotate(
          angle: math.pi,
          child: CustomPaint(
            size: const Size(15, 15),
            painter: TrianglePainter(color: Colors.blue),
          ),
        ),
      ),
      Positioned(
        right: size.width * 0.35,
        top: size.height * 0.32,
        child: CustomPaint(
          size: const Size(20, 20),
          painter: TrianglePainter(color: Colors.blue),
        ),
      ),
    ];
  }
}

// Custom painter for confetti around the star
class ConfettiPainter extends CustomPainter {
  final double progress;
  
  ConfettiPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42); // fixed seed for consistent pattern
    
    // Draw confetti pieces
    for (int i = 0; i < 20; i++) {
      final angle = (progress * 2 * math.pi) + (i * math.pi / 10);
      
      // Radius varies with time for movement effect
      final radiusMultiplier = 0.7 + 0.3 * math.sin(progress * 2 * math.pi + i);
      final radius = size.width * 0.4 * radiusMultiplier;
      
      // Calculate position
      final x = size.width / 2 + radius * math.cos(angle);
      final y = size.height / 2 + radius * math.sin(angle);
      
      // Determine shape and color
      final shapeType = i % 3;
      Color color;
      
      if (i % 5 == 0) color = Colors.pinkAccent;
      else if (i % 5 == 1) color = Colors.blue;
      else if (i % 5 == 2) color = Colors.yellow;
      else if (i % 5 == 3) color = Colors.red;
      else color = Colors.orange;
      
      // Draw different shapes
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
        
      if (shapeType == 0) {
        // Draw a small circle
        canvas.drawCircle(Offset(x, y), 3, paint);
      } else if (shapeType == 1) {
        // Draw a small square
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 5, height: 5),
          paint,
        );
      } else {
        // Draw a small triangle
        final path = Path();
        path.moveTo(x, y - 3);
        path.lineTo(x - 3, y + 2);
        path.lineTo(x + 3, y + 2);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Custom painter for smiling star character
class SmileStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.fill;
      
    // Draw star shape
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = size.width / 4;
    const numPoints = 5;
    final angleIncrement = (2 * math.pi) / (numPoints * 2);
    
    double angle = -math.pi / 2; // Start at the top
    
    path.moveTo(
      centerX + outerRadius * math.cos(angle),
      centerY + outerRadius * math.sin(angle),
    );
    
    for (int i = 0; i < numPoints * 2; i++) {
      angle += angleIncrement;
      double nextRadius = i % 2 == 0 ? innerRadius : outerRadius;
      path.lineTo(
        centerX + nextRadius * math.cos(angle),
        centerY + nextRadius * math.sin(angle),
      );
    }
    
    path.close();
    canvas.drawPath(path, greenPaint);
    
    // Draw face
    final facePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    // Eyes (curved lines for happy closed eyes)
    final leftEyePath = Path();
    leftEyePath.moveTo(centerX - 10, centerY - 5);
    leftEyePath.quadraticBezierTo(centerX - 8, centerY - 10, centerX - 6, centerY - 5);
    canvas.drawPath(leftEyePath, facePaint);
    
    final rightEyePath = Path();
    rightEyePath.moveTo(centerX + 6, centerY - 5);
    rightEyePath.quadraticBezierTo(centerX + 8, centerY - 10, centerX + 10, centerY - 5);
    canvas.drawPath(rightEyePath, facePaint);
    
    // Smile
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
      
    final smilePath = Path();
    smilePath.moveTo(centerX - 10, centerY + 2);
    smilePath.quadraticBezierTo(centerX, centerY + 12, centerX + 10, centerY + 2);
    smilePath.quadraticBezierTo(centerX, centerY + 7, centerX - 10, centerY + 2);
    smilePath.close();
    canvas.drawPath(smilePath, smilePaint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for triangle shapes
class TrianglePainter extends CustomPainter {
  final Color color;
  
  TrianglePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
      
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}