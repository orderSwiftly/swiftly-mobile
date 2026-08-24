import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final Function(String)? onSearch;
  final Function(String)? onChanged;
  final VoidCallback? onFilterTap;
  final bool showFilterButton;
  final bool autoFocus;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search for products, vendors...',
    this.onSearch,
    this.onChanged,
    this.onFilterTap,
    this.showFilterButton = true,
    this.autoFocus = false,
    this.margin,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onSearch?.call('');
    setState(() {});
  }

  void _submitSearch() {
    if (_controller.text.isNotEmpty) {
      widget.onSearch?.call(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? AppColors.text,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBg.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autoFocus,
                onChanged: widget.onChanged,
                onSubmitted: (_) => _submitSearch(),
                style: AppTypography.body.copyWith(
                  color: widget.textColor ?? AppColors.primary,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTypography.body.copyWith(
                    color: AppColors.textHint,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: _isFocused ? AppColors.accent : AppColors.textHint,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 18,
                            color: AppColors.textHint,
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: widget.backgroundColor ?? AppColors.text,
                ),
              ),
            ),
          ),
          // Filter Button
          if (widget.showFilterButton) ...[
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onFilterTap,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.tune, color: AppColors.accent, size: 22),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
