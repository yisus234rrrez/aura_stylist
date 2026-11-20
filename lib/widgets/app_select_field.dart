import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';




class AppSelectField extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    this.required = false,
    this.labelTrailing,
    required this.placeholder,
    this.onTap,
    this.icon = Icons.expand_more,
    this.valueColor,
    this.fillColor = AppColors.secondaryButtonSurface,
    this.elevated = false,
    this.minHeight = 52,
    this.borderRadius = 12,
  });

  final String label;
  final bool required;
  final String? labelTrailing;
  final String placeholder;
  final VoidCallback? onTap;


  final IconData icon;


  final Color? valueColor;

  final Color fillColor;
  final bool elevated;
  final double minHeight;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w700,
      fontSize: 11,
      height: 14 / 11,
      letterSpacing: 0.33,
      color: AppColors.textPrimary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(child: Text(label, style: labelStyle)),
            if (required)
              Text(
                ' *',
                style: labelStyle.copyWith(color: AppColors.danger),
              ),
            if (labelTrailing != null) ...[
              const Spacer(),
              Text(
                labelTrailing!,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                  height: 14 / 10,
                  color: AppColors.textSecondaryMuted,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Material(
          color: fillColor,
          borderRadius: BorderRadius.circular(borderRadius),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: onTap,
            child: Container(
              constraints: BoxConstraints(minHeight: minHeight),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: elevated
                    ? const [
                        BoxShadow(
                          color: AppColors.shadowSoft,
                          blurRadius: 1,
                          offset: Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 20 / 14,
                        color: valueColor ?? AppColors.hintOnWhite,
                      ),
                    ),
                  ),
                  Icon(icon, size: 18, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
