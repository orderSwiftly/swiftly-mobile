import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    String cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.startsWith('+')) {
      if (cleaned.length < 13 || cleaned.length > 15) {
        return 'Enter a valid phone number';
      }
    } else {
      if (cleaned.length < 10 || cleaned.length > 11) {
        return 'Enter a valid phone number';
      }
    }

    String numbersOnly = cleaned.replaceAll('+', '');
    if (!RegExp(r'^\d+$').hasMatch(numbersOnly)) {
      return 'Phone number should contain only numbers';
    }

    return null;
  }

  // ========== API ERROR MESSAGES ==========

  // Get user-friendly error message from API response
  static String getErrorMessage(String error) {
    String message = error.replaceAll('Exception:', '').trim().toLowerCase();

    if (message.contains('email has been used') ||
        message.contains('email already') ||
        message.contains('email already exists')) {
      return 'This email is already registered. Please use a different email or login.';
    }

    if (message.contains('phone has been used') ||
        message.contains('phone already') ||
        message.contains('phone number already')) {
      return 'This phone number is already registered.';
    }

    if (message.contains('validation')) {
      if (message.contains('email')) {
        return 'Please enter a valid email address.';
      }
      if (message.contains('phone')) {
        return 'Please enter a valid phone number.';
      }
      if (message.contains('password')) {
        return 'Password must meet the requirements.';
      }
      return 'Please check your input and try again.';
    }

    if (message.contains('email') && message.contains('exist')) {
      return 'This email is already registered. Please use a different email or login.';
    }
    if (message.contains('email') && message.contains('taken')) {
      return 'Email address is already in use.';
    }
    if (message.contains('email') && message.contains('already')) {
      return 'Email already exists. Try logging in instead.';
    }

    if (message.contains('phone') && message.contains('exist')) {
      return 'This phone number is already registered.';
    }
    if (message.contains('phone') && message.contains('taken')) {
      return 'Phone number is already in use.';
    }
    if (message.contains('phone') && message.contains('already')) {
      return 'Phone number already exists.';
    }

    if (message.contains('password') && message.contains('match')) {
      return 'Passwords do not match. Please check and try again.';
    }
    if (message.contains('weak')) {
      return 'Password is too weak. Please use a stronger password.';
    }

    if (message.contains('network') || message.contains('connection')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (message.contains('timeout')) {
      return 'Request timeout. Please try again.';
    }
    if (message.contains('500')) {
      return 'Server error. Please try again later.';
    }
    if (message.contains('404')) {
      return 'Service unavailable. Please try again later.';
    }

    return message.isEmpty
        ? 'Something went wrong. Please try again.'
        : error.replaceAll('Exception:', '').trim();
  }

  // Show error snackbar with specific message - FIXED VERSION
  static void showErrorSnackBar(BuildContext context, String error) {
    final errorMessage = getErrorMessage(error);

    // Hide any existing snackbar first
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Show new snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    // Hide any existing snackbar first
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.prof,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}