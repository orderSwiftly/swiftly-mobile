import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Function(String)? onCountryCodeChanged;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.validator,
    this.onCountryCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Code Picker
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CountryCodePicker(
            onChanged: (CountryCode countryCode) {
              if (onCountryCodeChanged != null) {
                onCountryCodeChanged!(countryCode.dialCode ?? '+234');
              }
            },
            initialSelection: 'NG',
            favorite: ['+234', '+1', '+44', '+233', '+27'],
            showCountryOnly: false,
            showOnlyCountryWhenClosed: false,
            alignLeft: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            textStyle: AppTypography.body.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 12),

        // Phone Number Field
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.phone,
            style: AppTypography.body.copyWith(color: AppColors.darkBg),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '9011195859',
              labelStyle: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              hintStyle: AppTypography.body.copyWith(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.text,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.secondary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
