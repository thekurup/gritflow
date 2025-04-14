import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// 1. Disappointed Buddy Character Painter
class DisappointedBuddyPainter extends CustomPainter {
  final double frownStrength; // 0.0 to 1.0 for animation
  final bool isShakingHead;
  
  DisappointedBuddyPainter({
    this.frownStrength = 1.0,
    this.isShakingHead = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.fill;
    
    // Center of the pentagon
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.4;
    
    // Draw pentagon with slight horizontal shake if needed
    final shakeOffset = isShakingHead ? math.sin(DateTime.now().millisecondsSinceEpoch * 0.02) * 3 : 0.0;
    final path = Path();
    
    for (int i = 0; i < 5; i++) {
      final angle = 2 * math.pi / 5 * i - math.pi / 2;
      final x = centerX + shakeOffset + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
    
    // Draw eyes (slightly sad)
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    // Left eye - sad tilt
    canvas.drawCircle(
      Offset(centerX - 10, centerY - 5 + frownStrength * 2),
      3,
      eyePaint,
    );
    
    // Right eye - sad tilt
    canvas.drawCircle(
      Offset(centerX + 10, centerY - 5 + frownStrength * 2),
      3,
      eyePaint,
    );
    
    // Draw frown (instead of smile)
    final frownPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final frownPath = Path();
    frownPath.moveTo(centerX - 10, centerY + 5 + frownStrength * 2);
    frownPath.quadraticBezierTo(
      centerX, centerY - frownStrength * 5, // Control point goes up for frown
      centerX + 10, centerY + 5 + frownStrength * 2,
    );
    
    canvas.drawPath(frownPath, frownPaint);
    
    // Draw droopy arms
    final armPaint = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Left droopy arm
    final leftArmPath = Path();
    leftArmPath.moveTo(centerX - radius * 0.7, centerY + radius * 0.2);
    leftArmPath.quadraticBezierTo(
      centerX - radius * 0.8, centerY + radius * 0.5 + frownStrength * 5,
      centerX - radius * 0.9, centerY + radius * 0.6 + frownStrength * 5,
    );
    
    // Right droopy arm
    final rightArmPath = Path();
    rightArmPath.moveTo(centerX + radius * 0.7, centerY + radius * 0.2);
    rightArmPath.quadraticBezierTo(
      centerX + radius * 0.8, centerY + radius * 0.5 + frownStrength * 5,
      centerX + radius * 0.9, centerY + radius * 0.6 + frownStrength * 5,
    );
    
    canvas.drawPath(leftArmPath, armPaint);
    canvas.drawPath(rightArmPath, armPaint);
  }
  
  @override
  bool shouldRepaint(covariant DisappointedBuddyPainter oldDelegate) {
    return oldDelegate.frownStrength != frownStrength || 
           oldDelegate.isShakingHead != isShakingHead;
  }
}

// 2. Speech Bubble Widget
class SpeechBubble extends StatelessWidget {
  final String message;
  final double opacity;
  
  const SpeechBubble({
    Key? key,
    required this.message,
    this.opacity = 1.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Stack(
        children: [
          // Bubble background
          CustomPaint(
            painter: BubblePainter(),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 15),
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    final path = Path();
    
    // Draw rounded rectangle
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height - 10),
        const Radius.circular(10),
      ),
    );
    
    // Add triangle pointer at bottom
    path.moveTo(20, size.height - 10);
    path.lineTo(10, size.height);
    path.lineTo(30, size.height - 10);
    path.close();
    
    // Draw shadow first
    canvas.drawPath(path, shadowPaint);
    // Then draw bubble
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3. Skipped Task Animation Widget
class SkippedTaskAnimation extends StatefulWidget {
  final Widget child;
  final bool isSkipped;
  final VoidCallback onUndoTap;
  
  const SkippedTaskAnimation({
    Key? key,
    required this.child,
    required this.isSkipped,
    required this.onUndoTap,
  }) : super(key: key);
  
  @override
  State<SkippedTaskAnimation> createState() => _SkippedTaskAnimationState();
}

class _SkippedTaskAnimationState extends State<SkippedTaskAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _showUndoButton = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showUndoButton = true;
        });
        
        // Auto-hide undo button after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && _showUndoButton) {
            setState(() {
              _showUndoButton = false;
            });
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _showUndoButton = false;
        });
      }
    });
  }
  
  @override
  void didUpdateWidget(SkippedTaskAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSkipped && !oldWidget.isSkipped) {
      _controller.forward();
    } else if (!widget.isSkipped && oldWidget.isSkipped) {
      _controller.reverse();
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
        // Original child with animations
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.grey.withOpacity(_controller.value * 0.2),
                    BlendMode.srcATop,
                  ),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
        
        // Undo button with slide animation
        if (_showUndoButton)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 50.0, end: 0.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(value, 0),
                  child: child,
                );
              },
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onUndoTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C853).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.undo,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Undo',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// 4. Main Disappointed Buddy Animation Controller
class DisappointedBuddyAnimationController extends StatefulWidget {
  final String username;
  final bool triggerAnimation;
  final VoidCallback onAnimationComplete;
  
  const DisappointedBuddyAnimationController({
    Key? key,
    required this.username,
    required this.triggerAnimation,
    required this.onAnimationComplete,
  }) : super(key: key);
  
  @override
  State<DisappointedBuddyAnimationController> createState() =>
      _DisappointedBuddyAnimationControllerState();
}

class _DisappointedBuddyAnimationControllerState
    extends State<DisappointedBuddyAnimationController>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _positionController;
  late AnimationController _buddyController;
  late AnimationController _bubbleController;
  late AnimationController _glowController;
  
  // Animations
  late Animation<double> _buddyPositionY;
  late Animation<double> _buddyPositionX;
  late Animation<double> _buddyFrownAnimation;
  late Animation<double> _buddyShakeAnimation;
  late Animation<double> _bubbleOpacityAnimation;
  late Animation<double> _glowRadiusAnimation;
  
  final List<String> _messages = [
    "Skipping is fine, but don't forget to come back stronger!",
    "Let's try again tomorrow!",
    "It's okay to skip sometimes, but don't make it a habit!",
    "Taking a break? That's fine, we'll conquer this later!",
  ];
  
  late String _currentMessage;
  bool _isAnimating = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize random message
    _currentMessage = _getRandomMessage();
    
    // Position animation (move from quote box to top left)
    _positionController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Buddy facial expression animation
    _buddyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Speech bubble animation
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Glow effect animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Define animation curves
    _buddyPositionY = Tween<double>(
      begin: 200.0, // Start from quote box (approximate Y position)
      end: 50.0,    // End near the username greeting
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOutBack,
    ));
    
    _buddyPositionX = Tween<double>(
      begin: 150.0, // Center X (will be adjusted in build method)
      end: 50.0,    // Left side X position
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOut,
    ));
    
    _buddyFrownAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buddyController,
      curve: Curves.easeInOut,
    ));
    
    _buddyShakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buddyController,
      curve: Curves.elasticIn,
    ));
    
    _bubbleOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeInOut,
    ));
    
    _glowRadiusAnimation = Tween<double>(
      begin: 0.0,
      end: 40.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOut,
    ));
    
    // Set up animation sequence listeners
    _positionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _buddyController.forward();
      }
    });
    
    _buddyController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _bubbleController.forward();
      }
    });
    
    _bubbleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _glowController.forward();
      }
    });
    
    _glowController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Wait a moment, then dismiss
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _dismissAnimation();
          }
        });
      }
    });
  }
  
  @override
  void didUpdateWidget(DisappointedBuddyAnimationController oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Start animation if triggered
    if (widget.triggerAnimation && !oldWidget.triggerAnimation && !_isAnimating) {
      _startAnimation();
    }
  }
  
  void _startAnimation() {
    setState(() {
      _isAnimating = true;
      _currentMessage = _getRandomMessage();
    });
    
    _positionController.forward();
  }
  
  void _dismissAnimation() {
    // Reverse everything smoothly
    _glowController.reverse();
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _bubbleController.reverse();
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _buddyController.reverse();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _positionController.reverse().then((_) {
          setState(() {
            _isAnimating = false;
          });
          widget.onAnimationComplete();
        });
      }
    });
  }
  
  String _getRandomMessage() {
    final random = math.Random();
    String message = _messages[random.nextInt(_messages.length)];
    
    // Replace placeholder with actual username if present
    if (widget.username.isNotEmpty) {
      message = message.replaceAll("username", widget.username);
    }
    
    return message;
  }
  
  @override
  void dispose() {
    _positionController.dispose();
    _buddyController.dispose();
    _bubbleController.dispose();
    _glowController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isAnimating) {
      return const SizedBox.shrink();
    }
    
    // Update the start position X based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    // Set the start position to the center of the screen
    _buddyPositionX = Tween<double>(
      begin: screenWidth / 2, 
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOut,
    ));
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _positionController,
        _buddyController,
        _bubbleController,
        _glowController,
      ]),
      builder: (context, child) {
        return Stack(
          children: [
            // Background overlay when animation is active
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Container(
                  color: Colors.black.withOpacity(0.02),
                ),
              ),
            ),
            
            // Positioned buddy with glow effect
            Positioned(
              left: _buddyPositionX.value - 30, // Adjust based on buddy size
              top: _buddyPositionY.value - 30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (_glowController.value > 0)
                      BoxShadow(
                        color: const Color(0xFF00C853).withOpacity(0.3),
                        blurRadius: _glowRadiusAnimation.value,
                        spreadRadius: _glowRadiusAnimation.value * 0.2,
                      ),
                  ],
                ),
                child: CustomPaint(
                  painter: DisappointedBuddyPainter(
                    frownStrength: _buddyFrownAnimation.value,
                    isShakingHead: _buddyController.value > 0.3 && 
                                  _buddyController.value < 0.8,
                  ),
                ),
              ),
            ),
            
            // Speech bubble positioned above buddy
            Positioned(
              left: _buddyPositionX.value - 80, // Wider than buddy
              top: _buddyPositionY.value - 90, // Above buddy
              width: 200,
              child: Opacity(
                opacity: _bubbleOpacityAnimation.value,
                child: SpeechBubble(
                  message: _currentMessage,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}