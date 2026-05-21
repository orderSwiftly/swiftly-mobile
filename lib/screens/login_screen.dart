import 'package:flutter/material.dart';
import 'package:swiftly_mobile/core/theme/app_typography.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_field.dart';
import '../widgets/custom_loader.dart';
import '../core/theme/app_colors.dart';
import '../utils/validators.dart';
import '../services/api_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false;

  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _emailController.clear();
    _passwordController.clear();
    _formKey.currentState?.reset();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await _apiService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          Validators.showSuccessSnackBar(
            context,
            'Login successful! Welcome back!',
          );

          _resetForm();

          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        }
      } catch (e) {
        if (mounted) {
          Validators.showErrorSnackBar(context, e.toString());
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Wave header stays full width on all screen sizes
          const _GreenWaveHeader(),
          Expanded(
            child: SingleChildScrollView(
              // ── DESKTOP ADAPTATION START ──
              // Removed horizontal padding here; moved inside ConstrainedBox > Padding
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: ConstrainedBox(
                  // Caps form width at 520px on desktop; fills screen on mobile
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    // ── DESKTOP ADAPTATION END ──
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: AppTypography.headline.copyWith(
                              color: AppColors.primary,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Login to your account',
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          CustomTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'Enter your email address',
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 20),

                          PasswordField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            validator: Validators.validatePassword,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppColors.accent,
                                    onChanged: (v) => setState(
                                      () => _rememberMe = v ?? false,
                                    ),
                                  ),
                                  Text(
                                    'Remember Me',
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: const StadiumBorder(),
                                disabledBackgroundColor: AppColors.accent
                                    .withOpacity(0.7),
                              ),
                              child: _isLoading
                                  ? const CustomLoader(
                                      size: 24,
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Login ›',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/signup',
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "Don't have an account? ",
                                    ),
                                    TextSpan(
                                      text: 'Sign up',
                                      style: TextStyle(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: AppTypography.fontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          const Center(
                            child: Text(
                              'By continuing, you agree to our Terms & Privacy Policy',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenWaveHeader extends StatelessWidget {
  const _GreenWaveHeader();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _WaveClipper(),
      child: Container(
        height: 160,
        color: AppColors.waveClr,
        padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
        alignment: Alignment.topLeft,
        child: const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  const _WaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 40,
      size.width,
      size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
