import 'package:flutter/material.dart';

import '../../routes/app_route_args.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_form_actions.dart';
import '../../widgets/app_form_header.dart';
import '../../widgets/app_module_hero.dart';
import '../../widgets/app_success_toast.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_top_bar.dart';




class SpecialtyEditScreen extends StatefulWidget {
  const SpecialtyEditScreen({
    super.key,
    this.title,
    this.initialActive = true,
    this.showToast = false,
    this.initial = const SpecialtyRouteArgs(),
  });


  final String? title;


  final bool initialActive;


  final bool showToast;

  final SpecialtyRouteArgs initial;

  @override
  State<SpecialtyEditScreen> createState() => _SpecialtyEditScreenState();
}

class _SpecialtyEditScreenState extends State<SpecialtyEditScreen> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initial.name.isEmpty
        ? 'Peluquería y Colorimetría'
        : widget.initial.name,
  );
  late final TextEditingController _descriptionController =
      TextEditingController(
    text: widget.initial.description.isEmpty
        ? 'Diagnóstico capilar integral, balayage, decoloración botánica y '
            'rituales de sellado térmico.'
        : widget.initial.description,
  );
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _active = widget.initialActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Ingresa el nombre de la especialidad.'),
          ),
        );
      return;
    }
    if (widget.initial.id == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    try {
      final response = await AuraApi.especialidades.update(
        widget.initial.id,
        _nameController.text.trim(),
      );
      if (!mounted) return;
      if (response.isSuccess) {
        Navigator.of(context).maybePop();
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'No se pudo actualizar la especialidad.',
              ),
            ),
          );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle fieldLabelStyle = TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: 0.14,
      color: AppColors.textPrimary,
    );
    final TextStyle helperTrailingStyle = TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w700,
      fontSize: 11,
      height: 14 / 11,
      letterSpacing: 0.33,
      color: AppColors.textBody,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppTopBar(
            title: 'Especialidades',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.showToast)
                    const AppSuccessToast(
                      title: 'Especialidad guardada correctamente',
                      message: 'Los cambios se guardaron en el catálogo.',
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: AppFormHeader(
                      title: widget.title ?? 'Editar Especialidad',
                      badge: 'ESP-04',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: AppModuleHero(
                      title: 'Módulo de Servicios & Cuidados',
                      subtitle:
                          'Configura las áreas maestras para estilistas y '
                          'tratamientos capilares.',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Nombre de la especialidad',
                          labelSuffix: Text(
                            '*',
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.danger,
                            ),
                          ),
                          labelTrailing: Text(
                            'Obligatorio',
                            style: helperTrailingStyle,
                          ),
                          labelStyle: fieldLabelStyle,
                          controller: _nameController,
                          fillColor: AppColors.white,
                          elevated: true,
                          minHeight: 52,
                          textColor: AppColors.textPrimary,
                          suffixIcon: const Icon(
                            Icons.check_circle,
                            size: 17,
                            color: AppColors.accentDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Descripción',
                          labelTrailing: Text(
                            'Alcance técnico',
                            style: helperTrailingStyle,
                          ),
                          labelStyle: fieldLabelStyle,
                          controller: _descriptionController,
                          fillColor: AppColors.white,
                          elevated: true,
                          maxLines: 3,
                          textColor: AppColors.textPrimary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Esta descripción será visible para recepción al '
                          'coordinar reservas y asignaciones.',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 16 / 12,
                            color: AppColors.textBody,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StatusCard(
                          active: _active,
                          onToggle: () =>
                              setState(() => _active = !_active),
                        ),
                        const SizedBox(height: 16),
                        const _LinkedProfessionals(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppFormActions(
            primaryLabel: 'Guardar cambios',
            onCancel: () => Navigator.of(context).maybePop(),
            onPrimary: _save,
          ),
        ],
      ),
    );
  }
}


class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.active, required this.onToggle});

  final bool active;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Estado: ${active ? 'Activa' : 'Inactiva'}',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 20 / 14,
                        letterSpacing: 0.14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.overlayGreen40
                            : AppColors.secondaryButtonSurface,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        active ? 'En línea' : 'Fuera de línea',
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          height: 14 / 11,
                          letterSpacing: 0.33,
                          color: AppColors.buttonLabelDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  active
                      ? 'Disponible para asociar nuevos servicios y '
                            'profesionales.'
                      : 'No disponible para asociar nuevos servicios ni '
                            'profesionales.',
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
          const SizedBox(width: 8),
          _ActiveSwitch(active: active, onTap: onToggle),
        ],
      ),
    );
  }
}


class _ActiveSwitch extends StatelessWidget {
  const _ActiveSwitch({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        width: 48,
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.secondaryButtonSurface,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: active
              ? const Icon(
                  Icons.check,
                  size: 14,
                  color: AppColors.textPrimary,
                )
              : null,
        ),
      ),
    );
  }
}


class _LinkedProfessionals extends StatelessWidget {
  const _LinkedProfessionals();

  static const List<({String initials, Color background, Color foreground})>
      _avatars =
      <({String initials, Color background, Color foreground})>[
    (initials: 'VR', background: AppColors.secondary, foreground: AppColors.white),
    (initials: 'ML', background: AppColors.accentDark, foreground: AppColors.white),
    (initials: 'CR', background: AppColors.tabSelectedBadge, foreground: AppColors.tabSelectedBadgeText),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pillBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROFESIONALES VINCULADOS',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 14 / 11,
                  letterSpacing: 0.55,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '3 estilistas',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 16 / 12,
                  letterSpacing: 0.24,
                  color: AppColors.accentDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            width: 32 + (_avatars.length) * 24,
            child: Stack(
              children: [
                for (int i = 0; i < _avatars.length; i++)
                  Positioned(
                    left: i * 24,
                    child: _Avatar(
                      initials: _avatars[i].initials,
                      background: _avatars[i].background,
                      foreground: _avatars[i].foreground,
                    ),
                  ),
                Positioned(
                  left: _avatars.length * 24,
                  child: const _Avatar(
                    initials: '+1',
                    background: AppColors.white,
                    foreground: AppColors.textPrimary,
                    small: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.background,
    required this.foreground,
    this.small = false,
  });

  final String initials;
  final Color background;
  final Color foreground;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: AppColors.background,
            spreadRadius: 2,
            blurRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w700,
          fontSize: small ? 10 : 12,
          height: 1,
          color: foreground,
        ),
      ),
    );
  }
}


