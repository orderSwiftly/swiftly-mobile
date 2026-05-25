// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swiftly_mobile/providers/auth_provider.dart';
import 'package:swiftly_mobile/services/api_service.dart';
import 'package:swiftly_mobile/screens/reset_password_screen.dart';
import 'package:swiftly_mobile/screens/verify_email_screen.dart';
import 'package:swiftly_mobile/screens/verify_otp_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_wrapper.dart'; // Import MainWrapper instead of DashboardScreen
import 'core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final ApiService _apiService = ApiService();
  bool? _onboardingCompleted;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final completed = await _apiService.isOnboardingCompleted();
      print('Onboarding completed status: $completed'); // Debug log
      setState(() {
        _onboardingCompleted = completed;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking onboarding: $e');
      setState(() {
        _onboardingCompleted = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    print('Auth state status: ${authState.value?.status}'); // Debug log
    print('Onboarding completed: $_onboardingCompleted'); // Debug log
    print('Is loading: $_isLoading'); // Debug log

    return MaterialApp(
      title: 'Swiftly Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.text,
        fontFamily: 'Manrope',
      ),
      home: _buildHomeScreen(authState),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/verify-email': (context) =>
            const VerifyEmailScreen(email: '', phone: ''),
        '/verify-otp': (context) => const VerifyOtpScreen(email: ''),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) =>
            const MainWrapper(), // Changed to MainWrapper
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
        if (settings.name == '/reset-password') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) =>
                ResetPasswordScreen(resetToken: args?['reset_token'] ?? ''),
          );
        }
        return null;
      },
    );
  }

  Widget _buildHomeScreen(AsyncValue<AuthState> authState) {
    // Still loading onboarding status
    if (_isLoading) {
      print('Showing splash - still loading onboarding status');
      return const SplashScreen();
    }

    // Use when() to handle auth states
    return authState.when(
      loading: () {
        print('Showing splash - auth loading');
        return const SplashScreen();
      },
      error: (error, stackTrace) {
        print('Auth error: $error');
        // If onboarding not completed, show onboarding
        if (_onboardingCompleted == false) {
          print('Showing onboarding (auth error case)');
          return const OnboardingScreen();
        }
        print('Showing login (auth error case)');
        return const LoginScreen();
      },
      data: (state) {
        // CASE 1: User is authenticated - go to dashboard wrapper
        if (state.status == AuthStatus.authenticated && state.user != null) {
          print('User is authenticated, showing MainWrapper');
          return const MainWrapper(); // Changed to MainWrapper
        }

        // CASE 2: User not authenticated
        // If onboarding not completed, show onboarding
        if (_onboardingCompleted == false) {
          print('Onboarding not completed, showing onboarding');
          return const OnboardingScreen();
        }

        // CASE 3: Onboarding completed but not authenticated - show login
        print('Onboarding completed but not authenticated, showing login');
        return const LoginScreen();
      },
    );
  }
}