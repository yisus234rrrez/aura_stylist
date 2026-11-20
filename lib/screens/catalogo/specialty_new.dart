import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_form_actions.dart';
import '../../widgets/app_form_header.dart';
import '../../widgets/app_module_hero.dart';
import '../../widgets/app_text_field.dart';
import '../../services/remote/aura_api.dart';
import '../../services/remote/api_service.dart';
import '../../widgets/app_top_bar.dart';




class SpecialtyNewScreen extends StatefulWidget {
  const SpecialtyNewScreen({super.key});

  @override
  State<SpecialtyNewScreen> createState() => _SpecialtyNewScreenState();
}

class _SpecialtyNewScreenState extends State<SpecialtyNewScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
          const SnackBar(content: Text('Ingresa el nombre de la especialidad.')),
        );
      return;
    }
    try {
      final response = await AuraApi.createSpecialty(_nameController.text.trim());
      if (!mounted) return;
      if (!response.isSuccess) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message ?? 'No se pudo guardar la especialidad.'))); return; }
      Navigator.of(context).pushReplacementNamed(AppRoutes.specialties);
    } on ApiException catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message))); }
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: AppFormHeader(title: 'Nueva Especialidad'),
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
                          hintText: 'Ej. Cuidado Facial y Piel',
                          hintColor: AppColors.hintOnWhite,
                          fillColor: AppColors.white,
                          elevated: true,
                          minHeight: 52,
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
                          hintText:
                              'Describe el alcance técnico de la especialidad',
                          hintColor: AppColors.hintOnWhite,
                          fillColor: AppColors.white,
                          elevated: true,
                          maxLines: 3,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppFormActions(
            primaryLabel: 'Guardar especialidad',
            onCancel: () => Navigator.of(context).maybePop(),
            onPrimary: _save,
          ),
        ],
      ),
    );
  }
}
