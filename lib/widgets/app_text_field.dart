import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';




class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.labelSuffix,
    this.labelTrailing,
    this.labelStyle,
    this.controller,
    this.hintText,
    this.hintColor = AppColors.textBodyFaint,
    this.obscureText = false,
    this.prefixIconAsset,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.borderRadius = 8,
    this.minHeight = 48,
    this.maxLines = 1,
    this.textColor = AppColors.textDark,
    this.fillColor = AppColors.surfaceSoft,
    this.elevated = false,
  });


  final String label;


  final Widget? labelSuffix;


  final Widget? labelTrailing;


  final TextStyle? labelStyle;

  final TextEditingController? controller;
  final String? hintText;
  final Color hintColor;
  final bool obscureText;


  final String? prefixIconAsset;


  final Widget? prefixIcon;


  final Widget? suffixIcon;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;


  final bool readOnly;


  final VoidCallback? onTap;


  final double borderRadius;


  final double minHeight;


  final int maxLines;


  final Color textColor;


  final Color fillColor;


  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final TextStyle resolvedLabelStyle =
        labelStyle ??
        TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          height: 14 / 11,
          letterSpacing: 0.33,
          color: AppColors.textBody,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(child: Text(label, style: resolvedLabelStyle)),
                    ?labelSuffix,
                  ],
                ),
              ),
              ?labelTrailing,
            ],
          ),
          const SizedBox(height: 4),
        ],
        Container(
          constraints: BoxConstraints(minHeight: minHeight),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: elevated
                ? const [
                    BoxShadow(
                      color: AppColors.shadowSoft,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (prefixIconAsset != null)
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 14),
                  child: Image.asset(
                    prefixIconAsset!,
                    width: 15,
                    height: 15,
                    fit: BoxFit.contain,
                  ),
                )
              else if (prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 14),
                  child: prefixIcon,
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  enabled: enabled,
                  readOnly: readOnly,
                  onTap: onTap,
                  maxLines: maxLines,
                  cursorColor: AppColors.primary,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  onSubmitted: onSubmitted,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 20 / 14,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 14,
                      height: 20 / 14,
                      color: hintColor,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal:
                          (prefixIconAsset == null && prefixIcon == null)
                              ? 16
                              : 0,
                    ),
                  ),
                ),
              ),
              if (suffixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: suffixIcon,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
