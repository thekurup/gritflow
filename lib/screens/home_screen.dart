import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gritflow/blocs/quotes/quote_service.dart';
import 'package:gritflow/hive/hive_habit_service.dart';
import 'package:gritflow/blocs/quotes/quote_cubit.dart';
import 'package:gritflow/blocs/quotes/quote_state.dart';
import 'package:gritflow/widgets/disappointed_buddy_animation.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

import 'package:gritflow/hive/hive_crud.dart';
import 'package:gritflow/models/habit_model.dart';
import 'package:gritflow/models/user_model.dart';
import 'package:gritflow/screens/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final HiveUserService _userService = HiveUserService();
  final HiveHabitService _habitService = HiveHabitService();
  
  UserModel? _currentUser;
  List<HabitModel> _habits = [];
  bool _isLoading = true;
  int _selectedNavIndex = 0;
  
  // Disappointed buddy animation state
  bool _showDisappointedBuddy = false;
  String _lastSkippedHabitId = '';
  
  // Animation controllers
  late AnimationController _characterController;
  late AnimationController _characterWaveController;
  late AnimationController _quoteController;
  late AnimationController _navGlowController;
  
  // Animations
  late Animation<double> _characterScale;
  late Animation<double> _characterWave;
  late Animation<double> _quoteOpacity;
  late Animation<double> _navGlowAnimation;
  
  @override
  void initState() {
    super.initState();
    print("HomeScreen initState called");
    _loadUserData();
    _loadHabits();
    
    // Character animation controller (bobbing effect)
    _characterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    // Character wave animation
    _characterWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    // Quote fade in-out animation
    _quoteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    // Nav glow animation
    _navGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Define animations
    _characterScale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _characterController,
      curve: Curves.easeInOut,
    ));
    
    _characterWave = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _characterWaveController,
      curve: Curves.easeInOut,
    ));
    
    _quoteOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7),
        weight: 20,
      ),
    ]).animate(_quoteController);
    
    _navGlowAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _navGlowController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _characterController.dispose();
    _characterWaveController.dispose();
    _quoteController.dispose();
    _navGlowController.dispose();
    super.dispose();
  }

  // Load user data from Hive
  Future<void> _loadUserData() async {
    try {
      print("Loading user data...");
      final user = await _userService.getCurrentUser();
      print("User loaded: ${user?.username}");
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Load habits (mock data for now)
  Future<void> _loadHabits() async {
    try {
      print("Loading habits...");
      // Use getMockHabits instead of getHabits
      final habits = await _habitService.getMockHabits();
      print("Habits loaded: ${habits.length}");
      setState(() {
        _habits = habits;
      });
    } catch (e) {
      print("Error loading habits: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading habits: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Mark habit as completed/skipped
  void _toggleHabit(String id, bool completed) {
    setState(() {
      final index = _habits.indexWhere((habit) => habit.id == id);
      if (index != -1) {
        final wasCompletedBefore = _habits[index].completed;
        _habits[index] = _habits[index].copyWith(completed: completed);
        
        // Update in Hive (in a real app)
        _habitService.updateHabit(_habits[index]);
        
        // If this is a new skip, trigger disappointed buddy animation
        if (!wasCompletedBefore && completed) {
          _lastSkippedHabitId = id;
          
          // First show task with "Skip" changed to "Done"
          // then trigger animation after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _showDisappointedBuddy = true;
              });
            }
          });
        }
      }
    });
  }
  
  // Undo skip
  void _undoSkip(String id) {
    setState(() {
      final index = _habits.indexWhere((habit) => habit.id == id);
      if (index != -1) {
        _habits[index] = _habits[index].copyWith(completed: false);
        
        // Update in Hive (in a real app)
        _habitService.updateHabit(_habits[index]);
        
        // If this was the last skipped habit, clear the disappointed state
        if (id == _lastSkippedHabitId) {
          _lastSkippedHabitId = '';
          _showDisappointedBuddy = false;
        }
      }
    });
  }
  
  // Called when buddy animation completes
  void _onBuddyAnimationComplete() {
    setState(() {
      _showDisappointedBuddy = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    print("Building HomeScreen, isLoading: $_isLoading");
    
    // Start with a simple UI for debugging
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00C853),
              ),
            )
          : Stack(
              children: [
                // Main content
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Header with username and day strip
                          _buildHeader(),
                          
                          const SizedBox(height: 24),
                          
                          // Characters with quote bubble - FIXED to prevent overflow
                          _buildSimpleCharacterSection(),
                          
                          const SizedBox(height: 30),
                          
                          // Habits section
                          _buildHabitsSection(),
                          
                          // Extra space at bottom
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Disappointed buddy animation overlay
                if (_showDisappointedBuddy)
                  DisappointedBuddyAnimationController(
                    username: _currentUser?.username ?? 'User',
                    triggerAnimation: _showDisappointedBuddy,
                    onAnimationComplete: _onBuddyAnimationComplete,
                  ),
              ],
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
  
  // Header with username and day strip
  Widget _buildHeader() {
    // Get current date/time
    final now = DateTime.now();
    final dayFormat = DateFormat('E'); // Short day name (e.g., "Mon")
    final dateFormat = DateFormat('d'); // Day number (e.g., "15")
    
    // Generate the weekday items
    List<Widget> weekDays = [];
    for (int i = 0; i < 7; i++) {
      // Calculate the date for each day of the week
      final day = now.subtract(Duration(days: now.weekday - 1 - i));
      final dayName = dayFormat.format(day).toUpperCase();
      final dayNum = dateFormat.format(day);
      final isToday = day.day == now.day && 
                      day.month == now.month && 
                      day.year == now.year;
      
      weekDays.add(
        Container(
          width: 36,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFF1A1A1A) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: [
              Text(
                dayName.substring(0, 2), // Just take first 2 chars
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isToday ? Colors.white : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFF121212) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    dayNum,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username greeting
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            children: [
              const TextSpan(text: 'Hey, '),
              TextSpan(
                text: _currentUser?.username ?? 'User',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '!'),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Weekday strip
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: weekDays),
        ),
      ],
    );
  }
  
  // Simplified character section with fixed overflow issue
  Widget _buildSimpleCharacterSection() {
    // Check if any habit was recently skipped to change pentagon's mood
    final bool anyHabitSkipped = _showDisappointedBuddy;
    
    return Container(
      width: double.infinity,
      height: 150, // Keep original height
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBE6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Quote bubble - with ClipRect to prevent overflow
          Expanded(
            child: ClipRect(
             child: BlocProvider(
  create: (context) => QuoteCubit(
    quoteService: DefaultQuoteService(),
  )..fetchQuote(),
  child: BlocBuilder<QuoteCubit, QuoteState>(
    builder: (context, state) {
      String quoteText = "Today is your opportunity to build the tomorrow you want.";
                    
                    if (state is QuoteLoaded) {
                      quoteText = state.quote;
                    } else if (state is QuoteError) {
                      quoteText = "A positive mindset makes all the difference!";
                    }
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          quoteText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          // Limit to 2 lines to prevent overflow
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8), // Fixed gap instead of Spacer
          
          // Character row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Pentagon character - now with isSkipped parameter
              AnimatedBuilder(
                animation: _characterController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _characterScale.value,
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: CustomPaint(
                        painter: PentagonCharacterPainter(
                          isSkipped: anyHabitSkipped,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Water glass character
              AnimatedBuilder(
                animation: _characterWaveController,
                builder: (context, child) {
                  return SizedBox(
                    width: 60,
                    height: 70,
                    child: CustomPaint(
                      painter: WaterGlassCharacterPainter(
                        waveOffset: _characterWave.value,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Habits list section
  Widget _buildHabitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Habits header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Color(0xFF00C853),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM d').format(DateTime.now()),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Habits list - Now uses SkippedTaskAnimation widget
        ..._habits.map((habit) {
          // Check if this habit is skipped to show animation
          final isSkipped = habit.completed && _lastSkippedHabitId == habit.id;
          
          return SkippedTaskAnimation(
            isSkipped: isSkipped,
            onUndoTap: () => _undoSkip(habit.id),
            child: _buildHabitCard(habit),
          );
        }).toList(),
        
        // Add habit button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: InkWell(
            onTap: () {
              // Handle add habit action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add habit clicked!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF00C853).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF00C853),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+ New habit',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF00C853),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Single habit card - modified to work with skip animation
  Widget _buildHabitCard(HabitModel habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C853).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Toggle habit completion on tap
          _toggleHabit(habit.id, !habit.completed);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Habit icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  habit.icon,
                  color: const Color(0xFF00C853),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Habit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        decoration: habit.completed 
                            ? TextDecoration.lineThrough 
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.duration} min',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Skip/Done button
              TextButton(
                onPressed: habit.completed 
                    ? null 
                    : () {
                        // Mark as skipped
                        _toggleHabit(habit.id, true);
                      },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                  backgroundColor: const Color(0xFF222222),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
                child: Text(
                  habit.completed ? 'Done' : 'Skip',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: habit.completed ? Colors.green[200] : Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Bottom navigation bar with glow effect
  Widget _buildBottomNav() {
    // Navigation items
    final navItems = [
      const NavigationItem(icon: Icons.home, label: 'Home'),
      const NavigationItem(icon: Icons.add_circle_outline, label: 'Add'),
      const NavigationItem(icon: Icons.pause_circle_outline, label: 'Pause'),
      const NavigationItem(icon: Icons.person, label: 'Profile'),
    ];
    
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          return AnimatedBuilder(
            animation: _navGlowController,
            builder: (context, child) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedNavIndex = index;
                  });
                  
                  // Handle navigation
                  if (index == 3) { // Profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: _selectedNavIndex == index
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00C853).withOpacity(0.3),
                              blurRadius: _navGlowAnimation.value * 10,
                              spreadRadius: _navGlowAnimation.value * 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        navItems[index].icon,
                        color: _selectedNavIndex == index
                            ? const Color(0xFF00C853)
                            : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        navItems[index].label,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: _selectedNavIndex == index
                              ? const Color(0xFF00C853)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// Navigation item model
class NavigationItem {
  final IconData icon;
  final String label;
  
  const NavigationItem({
    required this.icon,
    required this.label,
  });
}

// Pentagon character painter - Updated to accept isSkipped parameter
class PentagonCharacterPainter extends CustomPainter {
  final bool isSkipped;
  
  PentagonCharacterPainter({
    this.isSkipped = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.fill;
    
    // Draw pentagon
    final path = Path();
    final centerX = size.width / 2;
    const centerY = 35.0;
    const radius = 32.0;
    
    for (int i = 0; i < 5; i++) {
      final angle = 2 * math.pi / 5 * i - math.pi / 2;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
    
    // Draw eyes
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    // Left eye
    canvas.drawCircle(
      Offset(centerX - 10, centerY - 5),
      3,
      eyePaint,
    );
    
    // Right eye
    canvas.drawCircle(
      Offset(centerX + 10, centerY - 5),
      3,
      eyePaint,
    );
    
    // Draw mouth - smile or frown based on isSkipped
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final mouthPath = Path();
    
    if (isSkipped) {
      // Draw frown when skipped
      mouthPath.moveTo(centerX - 10, centerY + 5);
      mouthPath.quadraticBezierTo(
        centerX, centerY - 5, // Control point goes up for frown
        centerX + 10, centerY + 5,
      );
    } else {
      // Draw smile when not skipped
      mouthPath.moveTo(centerX - 10, centerY + 5);
      mouthPath.quadraticBezierTo(
        centerX, centerY + 15,
        centerX + 10, centerY + 5,
      );
    }
    
    canvas.drawPath(mouthPath, mouthPaint);
  }
  
  @override
  bool shouldRepaint(covariant PentagonCharacterPainter oldDelegate) {
    return oldDelegate.isSkipped != isSkipped;
  }
}

// Water glass character painter
class WaterGlassCharacterPainter extends CustomPainter {
  final double waveOffset;
  
  WaterGlassCharacterPainter({required this.waveOffset});
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw glass outline
    final glassPaint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final glassPath = Path();
    glassPath.moveTo(centerX - 18, centerY - 25);
    glassPath.lineTo(centerX - 15, centerY + 20);
    glassPath.lineTo(centerX + 15, centerY + 20);
    glassPath.lineTo(centerX + 18, centerY - 25);
    glassPath.close();
    
    canvas.drawPath(glassPath, glassPaint);
    
    // Draw water inside glass
    final waterPaint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    // Create wave effect for water surface
    final waterPath = Path();
    waterPath.moveTo(centerX - 15, centerY + 5);
    
    // Dynamic wave based on animation
    for (int i = 0; i <= 6; i++) {
      final x = centerX - 15 + i * 5;
      final waveHeight = math.sin((i / 3) + (waveOffset * 10)) * 4;
      waterPath.lineTo(x, centerY + waveHeight);
    }
    
    waterPath.lineTo(centerX + 15, centerY + 5);
    waterPath.lineTo(centerX + 15, centerY + 20);
    waterPath.lineTo(centerX - 15, centerY + 20);
    waterPath.close();
    
    canvas.drawPath(waterPath, waterPaint);
    
    // Draw face
    final facePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    // Eyes
    canvas.drawCircle(Offset(centerX - 7, centerY), 2, facePaint);
    canvas.drawCircle(Offset(centerX + 7, centerY), 2, facePaint);
    
    // Smile
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final smilePath = Path();
    smilePath.moveTo(centerX - 6, centerY + 6);
    smilePath.quadraticBezierTo(
      centerX, centerY + 10,
      centerX + 6, centerY + 6,
    );
    
    canvas.drawPath(smilePath, smilePaint);
    
    // Arms
    final armPaint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Left arm
    final leftArmPath = Path();
    leftArmPath.moveTo(centerX - 15, centerY);
    leftArmPath.quadraticBezierTo(
      centerX - 25, centerY + 5,
      centerX - 25, centerY + 15,
    );
    
    // Right arm
    final rightArmPath = Path();
    rightArmPath.moveTo(centerX + 15, centerY);
    rightArmPath.quadraticBezierTo(
      centerX + 25, centerY + 5,
      centerX + 25, centerY + 15,
    );
    
    canvas.drawPath(leftArmPath, armPaint);
    canvas.drawPath(rightArmPath, armPaint);
  }
  
  @override
  bool shouldRepaint(covariant WaterGlassCharacterPainter oldDelegate) {
    return oldDelegate.waveOffset != waveOffset;
  }
}