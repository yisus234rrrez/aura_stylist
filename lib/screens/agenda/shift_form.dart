import 'package:flutter/material.dart';

import '../../models/horarios/horario_laboral.dart';
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




class ShiftFormScreen extends StatefulWidget {
  const ShiftFormScreen({super.key});

  @override
  State<ShiftFormScreen> createState() => _ShiftFormScreenState();
}

class _ShiftFormScreenState extends State<ShiftFormScreen> {
  bool _hasLunch = true;
  String? _professional;
  int? _professionalId;
  String? _day;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  TimeOfDay? _lunchTime;
  List<Profesional> _professionals = <Profesional>[];
  bool _loadingProfessionals = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfessionals();
  }

  Future<void> _loadProfessionals() async {
    try {
      final response = await AuraApi.profesionales.list();
      if (!mounted) return;
      setState(() {
        _professionals = response.data ?? <Profesional>[];
        _loadingProfessionals = false;
        if (_professionals.isNotEmpty) {
          _professional = _professionals.first.nombreCompleto;
          _professionalId = _professionals.first.id;
        }
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

  Future<void> _pickDay() async {
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Día de la semana',
      options: const <String>[
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo',
      ],
      selected: _day,
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _pickTime({required String field}) async {
    final TimeOfDay? picked = await pickAppTime(context);
    if (picked == null) return;
    setState(() {
      if (field == 'start') {
        _startTime = picked;
      } else if (field == 'end') {
        _endTime = picked;
      } else {
        _lunchTime = picked;
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _apiTime(TimeOfDay value) {
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  int _dayValue(String day) {
    const Map<String, int> values = <String, int>{
      'Domingo': 0,
      'Lunes': 1,
      'Martes': 2,
      'Miércoles': 3,
      'Jueves': 4,
      'Viernes': 5,
      'Sábado': 6,
    };
    return values[day] ?? 1;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_professionalId == null) {
      _showError('Selecciona un profesional.');
      return;
    }
    if (_day == null) {
      _showError('Selecciona un día de la semana.');
      return;
    }
    if (_startTime == null || _endTime == null) {
      _showError('Selecciona la hora de inicio y de fin.');
      return;
    }
    final int start = _startTime!.hour * 60 + _startTime!.minute;
    final int end = _endTime!.hour * 60 + _endTime!.minute;
    if (end <= start) {
      _showError('La hora de fin debe ser posterior a la de inicio.');
      return;
    }
    if (_hasLunch && _lunchTime == null) {
      _showError('Selecciona la hora de inicio del almuerzo.');
      return;
    }
    setState(() => _saving = true);
    try {
      final response = await AuraApi.horarios.create(
        HorarioLaboral(
          id: 0,
          profesionalId: _professionalId!,
          diaSemana: _dayValue(_day!),
          horaInicio: _apiTime(_startTime!),
          horaFin: _apiTime(_endTime!),
          tieneAlmuerzo: _hasLunch,
          horaInicioAlmuerzo:
              _hasLunch && _lunchTime != null ? _apiTime(_lunchTime!) : '00:00:00',
          horaFinAlmuerzo: _hasLunch && _lunchTime != null
              ? _apiTime(
                  TimeOfDay(
                    hour: (_lunchTime!.hour + 1) % 24,
                    minute: _lunchTime!.minute,
                  ),
                )
              : '00:00:00',
        ),
      );
      if (!mounted) return;
      if (!response.isSuccess) {
        _showError(response.message ?? 'No se pudo agregar la jornada.');
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.scheduleAdded);
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppAdminTopBar(section: 'Horarios'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppFormHeader(title: 'Agregar jornada'),
                  const SizedBox(height: 12),
                  const AppModuleHero(
                    title: 'Horario laboral',
                    subtitle:
                        'Define el día y las horas de trabajo. La pausa de '
                        'almuerzo es opcional.',
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
                    label: 'Día de la semana',
                    required: true,
                    labelTrailing: 'Obligatorio',
                    placeholder: _day ?? 'Selecciona un día',
                    valueColor: _day == null ? null : AppColors.textPrimary,
                    onTap: _pickDay,
                  ),
                  const SizedBox(height: 16),
                  AppSelectField(
                    label: 'Hora de inicio',
                    required: true,
                    labelTrailing: 'Obligatorio',
                    placeholder: _startTime == null
                        ? '08:00 AM'
                        : formatAppTime(_startTime!),
                    valueColor:
                        _startTime == null ? null : AppColors.textPrimary,
                    icon: Icons.schedule,
                    fillColor: AppColors.white,
                    elevated: true,
                    onTap: () => _pickTime(field: 'start'),
                  ),
                  const SizedBox(height: 16),
                  AppSelectField(
                    label: 'Hora de fin',
                    required: true,
                    labelTrailing: 'Posterior a la hora de inicio',
                    placeholder: _endTime == null
                        ? '06:00 PM'
                        : formatAppTime(_endTime!),
                    valueColor:
                        _endTime == null ? null : AppColors.textPrimary,
                    icon: Icons.schedule,
                    fillColor: AppColors.white,
                    elevated: true,
                    onTap: () => _pickTime(field: 'end'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Tiene almuerzo', style: labelStyle),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.overlayGreen40,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          _hasLunch ? 'Sí' : 'No',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            height: 14 / 11,
                            color: AppColors.buttonLabelDark,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _Switch(
                        active: _hasLunch,
                        onTap: () =>
                            setState(() => _hasLunch = !_hasLunch),
                      ),
                    ],
                  ),
                  if (_hasLunch) ...[
                    const SizedBox(height: 12),
                    AppSelectField(
                      label: 'Hora de inicio del almuerzo',
                      required: true,
                      labelTrailing: 'Solo si tiene almuerzo',
                      placeholder: _lunchTime == null
                          ? '01:00 PM'
                          : formatAppTime(_lunchTime!),
                      valueColor:
                          _lunchTime == null ? null : AppColors.textPrimary,
                      icon: Icons.schedule,
                      fillColor: AppColors.white,
                      elevated: true,
                      onTap: () => _pickTime(field: 'lunch'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          AppFormActions(
            primaryLabel: _saving ? 'Guardando...' : 'Agregar jornada',
            onCancel: () => Navigator.of(context).maybePop(),
            onPrimary: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({required this.active, required this.onTap});

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
              ? const Icon(Icons.check, size: 14, color: AppColors.textPrimary)
              : null,
        ),
      ),
    );
  }
}
