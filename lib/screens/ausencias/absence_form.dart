import 'package:flutter/material.dart';

import '../../models/profesionales/profesional.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_admin_top_bar.dart';
import '../../widgets/app_form_actions.dart';
import '../../widgets/app_form_header.dart';
import '../../widgets/app_module_hero.dart';
import '../../widgets/app_pickers.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_text_field.dart';




class AbsenceFormScreen extends StatefulWidget {
  const AbsenceFormScreen({super.key});

  @override
  State<AbsenceFormScreen> createState() => _AbsenceFormScreenState();
}

class _AbsenceFormScreenState extends State<AbsenceFormScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String? _professional;
  int? _professionalId;
  String? _absenceType;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Profesional> _professionals = <Profesional>[];
  bool _loadingProfessionals = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfessionals();
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadProfessionals() async {
    try {
      final response = await AuraApi.profesionales.list();
      if (!mounted) return;
      setState(() {
        _professionals = response.data ?? <Profesional>[];
        _loadingProfessionals = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadingProfessionals = false);
      _showError(e.message);
    }
  }

  Future<void> _pickProfessional() async {
    if (_loadingProfessionals || _professionals.isEmpty) {
      _showError('No hay profesionales disponibles.');
      return;
    }
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Profesional',
      options: _professionals
          .map((Profesional item) => item.nombreCompleto)
          .toList(),
      selected: _professional,
    );
    if (picked != null) {
      final Profesional item = _professionals.firstWhere(
        (Profesional value) => value.nombreCompleto == picked,
      );
      setState(() {
        _professional = item.nombreCompleto;
        _professionalId = item.id;
      });
    }
  }

  Future<void> _pickAbsenceType() async {
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Tipo de ausencia',
      options: const <String>[
        'Rango de fechas',
        'Día específico',
        'Permiso por horas',
      ],
      selected: _absenceType,
    );
    if (picked != null) setState(() => _absenceType = picked);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final DateTime? picked = await pickAppDate(
      context,
      initial: isStart ? _startDate : _endDate,
      firstDate: isStart ? DateTime(2020) : (_startDate ?? DateTime(2020)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        _startController.text = formatAppDate(picked);
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
          _endController.clear();
        }
      } else {
        _endDate = picked;
        _endController.text = formatAppDate(picked);
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _dateOnly(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-${day}T00:00:00';
  }

  int _motiveValue(String type) {
    const Map<String, int> values = <String, int>{
      'Rango de fechas': 0,
      'Día específico': 1,
      'Permiso por horas': 2,
    };
    return values[type] ?? 0;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_professionalId == null) {
      _showError('Selecciona un profesional.');
      return;
    }
    if (_absenceType == null) {
      _showError('Selecciona el tipo de ausencia.');
      return;
    }
    if (_startDate == null) {
      _showError('Selecciona la fecha inicial.');
      return;
    }
    if (_endDate == null) {
      _showError('Selecciona la fecha final.');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      _showError('La fecha final debe ser igual o posterior a la inicial.');
      return;
    }
    setState(() => _saving = true);
    try {
      final response = await AuraApi.eventualidades.createMassive(
        profesionalId: _professionalId!,
        motivo: _motiveValue(_absenceType!),
        observacion: _reasonController.text.trim(),
        periodos: <Map<String, String>>[
          <String, String>{
            'fechaInicio': _dateOnly(_startDate!),
            'fechaFin': _dateOnly(_endDate!),
          },
        ],
      );
      if (!mounted) return;
      if (!response.isSuccess) {
        _showError(
          response.message ?? 'No se pudo registrar la inasistencia.',
        );
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.absences);
    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w700,
      fontSize: 11,
      height: 14 / 11,
      letterSpacing: 0.33,
      color: AppColors.textPrimary,
    );
    final TextStyle trailingStyle = TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w500,
      fontSize: 10,
      height: 14 / 10,
      color: AppColors.textSecondaryMuted,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppAdminTopBar(section: 'Inasistencias'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppFormHeader(title: 'Registrar inasistencia'),
                  const SizedBox(height: 12),
                  const AppModuleHero(
                    title: 'Gestión de staff',
                    subtitle:
                        'Bloquea la agenda del profesional por días '
                        'específicos o por un rango de fechas.',
                  ),
                  const SizedBox(height: 16),
                  AppSelectField(
                    label: 'Profesional',
                    required: true,
                    labelTrailing: 'Obligatorio',
                    placeholder: _loadingProfessionals
                        ? 'Cargando profesionales...'
                        : _professional ?? 'Selecciona un profesional',
                    valueColor:
                        _professional == null ? null : AppColors.textPrimary,
                    onTap: _loadingProfessionals || _professionals.isEmpty
                        ? null
                        : _pickProfessional,
                  ),
                  const SizedBox(height: 16),
                  AppSelectField(
                    label: 'Tipo de ausencia',
                    required: true,
                    labelTrailing: 'Obligatorio',
                    placeholder: _absenceType ?? 'Selecciona el tipo',
                    valueColor:
                        _absenceType == null ? null : AppColors.textPrimary,
                    onTap: _pickAbsenceType,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Fecha inicial',
                    labelSuffix: Text(
                      '*',
                      style: labelStyle.copyWith(color: AppColors.danger),
                    ),
                    labelTrailing: Text('Obligatorio', style: trailingStyle),
                    labelStyle: labelStyle,
                    controller: _startController,
                    hintText: 'dd / mm / aaaa',
                    hintColor: AppColors.hintOnWhite,
                    fillColor: AppColors.white,
                    elevated: true,
                    borderRadius: 12,
                    minHeight: 52,
                    readOnly: true,
                    onTap: () => _pickDate(isStart: true),
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Fecha final',
                    labelSuffix: Text(
                      '*',
                      style: labelStyle.copyWith(color: AppColors.danger),
                    ),
                    labelTrailing: Text(
                      'Igual o posterior a la inicial',
                      style: trailingStyle,
                    ),
                    labelStyle: labelStyle,
                    controller: _endController,
                    hintText: 'dd / mm / aaaa',
                    hintColor: AppColors.hintOnWhite,
                    fillColor: AppColors.white,
                    elevated: true,
                    borderRadius: 12,
                    minHeight: 52,
                    readOnly: true,
                    onTap: () => _pickDate(isStart: false),
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Motivo',
                    labelStyle: labelStyle,
                    controller: _reasonController,
                    hintText:
                        'Salud, familiar, capacitación u otra causa justificada',
                    hintColor: AppColors.hintOnWhite,
                    fillColor: AppColors.white,
                    elevated: true,
                    borderRadius: 12,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Se notificará a recepción para reprogramar los turnos '
                    'afectados.',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 16 / 12,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppFormActions(
            primaryLabel: _saving ? 'Guardando...' : 'Registrar inasistencia',
            primaryIcon: Icons.event_busy_outlined,
            onCancel: () => Navigator.of(context).maybePop(),
            onPrimary: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
