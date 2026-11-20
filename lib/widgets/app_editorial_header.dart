import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';




class AppEditorialHeader extends StatelessWidget {
  const AppEditorialHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.surfaceMuted,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Icon(icon, size: 19, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: AppFonts.heading,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            height: 32 / 24,
            letterSpacing: -0.6,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 22.75 / 14,
            color: AppColors.textBody,
          ),
        ),
      ],
    );
  }
}
