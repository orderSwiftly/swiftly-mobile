// screens/store_owner/selecting_stores_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class SelectingStoresScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stores;
  final VoidCallback onStoreSelected;

  const SelectingStoresScreen({
    super.key,
    required this.stores,
    required this.onStoreSelected, // ← add this
  });

  @override
  State<SelectingStoresScreen> createState() => _SelectingStoresScreenState();
}

class _SelectingStoresScreenState extends State<SelectingStoresScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _selectedStoreId;
  bool _isSaving = false;

  Future<void> _confirmSelection() async {
    if (_selectedStoreId == null) return;

    setState(() => _isSaving = true);

    await _storage.write(key: 'active_store_id', value: _selectedStoreId);

    if (mounted) {
      widget.onStoreSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Text(
                'Select a Store',
                style: AppTypography.headline.copyWith(
                  color: AppColors.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.stores.length == 1
                    ? 'Confirm your store to continue.'
                    : 'Choose which store you want to manage.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              Expanded(
                child: ListView.separated(
                  itemCount: widget.stores.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final store = widget.stores[index];
                    final storeId = store['store_id'] as String;
                    final storeName = store['store_name'] ?? 'Unnamed Store';
                    final storeAddress = store['store_address'] ?? '';
                    final storePicture = store['store_picture'];
                    final institution =
                        (store['store_institution'] as String? ?? '')
                            .replaceAll('_', ' ')
                            .toLowerCase()
                            .split(' ')
                            .map(
                              (w) => w.isNotEmpty
                                  ? '${w[0].toUpperCase()}${w.substring(1)}'
                                  : '',
                            )
                            .join(' ');

                    final bool isSelected = _selectedStoreId == storeId;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedStoreId = storeId),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent.withValues(alpha: 0.08)
                              : AppColors.text,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.textHint.withValues(alpha: 0.4),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Store avatar
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  storePicture != null &&
                                      storePicture.toString().startsWith('http')
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        storePicture,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.store_rounded,
                                      color: AppColors.accent,
                                      size: 28,
                                    ),
                            ),
                            const SizedBox(width: 14),

                            // Store info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    storeName,
                                    style: AppTypography.title.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (storeAddress.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      storeAddress,
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  if (institution.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        institution,
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.accent,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Selection indicator
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: isSelected
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.accent,
                                      size: 24,
                                      key: const ValueKey('checked'),
                                    )
                                  : Icon(
                                      Icons.radio_button_unchecked,
                                      color: AppColors.textHint,
                                      size: 24,
                                      key: const ValueKey('unchecked'),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_selectedStoreId == null || _isSaving)
                      ? null
                      : _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Continue ›',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
