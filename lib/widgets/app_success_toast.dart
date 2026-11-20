import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';






class AppSuccessToast extends StatefulWidget {
  const AppSuccessToast({
    super.key,
    required this.title,
    required this.message,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  final String title;
  final String message;
  final EdgeInsetsGeometry margin;

  @override
  State<AppSuccessToast> createState() => _AppSuccessToastState();
}

class _AppSuccessToastState extends State<AppSuccessToast> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Container(
      margin: widget.margin,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowCard,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.statusActive,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 15,
              color: AppColors.statusActiveText,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 18 / 13,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  widget.message,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.textBody,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => setState(() => _visible = false),
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.close, size: 13, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
