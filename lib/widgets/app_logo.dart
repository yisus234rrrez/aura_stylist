import 'package:flutter/material.dart';

import '../theme/app_assets.dart';






class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});


  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logoAura,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
