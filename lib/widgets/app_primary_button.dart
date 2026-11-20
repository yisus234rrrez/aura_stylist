import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';




class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingIconAsset,
    this.leadingIcon,
    this.labelColor = AppColors.buttonLabel,
  });

  final String label;
  final VoidCallback? onPressed;


  final String? trailingIconAsset;


  final IconData? leadingIcon;


  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    const BorderRadius radius = BorderRadius.all(Radius.circular(12));

    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: AppColors.primary,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon!, size: 16, color: labelColor),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 20 / 14,
                    letterSpacing: 0.14,
                    color: labelColor,
                  ),
                ),
              ),
              if (trailingIconAsset != null) ...[
                const SizedBox(width: 8),
                Image.asset(
                  trailingIconAsset!,
                  width: 12,
                  height: 12,
                  fit: BoxFit.contain,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
