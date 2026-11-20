import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';




class AppSupportFooter extends StatelessWidget {
  const AppSupportFooter({super.key, this.onBackToLogin});

  final VoidCallback? onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onBackToLogin,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              'Volver al inicio de sesión',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 20 / 14,
                color: AppColors.textPrimary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '¿Necesitas asistencia técnica? Contacta a recepción central.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w400,
            fontSize: 12,
            height: 16 / 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
