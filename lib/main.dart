import 'package:flutter/material.dart';
import 'package:gritflow/screens/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:gritflow/models/user_model.dart';
import 'package:gritflow/models/habit_model.dart';  // Add this import
import 'package:gritflow/hive/hive_constants.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get the application documents directory
  final appDocumentDirectory = 
      await path_provider.getApplicationDocumentsDirectory();
  
  // Initialize Hive with the directory
  await Hive.initFlutter(appDocumentDirectory.path);
  
  // Register the adapter for UserModel
  Hive.registerAdapter(UserModelAdapter());
  
  // Register the new adapters for HabitModel and IconData
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(IconDataAdapter());
  
  // Open the boxes we need
  await Hive.openBox<UserModel>(HiveConstants.userBox);
  await Hive.openBox(HiveConstants.authBox);
  
  // Open the new boxes for habits
  await Hive.openBox<HabitModel>(HiveConstants.habitBox);
  await Hive.openBox(HiveConstants.userHabitsBox);
  
  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GritFlow',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00C853),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const SplashScreen(),
    );
  }
}