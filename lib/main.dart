import 'package:flutter/material.dart';
import 'screens/signup_screen.dart';
import 'core/theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor:
            AppColors.text, // Using AppColors.text as background
      ),
      home: const SignupScreen(),
    );
  }
}
