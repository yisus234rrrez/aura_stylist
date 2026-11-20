import 'package:flutter/material.dart';

import '../theme/app_colors.dart';




class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 12,
    this.soft = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;


  final double radius;


  final bool soft;

  @override
  Widget build(BuildContext context) {
    final List<BoxShadow> shadows = soft
        ? const [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ]
        : const [
            BoxShadow(
              color: AppColors.shadowCard,
              blurRadius: 6,
              spreadRadius: -1,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.shadowCard,
              blurRadius: 4,
              spreadRadius: -2,
              offset: Offset(0, 2),
            ),
          ];

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}
