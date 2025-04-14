import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gritflow/blocs/logins/login_bloc.dart';
import 'package:gritflow/blocs/logins/login_event.dart';
import 'package:gritflow/hive/hive_crud.dart';
import 'package:gritflow/models/user_model.dart';
import 'package:gritflow/screens/login_page.dart';
import 'package:gritflow/screens/profile_edit_screen.dart';
import 'dart:math' as math;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  final HiveUserService _userService = HiveUserService();
  UserModel? _currentUser;
  bool _isLoading = true;
  
  late AnimationController _characterController;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Animation controllers
    _characterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }
  
  @override
  void dispose() {
    _characterController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error message
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

  void _logout(BuildContext context) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              
              // Handle logout through the Hive service directly
              _userService.logout().then((_) {
                // Navigate to login screen using correct context
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: ${error.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: const Color(0xFF00C853),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GritFlow',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00C853),
              ),
            )
          : _currentUser == null
              ? _buildNoUserView()
              : _buildUserProfileView(),
    );
  }

  Widget _buildNoUserView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No user logged in',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: Text(
              'Go to Login',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner with character
          _buildWelcomeBanner(),
          
          const SizedBox(height: 24),
          
          // User information card
          _buildUserInfoCard(),
          
          const SizedBox(height: 24),
          
          // Activity section
          Text(
            'Your Activities',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Placeholder activities
          _buildActivityCard(
            icon: Icons.check_circle,
            title: 'Profile Created',
            date: 'Today',
            color: Colors.green,
          ),
          
          _buildActivityCard(
            icon: Icons.login,
            title: 'Successfully Logged In',
            date: 'Today',
            color: Colors.blue,
          ),
          
          _buildActivityCard(
            icon: Icons.person,
            title: 'Account Verified',
            date: 'Today',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF009624)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Character animation
          AnimatedBuilder(
            animation: _characterController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + 0.05 * math.sin(_characterController.value * 2 * math.pi),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(40, 40),
                      painter: MoeCharacterPainter(),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 16),
          
          // Welcome text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  _currentUser?.username ?? 'User',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Profile',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // Edit profile button
              TextButton.icon(
                onPressed: () async {
                  if (_currentUser != null) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileEditScreen(user: _currentUser!),
                      ),
                    );
                    
                    // Refresh user data if profile was updated
                    if (result != null && result is UserModel) {
                      setState(() {
                        _currentUser = result;
                      });
                    }
                  }
                },
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xFF00C853),
                  size: 16,
                ),
                label: Text(
                  'Edit',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF00C853),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: const Color(0xFF00C853).withOpacity(0.1),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Username
          _buildProfileInfoRow(
            icon: Icons.person,
            title: 'Username',
            value: _currentUser?.username ?? 'N/A',
          ),
          
          const Divider(color: Colors.grey),
          
          // Email
          _buildProfileInfoRow(
            icon: Icons.email,
            title: 'Email',
            value: _currentUser?.email ?? 'N/A',
          ),
          
          const Divider(color: Colors.grey),
          
          // Phone
          _buildProfileInfoRow(
            icon: Icons.phone,
            title: 'Phone',
            value: _currentUser?.phone ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF00C853),
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String date,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for Moe character face
class MoeCharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw eyes (closed happy eyes)
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    // Left eye
    final leftEyePath = Path();
    leftEyePath.moveTo(centerX - 10, centerY - 3);
    leftEyePath.quadraticBezierTo(centerX - 8, centerY - 8, centerX - 5, centerY - 3);
    canvas.drawPath(leftEyePath, eyePaint);
    
    // Right eye
    final rightEyePath = Path();
    rightEyePath.moveTo(centerX + 5, centerY - 3);
    rightEyePath.quadraticBezierTo(centerX + 8, centerY - 8, centerX + 10, centerY - 3);
    canvas.drawPath(rightEyePath, eyePaint);
    
    // Draw smile
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final smilePath = Path();
    smilePath.moveTo(centerX - 8, centerY + 5);
    smilePath.quadraticBezierTo(centerX, centerY + 12, centerX + 8, centerY + 5);
    smilePath.quadraticBezierTo(centerX, centerY + 8, centerX - 8, centerY + 5);
    smilePath.close();
    
    canvas.drawPath(smilePath, smilePaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}