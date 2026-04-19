import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/job_provider.dart';
import 'screens/home_screen.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => JobProvider(),
    child: const JobTrackerApp(),
  ),
);

class JobTrackerApp extends StatelessWidget {
  const JobTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0C0E14),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF12151E),
          primary: Color(0xFF7C6AF7),
          secondary: Color(0xFF4A9EFF),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Syne'),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF12151E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(11)),
            side: BorderSide(color: Color(0xFF1E2336)),
          ),
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}