import 'package:flutter/material.dart';
import 'package:swiftly_mobile/core/theme/app_typography.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_field.dart';
import '../widgets/custom_loader.dart';
import '../widgets/phone_input_field.dart';
import '../core/theme/app_colors.dart';
import '../utils/validators.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _selectedCountryCode = '+234';

  // Create instance of API service
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Helper method to reset the entire form
  void _resetForm() {
    // Clear all text controllers
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();

    // Reset form validation state (removes error messages)
    _formKey.currentState?.reset();
  }

  // Handle signup with API call
  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Combine country code with phone number
        final fullPhoneNumber =
            '$_selectedCountryCode${_phoneController.text.trim().replaceFirst(RegExp(r'^0+'), '')}';

        // Call the signup API
        await _apiService.signup(
          first_name: _firstNameController.text.trim(),
          last_name: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirm_password: _confirmPasswordController.text,
          phone: fullPhoneNumber,
        );

        if (mounted) {
          // Show success message using validator helper
          Validators.showSuccessSnackBar(
            context,
            'Account created successfully! 🎉',
          );

          // Reset form to empty state
          _resetForm();
        }
      } catch (e) {
        // Show error message using validator helper
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
          _GreenWaveHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Name & Last Name Row
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _firstNameController,
                            label: 'First Name',
                            hint: 'Enter your first name',
                            validator: Validators.validateName,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CustomTextField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            hint: 'Enter your last name',
                            validator: Validators.validateName,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 20),

                    // Phone Field with Country Code
                    PhoneInputField(
                      controller: _phoneController,
                      onCountryCodeChanged: (code) {
                        _selectedCountryCode = code;
                      },
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    PasswordField(
                      controller: _passwordController,
                      label: 'Create Password',
                      hint: 'at least 6 characters',
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    PasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      validator: (value) => Validators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const StadiumBorder(),
                          disabledBackgroundColor: AppColors.accent.withOpacity(
                            0.7,
                          ),
                        ),
                        child: _isLoading
                            ? const CustomLoader(
                                size: 24,
                                strokeWidth: 2.5,
                                color: Colors.white,
                              )
                            : const Text(
                                'Sign up ›',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account?  '),
                            TextSpan(
                              text: 'Login here',
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
                    const SizedBox(height: 8),

                    // Terms & Privacy
                    const Center(
                      child: Text(
                        'By signing up to Terms & Privacy Policy',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Green Wave Header Widget
class _GreenWaveHeader extends StatelessWidget {
  const _GreenWaveHeader();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: 160,
        color: AppColors.waveClr,
        padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
        alignment: Alignment.topLeft,
        child: const Text(
          'Sign Up',
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

// Wave Clipper for Custom Shape
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
  bool shouldReclip(_WaveClipper oldClipper) => false;
}