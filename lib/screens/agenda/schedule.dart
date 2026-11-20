import 'package:flutter/material.dart';

import '../../models/horarios/horario_laboral.dart';
import '../../models/profesionales/profesional.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_admin_top_bar.dart';
import '../../widgets/app_pickers.dart';
import '../../widgets/app_success_toast.dart';


class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, this.showToast = false});

  final bool showToast;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Profesional> _professionals = <Profesional>[];
  List<HorarioLaboral> _horarios = <HorarioLaboral>[];
  Profesional? _selected;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final responses = await Future.wait<dynamic>(<Future<dynamic>>[
        AuraApi.profesionales.list(),
        AuraApi.horarios.list(),
      ]);
      if (!mounted) return;
      final professionalResponse = responses[0];
      final scheduleResponse = responses[1];
      final List<Profesional> professionals =
          professionalResponse.data as List<Profesional>? ?? <Profesional>[];
      setState(() {
        _professionals = professionals;
        _horarios = scheduleResponse.data as List<HorarioLaboral>? ??
            <HorarioLaboral>[];
        final int currentId = _selected?.id ?? 0;
        _selected = professionals.isEmpty
            ? null
            : professionals.firstWhere(
                (Profesional item) => item.id == currentId,
                orElse: () => professionals.first,
              );
        _error = scheduleResponse.isSuccess
            ? null
            : (scheduleResponse.message ?? 'No se pudieron cargar los horarios.');
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  List<HorarioLaboral> get _delProfesional {
    final int id = _selected?.id ?? 0;
    final List<HorarioLaboral> items = _horarios
        .where((HorarioLaboral item) => item.profesionalId == id)
        .toList();
    items.sort((HorarioLaboral a, HorarioLaboral b) {
      final int da = a.diaSemana == 0 ? 7 : a.diaSemana;
      final int db = b.diaSemana == 0 ? 7 : b.diaSemana;
      return da.compareTo(db);
    });
    return items;
  }

  static int _minutes(String value) {
    final List<String> parts = value.split(':');
    if (parts.length < 2) return 0;
    final int hour = int.tryParse(parts[0]) ?? 0;
    final int minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  String get _horasTexto {
    int total = 0;
    for (final HorarioLaboral item in _delProfesional) {
      int minutes = _minutes(item.horaFin) - _minutes(item.horaInicio);
      if (item.tieneAlmuerzo) {
        minutes -= _minutes(item.horaFinAlmuerzo) -
            _minutes(item.horaInicioAlmuerzo);
      }
      if (minutes > 0) total += minutes;
    }
    final int hours = total ~/ 60;
    final int rest = total % 60;
    return rest == 0 ? '$hours' : '${hours}h ${rest}m';
  }

  String _formatTime(String value) {
    final List<String> parts = value.split(':');
    if (parts.length < 2) return value;
    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return value;
    final int hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final String period = hour < 12 ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickProfessional() async {
    if (_professionals.isEmpty) return;
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Profesional',
      options: _professionals
          .map((Profesional item) => item.nombreCompleto)
          .toList(),
      selected: _selected?.nombreCompleto,
    );
    if (picked == null) return;
    setState(() {
      _selected = _professionals.firstWhere(
        (Profesional item) => item.nombreCompleto == picked,
      );
    });
  }

  Future<void> _editHorario(HorarioLaboral horario) async {
    final _ShiftEditResult? result = await showModalBottomSheet<_ShiftEditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditShiftSheet(horario: horario),
    );
    if (result == null || !mounted) return;
    try {
      if (result.delete) {
        final response = await AuraApi.horarios.delete(horario.id);
        if (!mounted) return;
        if (!response.isSuccess) {
          _showError(response.message ?? 'No se pudo eliminar la jornada.');
          return;
        }
      } else {
        final response = await AuraApi.horarios.update(
          horario.id,
          HorarioLaboral(
            id: horario.id,
            profesionalId: horario.profesionalId,
            diaSemana: horario.diaSemana,
            horaInicio: result.inicio,
            horaFin: result.fin,
            tieneAlmuerzo: result.almuerzo,
            horaInicioAlmuerzo: result.almuerzo ? result.almInicio : '00:00:00',
            horaFinAlmuerzo: result.almuerzo ? result.almFin : '00:00:00',
          ),
        );
        if (!mounted) return;
        if (!response.isSuccess) {
          _showError(response.message ?? 'No se pudo actualizar la jornada.');
          return;
        }
      }
      _load();
    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final List<HorarioLaboral> items = _delProfesional;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppAdminTopBar(
            title: 'Aura Stylist',
            section: '',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.showToast)
                    const AppSuccessToast(
                      title: 'Jornada agregada correctamente',
                      message: 'El horario semanal se actualizó en la agenda.',
                    ),
                  _AssignedProfessionalCard(
                    profesional: _selected,
                    onTap: _pickProfessional,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Horario Semanal',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFonts.heading,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            height: 30 / 22,
                            letterSpacing: -0.44,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Jornadas activas',
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 18 / 13,
                          color: AppColors.textSecondaryMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AvailabilityCard(
                    hours: _horasTexto,
                    days: items.length,
                    loading: _loading,
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_error != null)
                    Column(
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 13,
                            color: AppColors.danger,
                          ),
                        ),
                        TextButton(
                          onPressed: _load,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  else if (items.isEmpty)
                    Text(
                      'No hay jornadas registradas para este profesional.',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        color: AppColors.textSecondaryMuted,
                      ),
                    )
                  else
                    for (final HorarioLaboral horario in items) ...[
                      _DayCard(
                        day: horario.diaNombre,
                        start: _formatTime(horario.horaInicio),
                        end: _formatTime(horario.horaFin),
                        lunch: horario.tieneAlmuerzo
                            ? '${_formatTime(horario.horaInicioAlmuerzo)} – '
                                  '${_formatTime(horario.horaFinAlmuerzo)}'
                            : '',
                        onTap: () => _editHorario(horario),
                      ),
                      const SizedBox(height: 12),
                    ],
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).pushNamed(AppRoutes.addShift);
                      if (!mounted) return;
                      _load();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar jornada'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedProfessionalCard extends StatelessWidget {
  const _AssignedProfessionalCard({
    required this.profesional,
    required this.onTap,
  });

  final Profesional? profesional;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Profesional? item = profesional;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowMenuCard,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'PROFESIONAL ASIGNADO',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 14 / 10,
                    letterSpacing: 0.55,
                    color: AppColors.textSecondaryFaint,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.overlayGreen30,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
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
                      const SizedBox(width: 4),
                      Text(
                        'Cambiar',
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          height: 14 / 11,
                          color: AppColors.accentDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryButtonSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    item?.iniciales ?? '?',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item?.nombreCompleto ?? 'Sin profesional',
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 20 / 15,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        item?.especialidad?.nombre ?? 'Sin especialidad',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          height: 16 / 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        item == null
                            ? ''
                            : 'CC ${item.documento} · '
                                  '${item.porcentaje.toStringAsFixed(0)}% comisión',
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
                Text(
                  item == null ? '' : '#${item.id}',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.textSecondaryMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.hours,
    required this.days,
    required this.loading,
  });

  final String hours;
  final int days;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryButtonSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cálculo de Disponibilidad',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 14 / 10,
                    letterSpacing: 0.55,
                    color: AppColors.textSecondaryFaint,
                  ),
                ),
                Text(
                  loading
                      ? 'Calculando…'
                      : '$hours horas programadas / semana',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 20 / 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.overlayGreen40,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              '$days días\nactivos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                height: 13 / 10,
                color: AppColors.buttonLabelDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.start,
    required this.end,
    required this.lunch,
    required this.onTap,
  });

  final String day;
  final String start;
  final String end;
  final String lunch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w700,
      fontSize: 10,
      height: 14 / 10,
      letterSpacing: 0.4,
      color: AppColors.textSecondaryFaint,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowMenuCard,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  day,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 20 / 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _timeBox(labelStyle, 'Apertura', start),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _timeBox(labelStyle, 'Cierre', end),
                ),
              ],
            ),
            if (lunch.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.restaurant_outlined,
                    size: 14,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Receso de almuerzo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    lunch,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timeBox(TextStyle labelStyle, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftEditResult {
  const _ShiftEditResult({
    required this.delete,
    this.inicio = '',
    this.fin = '',
    this.almuerzo = false,
    this.almInicio = '',
    this.almFin = '',
  });

  final bool delete;
  final String inicio;
  final String fin;
  final bool almuerzo;
  final String almInicio;
  final String almFin;
}

class _EditShiftSheet extends StatefulWidget {
  const _EditShiftSheet({required this.horario});

  final HorarioLaboral horario;

  @override
  State<_EditShiftSheet> createState() => _EditShiftSheetState();
}

class _EditShiftSheetState extends State<_EditShiftSheet> {
  late TimeOfDay _inicio;
  late TimeOfDay _fin;
  late bool _almuerzo;
  late TimeOfDay _almInicio;
  late TimeOfDay _almFin;

  static TimeOfDay _parse(String value, TimeOfDay fallback) {
    final List<String> parts = value.split(':');
    if (parts.length < 2) return fallback;
    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return fallback;
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void initState() {
    super.initState();
    _inicio = _parse(widget.horario.horaInicio, const TimeOfDay(hour: 8, minute: 0));
    _fin = _parse(widget.horario.horaFin, const TimeOfDay(hour: 18, minute: 0));
    _almuerzo = widget.horario.tieneAlmuerzo;
    _almInicio = _parse(
      widget.horario.horaInicioAlmuerzo,
      const TimeOfDay(hour: 13, minute: 0),
    );
    _almFin = _parse(
      widget.horario.horaFinAlmuerzo,
      const TimeOfDay(hour: 14, minute: 0),
    );
  }

  static String _apiTime(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}:00';

  static String _label(TimeOfDay value) {
    final int hour12 = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    final String minute = value.minute.toString().padLeft(2, '0');
    final String period = value.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _pick(bool isStart) async {
    final TimeOfDay? picked = await pickAppTime(
      context,
      initial: isStart ? _inicio : _fin,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _inicio = picked;
      } else {
        _fin = picked;
      }
    });
  }

  Future<void> _pickLunch(bool isStart) async {
    final TimeOfDay? picked = await pickAppTime(
      context,
      initial: isStart ? _almInicio : _almFin,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _almInicio = picked;
      } else {
        _almFin = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Editar ${widget.horario.diaNombre}',
                style: TextStyle(
                  fontFamily: AppFonts.heading,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              _row('Apertura', _label(_inicio), () => _pick(true)),
              const SizedBox(height: 10),
              _row('Cierre', _label(_fin), () => _pick(false)),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Receso de almuerzo',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                value: _almuerzo,
                onChanged: (bool value) => setState(() => _almuerzo = value),
              ),
              if (_almuerzo) ...[
                _row('Inicio almuerzo', _label(_almInicio), () => _pickLunch(true)),
                const SizedBox(height: 10),
                _row('Fin almuerzo', _label(_almFin), () => _pickLunch(false)),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  _ShiftEditResult(
                    delete: false,
                    inicio: _apiTime(_inicio),
                    fin: _apiTime(_fin),
                    almuerzo: _almuerzo,
                    almInicio: _apiTime(_almInicio),
                    almFin: _apiTime(_almFin),
                  ),
                ),
                child: const Text('Guardar jornada'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(
                  const _ShiftEditResult(delete: true),
                ),
                child: const Text(
                  'Eliminar jornada',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.schedule,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
