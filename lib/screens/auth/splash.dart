import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_ambient_background.dart';
import '../../widgets/app_logo.dart';





class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const double _targetProgress = 1.0;

  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _progress = Tween<double>(begin: 0, end: _targetProgress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward().whenComplete(_goToNext);
  }

  Future<void> _goToNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final String? token = AuraApi.api.token;
    Navigator.of(context).pushReplacementNamed(
      token == null || token.isEmpty ? AppRoutes.login : AppRoutes.dashboard,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppAmbientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _SproutBadge(),
                _BrandingBlock(progress: _progress),
                const _FooterNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _SproutBadge extends StatelessWidget {
  const _SproutBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Image.asset(
        AppAssets.sproutIcon,
        width: 12,
        height: 12,
        fit: BoxFit.contain,
      ),
    );
  }
}



class _BrandingBlock extends StatelessWidget {
  const _BrandingBlock({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Emblem(),
        const SizedBox(height: 26),
        Text(
          'Aura Stylist',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppFonts.heading,
            fontWeight: FontWeight.w700,
            fontSize: 30,
            height: 38 / 30,
            letterSpacing: -0.75,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const _SectionLabel(),
        const SizedBox(height: 4),
        Text(
          'Un Estilo Ideal Para Todos',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w400,
            fontSize: 12,
            height: 16 / 12,
            color: AppColors.textBodyMuted,
          ),
        ),
        const SizedBox(height: 40),
        _SyncProgressIndicator(progress: progress),
      ],
    );
  }
}



class _Emblem extends StatelessWidget {
  const _Emblem();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 176,
      height: 176,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            AppAssets.outerRadiantRing,
            width: 176,
            height: 176,
            fit: BoxFit.contain,
          ),
          Image.asset(
            AppAssets.decorativePetalRing,
            width: 144,
            height: 144,
            fit: BoxFit.contain,
          ),
          const AppLogo(size: 133),
        ],
      ),
    );
  }
}


class _SectionLabel extends StatelessWidget {
  const _SectionLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _DividerLine(),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'GESTIÓN ADMINISTRATIVA',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 16 / 12,
              letterSpacing: 3,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const _DividerLine(),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(width: 16, height: 1, color: AppColors.divider);
  }
}


class _SyncProgressIndicator extends StatelessWidget {
  const _SyncProgressIndicator({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 192,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: AnimatedBuilder(
              animation: progress,
              builder: (context, _) {
                return LinearProgressIndicator(
                  value: progress.value,
                  minHeight: 6,
                  backgroundColor: AppColors.progressTrack,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Sincronizando espacio',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      height: 14 / 11,
                      letterSpacing: 0.55,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: progress,
                  builder: (context, _) {
                    final int percent = (progress.value * 100).round();
                    return Text(
                      '$percent%',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        height: 14 / 11,
                        letterSpacing: 0.33,
                        color: AppColors.accentDark,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _FooterNotice extends StatelessWidget {
  const _FooterNotice();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Versión beta 1.0',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            height: 14 / 11,
            letterSpacing: 0.55,
            color: AppColors.textSecondaryFaint,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Diseño  •  Alta Precisión',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 16 / 12,
                color: AppColors.textBodyFaint,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
