// hive_habit_service.dart
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:gritflow/hive/hive_constants.dart';
import 'package:gritflow/models/habit_model.dart';

class HiveHabitService {
  // Get reference to the habits box
  Future<Box<HabitModel>> get _habitsBox async =>
      await Hive.openBox<HabitModel>(HiveConstants.habitBox);

  // Get reference to the user habits relationship box
  Future<Box> get _userHabitsBox async =>
      await Hive.openBox(HiveConstants.userHabitsBox);

  // Create a new habit
  Future<String> createHabit(HabitModel habit, String userEmail) async {
    final box = await _habitsBox;
    
    // Generate a unique ID if not provided
    final id = habit.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : habit.id;
    
    // Create a habit with the new ID
    final newHabit = HabitModel(
      id: id,
      title: habit.title,
      icon: habit.icon,
      duration: habit.duration,
      completed: habit.completed,
    );
    
    // Save the habit
    await box.put(id, newHabit);
    
    // Associate with user
    await _associateHabitWithUser(id, userEmail);
    
    return id;
  }

  // Associate a habit with a user
  Future<void> _associateHabitWithUser(String habitId, String userEmail) async {
    final box = await _userHabitsBox;
    
    // Get existing habits for user
    final userHabits = box.get(userEmail, defaultValue: <String>[]);
    
    // Add new habit ID if not already associated
    if (!userHabits.contains(habitId)) {
      userHabits.add(habitId);
      await box.put(userEmail, userHabits);
    }
  }

  // Get a habit by ID
  Future<HabitModel?> getHabit(String id) async {
    final box = await _habitsBox;
    return box.get(id);
  }

  // Get all habits for a user
  Future<List<HabitModel>> getHabits({String? userEmail}) async {
    final habitsBox = await _habitsBox;
    
    // If no user email, return all habits (for admin/debug)
    if (userEmail == null) {
      return habitsBox.values.toList();
    }
    
    // Get user's habit IDs
    final userHabitsBox = await _userHabitsBox;
    final userHabitIds = userHabitsBox.get(userEmail, defaultValue: <String>[]);
    
    // Fetch habit details for each ID
    List<HabitModel> habits = [];
    for (var id in userHabitIds) {
      final habit = await getHabit(id);
      if (habit != null) {
        habits.add(habit);
      }
    }
    
    return habits;
  }

  // Update a habit
  Future<void> updateHabit(HabitModel habit) async {
    final box = await _habitsBox;
    await box.put(habit.id, habit);
  }

  // Delete a habit
  Future<void> deleteHabit(String id, String userEmail) async {
    final habitsBox = await _habitsBox;
    final userHabitsBox = await _userHabitsBox;
    
    // Remove habit from user association
    final userHabits = userHabitsBox.get(userEmail, defaultValue: <String>[]);
    userHabits.remove(id);
    await userHabitsBox.put(userEmail, userHabits);
    
    // Delete the habit itself
    await habitsBox.delete(id);
  }

  // For mock/temporary implementation in your current app stage
  Future<List<HabitModel>> getMockHabits() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Return mock data
    return [
      HabitModel(
        id: '1',
        title: 'Go for a walk',
        icon: Icons.directions_walk,
        duration: 25,
        completed: false,
      ),
      HabitModel(
        id: '2',
        title: 'Read fiction',
        icon: Icons.book,
        duration: 15,
        completed: false,
      ),
      HabitModel(
        id: '3',
        title: 'To inhabit the bed',
        icon: Icons.hotel,
        duration: 60,
        completed: true,
      ),
    ];
  }
}