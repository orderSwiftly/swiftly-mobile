import 'package:flutter/material.dart';
import 'package:swiftly_mobile/screens/splash_screen.dart';
import 'package:swiftly_mobile/screens/onboarding_screen.dart';
import 'package:swiftly_mobile/screens/signup_screen.dart';
import 'core/theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swiftly Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.text,
        fontFamily: 'Manrope',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
