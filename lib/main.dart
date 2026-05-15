// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:swiftly_mobile/screens/verify_email_screen.dart';
import 'package:swiftly_mobile/screens/verify_otp_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart'; // add
import 'core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
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
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const DashboardScreen(), // add
        '/verify-email': (context) =>
            const VerifyEmailScreen(email: '', phone: ''),
        '/verify-otp': (context) => const VerifyOtpScreen(email: ''),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/verify-otp') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => VerifyOtpScreen(
              email: args?['email'] ?? '',
              phone: args?['phone'],
              fromScreen: args?['fromScreen'] ?? 'signup',
            ),
          );
        }
        if (settings.name == '/verify-email') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => VerifyEmailScreen(
              email: args?['email'] ?? '',
              phone: args?['phone'],
            ),
          );
        }
        return null;
      },
    );
  }
}