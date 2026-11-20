import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_ambient_background.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';
import '../../services/remote/aura_api.dart';
import '../../services/remote/api_service.dart';





class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.showAuthError = false});

  final bool showAuthError;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final TextEditingController _userController = TextEditingController(
    text: '1102822682',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '1102822682',
  );
  late bool _showError = widget.showAuthError;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final String user = _userController.text.trim();
    final String password = _passwordController.text;
    if (user.isEmpty || password.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    setState(() {
      _isLoading = true;
      _showError = false;
    });
    try {
      final response = await AuraApi.login(user, password);
      if (!mounted) return;
      if (!response.isSuccess ||
          response.data == null ||
          response.data!.accessToken.isEmpty) {
        setState(() => _showError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ??
                  'No se pudo iniciar sesión. Verifica tus credenciales.',
            ),
          ),
        );
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _showError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppAmbientBackground(
        showTopAura: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              children: [
                const _LogoBadge(),
                const SizedBox(height: 16),
                _LoginHeader(
                  showError: _showError,
                  onCloseError: () => setState(() => _showError = false),
                ),
                const SizedBox(height: 28),
                AppCard(
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'USUARIO O ID DE ESTILISTA',
                        controller: _userController,
                        prefixIconAsset: AppAssets.icUser,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _PasswordField(
                        label: 'CONTRASEÑA',
                        controller: _passwordController,
                        onSubmitted: (_) => _onLogin(),
                      ),
                      const SizedBox(height: 16),
                      AppPrimaryButton(
                        label: _isLoading ? 'Conectando…' : 'Iniciar sesión',
                        trailingIconAsset: AppAssets.icArrowRight,
                        onPressed: _isLoading ? null : _onLogin,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
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
        ],
      ),
      child: const AppLogo(size: 56),
    );
  }
}


class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.label,
    this.controller,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      obscureText: _obscure,
      prefixIconAsset: AppAssets.icLock,
      textInputAction: TextInputAction.done,
      onSubmitted: widget.onSubmitted,
      suffixIcon: InkWell(
        onTap: () => setState(() => _obscure = !_obscure),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Image.asset(
              AppAssets.icEye,
              width: 16,
              height: 12,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}


class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
    required this.title,
    required this.message,
    this.onClose,
  });

  final String title;
  final String message;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 16 / 12,
                    letterSpacing: 0.24,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
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
            onTap: onClose,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 12, color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}


class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.showError, required this.onCloseError});

  final bool showError;
  final VoidCallback onCloseError;

  @override
  Widget build(BuildContext context) {
    final Text title = Text(
      'Bienvenido a Aura Stylist',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: AppFonts.heading,
        fontWeight: FontWeight.w700,
        fontSize: 24,
        height: 32 / 24,
        letterSpacing: -0.24,
        color: AppColors.textDark,
      ),
    );
    const Text eyebrow = Text(
      'PORTAL PROFESIONAL',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: AppFonts.body,
        fontWeight: FontWeight.w700,
        fontSize: 11,
        height: 14 / 11,
        letterSpacing: 1.1,
        color: AppColors.textPrimary,
      ),
    );
    const Text subtitle = Text(
      'Ingresa tus credenciales administrativas',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: AppFonts.body,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 20 / 14,
        color: AppColors.textBody,
      ),
    );

    if (!showError) {
      return Column(
        children: [eyebrow, const SizedBox(height: 4), title, subtitle],
      );
    }

    return Column(
      children: [
        title,
        const SizedBox(height: 12),
        _AlertBanner(
          title: 'Acceso no autorizado',
          message: 'Usuario o contraseña incorrectos. Verifica tus datos.',
          onClose: onCloseError,
        ),
        const SizedBox(height: 12),
        eyebrow,
        const SizedBox(height: 4),
        subtitle,
      ],
    );
  }
}
