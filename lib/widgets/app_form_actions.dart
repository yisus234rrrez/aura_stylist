import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import 'app_primary_button.dart';




class AppFormActions extends StatelessWidget {
  const AppFormActions({
    super.key,
    required this.primaryLabel,
    this.primaryIcon = Icons.save_outlined,
    this.onCancel,
    this.onPrimary,
    this.cancelLabel = 'Cancelar',
  });

  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback? onCancel;
  final VoidCallback? onPrimary;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.95),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowCard,
            blurRadius: 25,
            spreadRadius: -5,
            offset: Offset(0, -20),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Material(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onCancel,
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      child: Text(
                        cancelLabel,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 20 / 14,
                          letterSpacing: 0.14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppPrimaryButton(
                  label: primaryLabel,
                  leadingIcon: primaryIcon,
                  labelColor: AppColors.buttonLabelDark,
                  onPressed: onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
