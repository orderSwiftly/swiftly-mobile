import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:swiftly_mobile/core/theme/app_typography.dart';
import '../widgets/custom_loader.dart';
import '../core/theme/app_colors.dart';
import '../utils/validators.dart';
import '../services/api_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final String? phone;

  const VerifyEmailScreen({super.key, required this.email, this.phone});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  // 10 minutes countdown (600 seconds)
  int _secondsRemaining = 600; // 10 minutes = 600 seconds
  int _resendSecondsRemaining = 60; // Resend cooldown: 60 seconds
  bool _canResend = false;
  bool _codeExpired = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _startMainTimer();
    _startResendTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // Main timer for code expiration (10 minutes)
  void _startMainTimer() {
    Future.delayed(const Duration(seconds: 1), _updateMainTimer);
  }

  void _updateMainTimer() {
    if (_secondsRemaining > 0) {
      setState(() {
        _secondsRemaining--;
      });
      Future.delayed(const Duration(seconds: 1), _updateMainTimer);
    } else {
      setState(() {
        _codeExpired = true;
      });
    }
  }

  // Resend cooldown timer (60 seconds)
  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), _updateResendTimer);
  }

  void _updateResendTimer() {
    if (_resendSecondsRemaining > 0) {
      setState(() {
        _resendSecondsRemaining--;
      });
      Future.delayed(const Duration(seconds: 1), _updateResendTimer);
    } else {
      setState(() {
        _canResend = true;
      });
    }
  }

  // Format time as MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
      _canResend = false;
      _resendSecondsRemaining = 60;
      _codeExpired = false;
      // Reset main timer when resending
      _secondsRemaining = 600;
    });

    try {
      await _apiService.resendVerificationCode(email: widget.email);

      if (mounted) {
        Validators.showSuccessSnackBar(
          context,
          'Verification code resent successfully!',
        );
        _startMainTimer();
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        Validators.showErrorSnackBar(context, e.toString());
        setState(() {
          _canResend = true;
          _resendSecondsRemaining = 0;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_codeExpired) {
      Validators.showErrorSnackBar(
        context,
        'Verification code has expired. Please request a new one.',
      );
      return;
    }

    if (_pinController.text.length != 6) {
      Validators.showErrorSnackBar(
        context,
        'Please enter the 6-digit verification code',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.verifyEmail(
        email: widget.email,
        code: _pinController.text,
      );

      if (mounted) {
        Validators.showSuccessSnackBar(
          context,
          'Email verified successfully! 🎉',
        );

        // Navigate to login screen
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
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
      backgroundColor: AppColors.text,
      body: Column(
        children: [
          const _GreenWaveHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Email Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      size: 60,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Verify Your Email',
                    style: AppTypography.headline.copyWith(
                      color: AppColors.primary,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    'We have sent a verification code to',
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
                    'Enter the 6-digit code below',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Code Expiration Timer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _codeExpired
                          ? Colors.red.withOpacity(0.1)
                          : AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _codeExpired ? Icons.timer_off : Icons.timer,
                          size: 18,
                          color: _codeExpired ? Colors.red : AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _codeExpired
                              ? 'Code Expired'
                              : 'Code expires in: ${_formatTime(_secondsRemaining)}',
                          style: AppTypography.body.copyWith(
                            color: _codeExpired ? Colors.red : AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // PIN Code Field
                  PinCodeTextField(
                    controller: _pinController,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    enabled: !_codeExpired,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 60,
                      fieldWidth: 50,
                      activeFillColor: AppColors.text,
                      inactiveFillColor: AppColors.text,
                      selectedFillColor: AppColors.text,
                      activeColor: AppColors.accent,
                      inactiveColor: AppColors.secondary.withOpacity(0.5),
                      selectedColor: AppColors.accent,
                    ),
                    keyboardType: TextInputType.number,
                    onCompleted: (value) {
                      if (!_codeExpired) {
                        _verifyCode();
                      }
                    },
                    appContext: context,
                  ),
                  const SizedBox(height: 32),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_isLoading || _codeExpired)
                          ? null
                          : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _codeExpired
                            ? Colors.grey
                            : AppColors.accent,
                        foregroundColor: AppColors.text,
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
                              color: AppColors.prof,
                            )
                          : Text(
                              _codeExpired ? 'Code Expired' : 'Verify Email ›',
                              style: const TextStyle(
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
                      if (_canResend && !_codeExpired)
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
                      else if (!_codeExpired)
                        Text(
                          'Resend in ${_resendSecondsRemaining}s',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      if (_codeExpired)
                        GestureDetector(
                          onTap: _isLoading ? null : _resendCode,
                          child: Text(
                            'Request New Code',
                            style: AppTypography.body.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
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
      clipper: const _WaveClipper(),
      child: Container(
        height: 160,
        color: AppColors.waveClr,
        padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
        alignment: Alignment.topLeft,
        child: const Text(
          'Verify Email',
          style: TextStyle(
            color: AppColors.text,
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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}