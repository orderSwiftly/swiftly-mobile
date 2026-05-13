import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:swiftly_mobile/core/theme/app_typography.dart';
import '../widgets/custom_loader.dart';
import '../core/theme/app_colors.dart';
import '../utils/validators.dart';
import '../services/api_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final String? phone;
  final String? fromScreen; // 'signup' or 'forgot-password'

  const VerifyOtpScreen({
    super.key,
    required this.email,
    this.phone,
    this.fromScreen = 'signup',
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  int _secondsRemaining = 60;
  bool _canResend = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer() {
    if (_secondsRemaining > 0) {
      setState(() {
        _secondsRemaining--;
      });
      Future.delayed(const Duration(seconds: 1), _updateTimer);
    } else {
      setState(() {
        _canResend = true;
      });
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
      _canResend = false;
      _secondsRemaining = 60;
    });

    try {
      await _apiService.resendOtp(email: widget.email);

      if (mounted) {
        Validators.showSuccessSnackBar(context, 'OTP resent successfully!');
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        Validators.showErrorSnackBar(context, e.toString());
        setState(() {
          _canResend = true;
          _secondsRemaining = 0;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_pinController.text.length != 6) {
      Validators.showErrorSnackBar(
        context,
        'Please enter the 6-digit OTP code',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.verifyOtp(
        email: widget.email,
        code: _pinController.text,
      );

      if (mounted) {
        Validators.showSuccessSnackBar(
          context,
          widget.fromScreen == 'signup'
              ? 'Email verified successfully! 🎉'
              : 'OTP verified successfully! 🎉',
        );

        // Navigate based on source screen
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          if (widget.fromScreen == 'signup') {
            // From signup -> go to login
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          } else {
            // From forgot password -> go to reset password
            Navigator.pushReplacementNamed(
              context,
              '/reset-password',
              arguments: {'email': widget.email},
            );
          }
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // OTP Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security_outlined,
                      size: 60,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Verify OTP',
                    style: AppTypography.headline.copyWith(
                      color: AppColors.primary,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    'We have sent a One-Time Password (OTP) to',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: AppTypography.body.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6-digit OTP code below',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // PIN Code Field
                  PinCodeTextField(
                    controller: _pinController,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 60,
                      fieldWidth: 50,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      activeColor: AppColors.accent,
                      inactiveColor: AppColors.secondary.withOpacity(0.5),
                      selectedColor: AppColors.accent,
                    ),
                    keyboardType: TextInputType.number,
                    onCompleted: (value) {
                      _verifyOtp();
                    },
                    appContext: context,
                  ),
                  const SizedBox(height: 32),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
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
                              'Verify OTP ›',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Resend Code Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_canResend)
                        GestureDetector(
                          onTap: _isLoading ? null : _resendCode,
                          child: Text(
                            'Resend',
                            style: AppTypography.body.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Text(
                          'Resend in ${_secondsRemaining}s',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Back to Login Link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          children: [
                            const TextSpan(text: 'Back to '),
                            TextSpan(
                              text: 'Login',
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
                ],
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
          'Verify OTP',
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

// Wave Clipper
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
