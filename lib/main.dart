// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swiftly_mobile/providers/auth_provider.dart';
import 'package:swiftly_mobile/services/api_service.dart';
import 'package:swiftly_mobile/screens/reset_password_screen.dart';
import 'package:swiftly_mobile/screens/verify_email_screen.dart';
import 'package:swiftly_mobile/screens/verify_otp_screen.dart';
import 'package:swiftly_mobile/screens/profile_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_wrapper.dart';
import 'core/theme/app_colors.dart';
import 'routes/app_routes.dart';

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
      setState(() {
        _onboardingCompleted = completed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _onboardingCompleted = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

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
        '/profile': (context) => const ProfileScreen(),
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
        if (settings.name == '/reset-password') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) =>
                ResetPasswordScreen(resetToken: args?['reset_token'] ?? ''),
          );
        }
        return AppRoutes.onGenerateRoute(settings);
      },
    );
  }

  Widget _buildHomeScreen(AsyncValue<AuthState> authState) {
    if (_isLoading) return const SplashScreen();

    return authState.when(
      loading: () => const SplashScreen(),
      error: (error, stackTrace) {
        if (_onboardingCompleted == false) return const OnboardingScreen();
        return const LoginScreen();
      },
      data: (state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          return const MainWrapper();
        }
        if (_onboardingCompleted == false) return const OnboardingScreen();
        return const LoginScreen();
      },
    );
  }
}
