import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'models/task.dart';
import 'services/database_helper.dart';
import 'screens/profile_screen.dart'
    show globalProfileName, globalProfileUsername, globalProfileImagePath;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadAllData();
  runApp(const StudyMateApp());
}

/// Load semua data dari SQLite & SharedPreferences ke global notifiers
Future<void> _loadAllData() async {
  final db = DatabaseHelper.instance;

  // Load tasks
  final tasks = await db.getAllTasks();
  globalTasks.value = tasks;

  // Load schedules
  final schedules = await db.getAllJadwal();
  globalSchedules.value = schedules;

  // Load profile
  final profile = await db.loadProfile();
  globalProfileName.value = profile['name'] ?? 'Mahasiswa';
  globalProfileUsername.value = profile['username'] ?? 'mahasiswa@email.com';
  globalProfileImagePath.value = profile['imagePath'];
}

class StudyMateApp extends StatelessWidget {
  const StudyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2563EB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const OnboardingScreen(),
    );
  }
}
