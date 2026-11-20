import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';






class AppAmbientBackground extends StatelessWidget {
  const AppAmbientBackground({
    super.key,
    required this.child,
    this.showTopAura = false,
  });

  final Widget child;



  final bool showTopAura;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: Stack(
        children: [
          const Positioned(
            left: -96,
            top: -96,
            child: _Glow(color: AppColors.glowGreen, size: 288),
          ),
          const Positioned(
            right: -96,
            bottom: -96,
            child: _Glow(color: AppColors.glowBlue, size: 320),
          ),
          if (showTopAura)
            const Positioned(
              top: -40,
              left: 0,
              right: 0,
              child: Center(
                child: _Glow(color: AppColors.auraCircle, size: 192, blur: 20),
              ),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size, this.blur = 32});

  final Color color;
  final double size;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
