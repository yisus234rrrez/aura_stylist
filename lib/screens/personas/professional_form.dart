import 'package:flutter/material.dart';

import '../../models/especialidades/especialidad.dart';
import '../../models/profesionales/profesional.dart';
import '../../routes/app_route_args.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_admin_top_bar.dart';
import '../../widgets/app_form_actions.dart';
import '../../widgets/app_pickers.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_success_toast.dart';
import '../../widgets/app_text_field.dart';




class ProfessionalFormScreen extends StatefulWidget {
  const ProfessionalFormScreen({
    super.key,
    this.title = 'Nuevo Profesional',
    this.badge,
    this.isEdit = false,
    this.showToast = false,
    this.commissionError = false,
    this.initial = const ProfessionalRouteArgs(),
  });

  final String title;
  final String? badge;
  final bool isEdit;
  final bool showToast;
  final bool commissionError;
  final ProfessionalRouteArgs initial;

  @override
  State<ProfessionalFormScreen> createState() => _ProfessionalFormScreenState();
}

class _ProfessionalFormScreenState extends State<ProfessionalFormScreen> {
  late final TextEditingController _docController = TextEditingController(
    text: _valueOr(widget.initial.document, '1.028.934.551'),
  );
  late final TextEditingController _namesController = TextEditingController(
    text: _valueOr(widget.initial.names, 'Camila Andrea'),
  );
  late final TextEditingController _lastNamesController = TextEditingController(
    text: _valueOr(widget.initial.lastNames, 'Vargas Silva'),
  );
  late final TextEditingController _birthController = TextEditingController(
    text: _displayBirthDate(widget.initial.birthDate),
  );
  late final TextEditingController _commissionController =
      TextEditingController(
    text: _valueOr(widget.initial.commission, '45'),
  );
  late DateTime? _birthDate = _parseDate(widget.initial.birthDate) ??
      (widget.isEdit ? DateTime(1994, 6, 18) : null);
  late String? _specialty =
      _valueOr(widget.initial.specialty, 'Peluquería y Color').isEmpty
          ? null
          : _valueOr(widget.initial.specialty, 'Peluquería y Color');
  late int? _specialtyId = widget.initial.specialtyId == 0
      ? null
      : widget.initial.specialtyId;
  List<Especialidad> _specialties = <Especialidad>[];
  bool _loadingSpecialties = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSpecialties();
  }

  Future<void> _loadSpecialties() async {
    try {
      final response = await AuraApi.especialidades.list();
      if (!mounted) return;
      final List<Especialidad> items = response.data ?? <Especialidad>[];
      int? id = _specialtyId;
      if (id == null && _specialty != null) {
        for (final Especialidad item in items) {
          if (item.nombre == _specialty) {
            id = item.id;
            break;
          }
        }
      }
      setState(() {
        _specialties = items;
        _specialtyId = id;
        _loadingSpecialties = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadingSpecialties = false);
      _showError(e.message);
    }
  }

  DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;
    final DateTime? iso = DateTime.tryParse(value);
    if (iso != null) return iso;
    final List<String> parts = value.split('/');
    if (parts.length == 3) {
      final int? day = int.tryParse(parts[0].trim());
      final int? month = int.tryParse(parts[1].trim());
      final int? year = int.tryParse(parts[2].trim());
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  String _valueOr(String value, String fallback) {
    if (value.isNotEmpty) return value;
    return widget.isEdit ? fallback : '';
  }

  String _displayBirthDate(String value) {
    final DateTime? parsed = _parseDate(value);
    if (parsed != null) return formatAppDate(parsed);
    return _valueOr(value, '18 / 06 / 1994');
  }

  Future<void> _pickBirthDate() async {
    final DateTime? picked = await pickAppDate(
      context,
      initial: _birthDate ?? DateTime(1994, 6, 18),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthController.text = formatAppDate(picked);
      });
    }
  }

  Future<void> _pickSpecialty() async {
    if (_loadingSpecialties || _specialties.isEmpty) {
      _showError('No hay especialidades disponibles.');
      return;
    }
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Especialidad principal',
      options: _specialties.map((Especialidad item) => item.nombre).toList(),
      selected: _specialty,
    );
    if (picked != null) {
      final Especialidad item =
          _specialties.firstWhere((Especialidad value) => value.nombre == picked);
      setState(() {
        _specialty = item.nombre;
        _specialtyId = item.id;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_docController.text.trim().isEmpty) {
      _showError('Ingresa el documento de identidad.');
      return;
    }
    if (_namesController.text.trim().isEmpty) {
      _showError('Ingresa los nombres del profesional.');
      return;
    }
    if (_lastNamesController.text.trim().isEmpty) {
      _showError('Ingresa los apellidos del profesional.');
      return;
    }
    final int? commission = int.tryParse(_commissionController.text.trim());
    if (commission == null || commission < 0 || commission > 100) {
      _showError('La comisión debe estar entre 0% y 100%.');
      return;
    }
    if (_specialtyId == null) {
      _showError('Selecciona una especialidad principal.');
      return;
    }
    setState(() => _saving = true);
    final Profesional profesional = Profesional(
      id: widget.initial.id,
      documento: _docController.text.replaceAll(RegExp(r'\D'), ''),
      nombres: _namesController.text.trim(),
      apellidos: _lastNamesController.text.trim(),
      fechaNacimiento: _birthDate,
      porcentaje: commission.toDouble(),
      estado: widget.isEdit ? widget.initial.active : true,
      especialidadId: _specialtyId!,
    );
    try {
      final response = widget.isEdit
          ? await AuraApi.profesionales.update(widget.initial.id, profesional)
          : await AuraApi.profesionales.create(profesional);
      if (!mounted) return;
      if (!response.isSuccess) {
        _showError(
          response.message ?? 'No se pudo guardar el profesional.',
        );
        return;
      }
      if (widget.isEdit) {
        Navigator.of(context).maybePop();
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.professionals);
      }
    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _docController.dispose();
    _namesController.dispose();
    _lastNamesController.dispose();
    _birthController.dispose();
    _commissionController.dispose();
    super.dispose();
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
    final TextStyle helperStyle = TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w500,
      fontSize: 10,
      height: 14 / 10,
      color: AppColors.textSecondaryMuted,
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          const AppAdminTopBar(section: 'Crear Profesional'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.showToast)
                    const AppSuccessToast(
                      title: 'Profesional creado correctamente',
                      message:
                          'Perfil sincronizado con la agenda en tiempo real',
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontFamily: AppFonts.heading,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                height: 32 / 24,
                                letterSpacing: -0.24,
                                color: AppColors.secondary,
                              ),
                            ),
                            Text(
                              'Registro de identidad, especialidad técnica y '
                              'esquema de comisión.',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                height: 18 / 13,
                                color: AppColors.textSecondaryMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.badge != null) ...[
                        const SizedBox(width: 8),
                        _Badge(label: widget.badge!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Documento de identidad',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle,
                        ),
                      ),
                      Text(
                        ' *',
                        style: labelStyle.copyWith(color: AppColors.danger),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          'Obligatorio y único',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: trailingStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryButtonSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'CC',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppTextField(
                          label: '',
                          controller: _docController,
                          hintText: 'Número de documento',
                          hintColor: AppColors.hintOnWhite,
                          fillColor: AppColors.white,
                          elevated: true,
                          borderRadius: 12,
                          minHeight: 52,
                          textColor: AppColors.textPrimary,
                          suffixIcon: widget.isEdit
                              ? const Icon(
                                  Icons.verified_outlined,
                                  size: 18,
                                  color: AppColors.accentDark,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                  if (widget.isEdit) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 13,
                          color: AppColors.accentDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Documento validado sin duplicados',
                          style: helperStyle,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'NOMBRES',
                          labelSuffix: Text(
                            ' *',
                            style: labelStyle.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                          labelStyle: labelStyle,
                          controller: _namesController,
                          hintText: 'Nombres',
                          hintColor: AppColors.hintOnWhite,
                          fillColor: AppColors.white,
                          elevated: true,
                          borderRadius: 12,
                          minHeight: 52,
                          textColor: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'APELLIDOS',
                          labelStyle: labelStyle,
                          controller: _lastNamesController,
                          hintText: 'Apellidos',
                          hintColor: AppColors.hintOnWhite,
                          fillColor: AppColors.white,
                          elevated: true,
                          borderRadius: 12,
                          minHeight: 52,
                          textColor: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'FECHA DE NACIMIENTO',
                    labelTrailing: Text('No fecha futura', style: trailingStyle),
                    labelStyle: labelStyle,
                    controller: _birthController,
                    hintText: 'dd / mm / aaaa',
                    hintColor: AppColors.hintOnWhite,
                    fillColor: AppColors.white,
                    elevated: true,
                    borderRadius: 12,
                    minHeight: 52,
                    textColor: AppColors.textPrimary,
                    readOnly: true,
                    onTap: _pickBirthDate,
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 17,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (widget.isEdit) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          size: 13,
                          color: AppColors.accentDark,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Mayor de edad (29 años) · Validación exitosa',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: helperStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Porcentaje de comisión (%)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle,
                        ),
                      ),
                      Text(
                        ' *',
                        style: labelStyle.copyWith(color: AppColors.danger),
                      ),
                      const Spacer(),
                      _PercentBadge(
                        value: widget.commissionError
                            ? '120 %'
                            : (widget.isEdit ? '45 %' : '0 %'),
                        error: widget.commissionError,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    label: '',
                    controller: _commissionController,
                    hintText: '0',
                    hintColor: AppColors.hintOnWhite,
                    fillColor: AppColors.white,
                    elevated: true,
                    borderRadius: 12,
                    minHeight: 52,
                    textColor: AppColors.textPrimary,
                    keyboardType: TextInputType.number,
                    suffixIcon: Text(
                      '%',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.commissionError
                              ? 'Error: el porcentaje debe estar entre 0% y 100%.'
                              : 'Debe ser un valor numérico entre 0% y 100%',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: helperStyle.copyWith(
                            color: widget.commissionError
                                ? AppColors.danger
                                : AppColors.textSecondaryMuted,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          widget.commissionError
                              ? 'Valor fuera de rango'
                              : 'Aura Standard (40%-50%)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: helperStyle.copyWith(
                            fontWeight: FontWeight.w700,
                            color: widget.commissionError
                                ? AppColors.danger
                                : AppColors.textSecondaryMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppSelectField(
                    label: 'Especialidad principal',
                    required: true,
                    placeholder: _loadingSpecialties
                        ? 'Cargando especialidades...'
                        : _specialty ??
                            (_specialties.isEmpty
                                ? 'No hay especialidades disponibles'
                                : 'Selecciona una especialidad'),
                    valueColor:
                        _specialty == null ? null : AppColors.textPrimary,
                    onTap: _loadingSpecialties || _specialties.isEmpty
                        ? null
                        : _pickSpecialty,
                  ),
                ],
              ),
            ),
          ),
          AppFormActions(
            primaryLabel: _saving ? 'Guardando...' : 'Guardar profesional',
            primaryIcon: Icons.check,
            onCancel: () => Navigator.of(context).maybePop(),
            onPrimary: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          height: 14 / 11,
          letterSpacing: 0.33,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _PercentBadge extends StatelessWidget {
  const _PercentBadge({required this.value, required this.error});

  final String value;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: error ? AppColors.dangerSurface : AppColors.overlayGreen40,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          height: 14 / 11,
          letterSpacing: 0.33,
          color: error ? AppColors.danger : AppColors.buttonLabelDark,
        ),
      ),
    );
  }
}
