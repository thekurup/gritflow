# GritFlow 🌱
*Build Better Habits with Your AI-Powered Companion*

GritFlow is a beautifully crafted Flutter habit tracking application that transforms daily routine building into an engaging, gamified experience. Meet Moe and your other AI companions who provide emotional support, motivation, and celebrate your progress on your journey to better habits.

---

## 🎯 Overview

GritFlow makes habit formation enjoyable through interactive AI characters, dynamic motivational quotes, and sophisticated animation systems. Whether you're building a morning routine, establishing fitness habits, or cultivating mindfulness practices, GritFlow provides the visual feedback and emotional encouragement needed to stay consistent.

### Why GritFlow?
- **Emotional Intelligence**: AI companions that respond to your consistency with appropriate emotions
- **Visual Motivation**: Beautiful animations and progress tracking keep you engaged
- **Personalized Experience**: Custom user profiles with habit personalization
- **Local-First**: All your data stays on your device with fast, reliable Hive storage

---

## ✨ Features

### 🤖 AI Character System
- **Moe (Pentagon)**: Your primary companion who shows disappointment when habits are skipped
- **Star Character**: Celebration animations for achievements  
- **Water Glass**: Gentle reminders for hydration habits
- **Emotional Feedback**: Characters respond dynamically to your habit consistency

### 📊 Smart Habit Management
- **Visual Habit Cards**: Clean, intuitive interface for daily habit tracking
- **Progress Indicators**: Duration-based tracking with completion states
- **Skip Recovery**: Undo functionality with motivational messaging
- **Weekly Calendar**: Visual representation of your habit consistency

### 💬 Motivational Engine
- **Daily Quotes**: Curated inspirational messages delivered through speech bubbles
- **Dynamic Messaging**: Context-aware encouragement based on your progress
- **Personalized Motivation**: Messages that adapt to your username and habits

### 👤 User Experience
- **Secure Authentication**: Username or email-based login with session persistence
- **Profile Management**: Complete user data editing and management
- **Remember Me**: Convenient auto-login for returning users
- **Onboarding Flow**: Smooth splash screen with login state detection

---

## 🛠 Tech Stack

### Framework & Architecture
- **Flutter 3.0+** - Cross-platform mobile development
- **Dart SDK** - Modern programming language optimized for UI
- **BLoC Pattern** - Reactive state management with clear separation of concerns

### State Management
- **flutter_bloc** - Event-driven state management
- **equatable** - Value-based object comparison for efficient rebuilds
- **formz** - Form validation and state management

### Data Persistence
- **Hive** - Lightning-fast NoSQL database for local storage
- **Custom Adapters** - Type-safe serialization for UserModel and HabitModel
- **SharedPreferences** - Simple key-value storage for user preferences

### UI & Animation
- **Google Fonts** - Typography with Poppins and Pacifico fonts
- **flutter_animate** - Advanced animation capabilities
- **Custom Painters** - Hand-crafted character drawings and effects
- **Material Design** - Modern UI components with dark theme

### Networking & Services
- **http & dio** - Network requests for future API integration
- **bloc_test** - BLoC testing utilities
- **mockito** - Mock object generation for testing

---

## 📁 Project Structure

```
lib/
├── blocs/                    # State Management
│   ├── logins/              # Authentication BLoCs
│   │   ├── login_bloc.dart
│   │   ├── login_event.dart
│   │   └── login_state.dart
│   ├── quotes/              # Quote System
│   │   ├── quote_cubit.dart
│   │   ├── quote_service.dart
│   │   └── quote_state.dart
│   └── signup/              # Registration BLoCs
│       ├── signup_bloc.dart
│       ├── signup_event.dart
│       └── signup_state.dart
├── hive/                    # Database Layer
│   ├── hive_constants.dart  # Database configuration
│   ├── hive_crud.dart       # User CRUD operations
│   └── hive_habit_service.dart # Habit management
├── models/                  # Data Models
│   ├── habit_model.dart     # Habit entity with custom adapters
│   ├── habit_model.g.dart   # Generated Hive adapter
│   ├── user_model.dart      # User entity
│   └── user_model.g.dart    # Generated Hive adapter
├── screens/                 # UI Screens
│   ├── home_screen.dart     # Main dashboard
│   ├── login_page.dart      # Authentication
│   ├── profile_edit_screen.dart # Profile editing
│   ├── profile_page.dart    # User profile display
│   ├── signup_page.dart     # User registration
│   └── splash_screen.dart   # App initialization
├── services/                # Business Services
│   └── auth_service.dart    # Authentication wrapper
├── utils/                   # Helper Functions
│   ├── signup_validator.dart # Form validation
│   └── validators.dart      # Core validators
├── widgets/                 # Reusable Components
│   └── disappointed_buddy_animation.dart
└── main.dart               # App entry point
```

---

## 🚀 Installation Guide

### Prerequisites
- **Flutter SDK 3.0+** - [Installation Guide](https://flutter.dev/docs/get-started/install)
- **Dart SDK** - Included with Flutter
- **Android Studio / VS Code** - Recommended IDEs
- **Android/iOS Device or Emulator**

### Step-by-Step Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/gritflow.git
   cd gritflow
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive Adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Verify Installation**
   ```bash
   flutter doctor
   ```

5. **Run the Application**
   ```bash
   # For debugging
   flutter run

   # For release build
   flutter run --release
   ```

### Troubleshooting Installation

**Common Issues:**
- **Build Runner Fails**: Run `flutter clean` then `flutter pub get` again
- **Hive Errors**: Ensure all adapters are properly registered in `main.dart`
- **Font Issues**: Verify Google Fonts package is properly installed

---

## 💡 Usage Instructions

### Getting Started

1. **Launch GritFlow** - Open the app to see the animated splash screen
2. **Create Account** - Sign up with username, email, phone, and password
3. **Login** - Use either username or email with the "Remember Me" option
4. **Add Habits** - Create your first habit with custom icons and durations

### Daily Workflow

1. **Morning Review** - Check today's habits on the dashboard
2. **Track Progress** - Mark habits as complete or skip with feedback
3. **Character Interaction** - Watch Moe's reactions to your consistency  
4. **Weekly Planning** - Use the calendar strip to see patterns

### Advanced Features

- **Profile Editing**: Update username and phone number in Profile section
- **Undo Skips**: Tap the undo button on recently skipped habits
- **Quote Refresh**: Pull down to refresh motivational quotes
- **Habit Management**: Long-press habits for additional options

---

## 📱 Screenshots & Demo

*Add screenshots here showing:*
- Splash screen with character animations
- Home dashboard with habit cards
- Login/signup forms with glowing effects
- Character interactions and speech bubbles
- Profile management screens

---

## 🔮 Future Scope

### Planned Features
- **Cloud Sync** - Cross-device habit synchronization
- **Advanced Analytics** - Detailed progress charts and insights
- **Social Features** - Share achievements with friends
- **Habit Templates** - Pre-built habit categories and suggestions
- **Smart Reminders** - AI-powered notification timing
- **Gamification** - Achievement badges and streak rewards

### Technical Enhancements
- **API Integration** - Backend service for data synchronization
- **Push Notifications** - Local and remote notification system
- **Offline Mode** - Enhanced offline capabilities
- **Performance Optimization** - Improved memory management
- **Accessibility** - Screen reader and disability support
- **Internationalization** - Multi-language support

### UI/UX Improvements  
- **Theme Customization** - Multiple color schemes
- **Character Customization** - Personalized AI companions
- **Animation Settings** - User-controlled animation preferences
- **Widget Support** - Home screen widgets for quick tracking

---

## 🛠 Development & Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Follow Flutter development best practices
4. Test on both Android and iOS
5. Submit a pull request

### Code Style Guidelines
- Follow Dart/Flutter style guide
- Use meaningful variable names
- Comment complex logic
- Maintain BLoC pattern consistency
- Write tests for new features

### Testing
```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run integration tests
flutter drive --target=test_driver/app.dart
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Credits

- **UI Inspiration** - Modern habit tracking applications
- **Character Design** - Custom geometric character concepts  
- **Animation Techniques** - Flutter animation community
- **Color Palette** - Material Design color system

---

## 📞 Support

**Need Help?**
- 📧 Email: arjunkurup24@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/gritflow/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/gritflow/discussions)



---

## 🌟 Conclusion

GritFlow represents the future of habit tracking - where technology meets psychology to create meaningful behavior change. By combining beautiful design, intelligent feedback, and emotional connection, GritFlow makes building better habits not just easier, but genuinely enjoyable.

Start your journey to better habits today. Download GritFlow and meet Moe - your new companion in personal growth.

*Happy Habit Building! 🌱*
