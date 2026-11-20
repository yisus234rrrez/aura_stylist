import 'package:flutter/material.dart';

import '../../models/profesionales/profesional.dart';
import '../../models/servicios/servicio.dart';
import '../../routes/app_route_args.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_admin_top_bar.dart';
import '../../widgets/app_form_actions.dart';
import '../../widgets/app_options_sheet.dart';
import '../../widgets/app_pickers.dart';
import '../../widgets/app_select_field.dart';


class ReservationRescheduleScreen extends StatefulWidget {
  const ReservationRescheduleScreen({
    super.key,
    this.initial = const ReservationRouteArgs(),
  });

  final ReservationRouteArgs initial;

  @override
  State<ReservationRescheduleScreen> createState() =>
      _ReservationRescheduleScreenState();
}

class _ReservationRescheduleScreenState
    extends State<ReservationRescheduleScreen> {
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  List<Profesional> _professionals = <Profesional>[];
  Profesional? _professional;
  List<String> _slots = <String>[];
  String? _selectedSlot;
  bool _loading = true;
  bool _loadingSlots = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final responses = await Future.wait<dynamic>(<Future<dynamic>>[
        AuraApi.profesionales.list(),
        AuraApi.servicios.list(),
      ]);
      if (!mounted) return;
      final professionalResponse = responses[0];
      final serviceResponse = responses[1];
      final List<Profesional> all =
          professionalResponse.data as List<Profesional>? ?? <Profesional>[];
      final List<Servicio> services =
          serviceResponse.data as List<Servicio>? ?? <Servicio>[];
      int specialtyId = 0;
      for (final Servicio item in services) {
        if (item.id == widget.initial.servicioId) specialtyId = item.especialidadId;
      }
      List<Profesional> filtered = all
          .where(
            (Profesional item) =>
                specialtyId == 0 || item.especialidadId == specialtyId,
          )
          .toList();
      if (filtered.isEmpty) filtered = all;
      Profesional? current;
      for (final Profesional item in filtered) {
        if (item.id == widget.initial.profesionalId) current = item;
      }
      current ??= filtered.isEmpty ? null : filtered.first;
      setState(() {
        _professionals = filtered;
        _professional = current;
        _loading = false;
      });
      _loadSlots();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  String get _apiDate =>
      '${_date.year}-${_date.month.toString().padLeft(2, '0')}'
      '-${_date.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final DateTime? picked = await pickAppDate(
      context,
      initial: _date,
      firstDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _selectedSlot = null;
    });
    _loadSlots();
  }

  Future<void> _pickProfessional() async {
    if (_professionals.isEmpty) {
      _showInfo('No hay profesionales disponibles.');
      return;
    }
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Nuevo profesional',
      options: _professionals
          .map((Profesional item) => item.nombreCompleto)
          .toList(),
      selected: _professional?.nombreCompleto,
    );
    if (picked == null) return;
    setState(() {
      _professional = _professionals.firstWhere(
        (Profesional item) => item.nombreCompleto == picked,
      );
      _selectedSlot = null;
    });
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    if (widget.initial.servicioId <= 0) return;
    setState(() {
      _loadingSlots = true;
      _slots = <String>[];
      _selectedSlot = null;
    });
    try {
      final response = await AuraApi.agenda.availableSlots(
        fecha: _apiDate,
        servicioId: widget.initial.servicioId,
        profesionalId: _professional?.id,
      );
      if (!mounted) return;
      setState(() {
        _slots = response.data ?? <String>[];
        _loadingSlots = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadingSlots = false);
      _showInfo(e.message);
    }
  }

  Future<void> _pickSlot() async {
    if (_loadingSlots) return;
    if (_slots.isEmpty) {
      _showInfo('No hay horarios disponibles para esa fecha.');
      return;
    }
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Nuevo horario',
      options: _slots,
      selected: _selectedSlot,
    );
    if (picked != null) setState(() => _selectedSlot = picked);
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirm() async {
    if (widget.initial.id <= 0 || widget.initial.clienteId <= 0) {
      _showInfo('No se identificó la reserva a reagendar.');
      return;
    }
    if (_selectedSlot == null) {
      _showInfo('Selecciona la nueva fecha y hora.');
      return;
    }
    if (_professional == null) {
      _showInfo('Selecciona un profesional.');
      return;
    }
    final bool accepted = await showAppConfirmDialog(
      context,
      title: 'Confirmar reagendamiento',
      message:
          'La cita se moverá al horario seleccionado y se actualizará la '
          'agenda del profesional.',
      confirmLabel: 'Reagendar',
    );
    if (!accepted || !mounted) return;
    setState(() => _saving = true);
    try {
      final String fecha =
          '${_selectedSlot!.trim()}${_selectedSlot!.length == 16 ? ':00' : ''}';
      final response = await AuraApi.reservas.update(
        widget.initial.id,
        fecha: fecha,
        servicioId: widget.initial.servicioId,
        profesionalId: _professional!.id,
        clienteId: widget.initial.clienteId,
      );
      if (!mounted) return;
      if (!response.isSuccess) {
        setState(() => _saving = false);
        _showInfo(response.message ?? 'No se pudo reagendar la reserva.');
        return;
      }
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.reservationRescheduled,
        arguments: ReservationRouteArgs(
          id: widget.initial.id,
          clienteId: widget.initial.clienteId,
          servicioId: widget.initial.servicioId,
          profesionalId: _professional!.id,
          fechaHora: _selectedSlot!,
          estado: 'Reagendada',
          clientName: widget.initial.clientName,
          clientDocument: widget.initial.clientDocument,
          clientInitials: widget.initial.clientInitials,
          serviceName: widget.initial.serviceName,
          professionalName: _professional!.nombreCompleto,
          price: widget.initial.price,
          duration: widget.initial.duration,
          dayLabel: _dayLabel(_date),
          dayNumber: '${_date.day}',
          dateLong: _longDate(_date),
          time: _selectedSlot ?? '',
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showInfo(e.message);
    }
  }

  static const List<String> _months = <String>[
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  static const List<String> _weekdays = <String>[
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  static String _longDate(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${date.day} de '
      '${_months[date.month - 1]} de ${date.year}';

  static String _dayLabel(DateTime date) =>
      _weekdays[date.weekday - 1].substring(0, 3).toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppAdminTopBar(title: 'Aura Stylist', section: ''),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Reagendar Reserva',
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
                    'Modificación controlada de fecha, hora o profesional',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 18 / 13,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INFORMACIÓN NO MODIFICABLE',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.4,
                            color: AppColors.textSecondaryFaint,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _row(
                          'CLIENTE',
                          widget.initial.clientName.isEmpty
                              ? 'Cliente'
                              : widget.initial.clientName,
                        ),
                        const SizedBox(height: 8),
                        _row(
                          'SERVICIO',
                          widget.initial.serviceName.isEmpty
                              ? 'Servicio'
                              : widget.initial.serviceName,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.dangerSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CITA ACTUAL',
                                style: TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 0.4,
                                  color: AppColors.danger,
                                ),
                              ),
                              Text(
                                widget.initial.dateLong.isEmpty
                                    ? widget.initial.time
                                    : '${widget.initial.dateLong}'
                                          '${widget.initial.time.isEmpty ? '' : ' · ${widget.initial.time}'}',
                                style: TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 13,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    AppSelectField(
                      label: 'Nueva fecha',
                      placeholder: formatAppDate(_date),
                      valueColor: AppColors.textPrimary,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),
                    AppSelectField(
                      label: 'Nuevo horario',
                      placeholder: _loadingSlots
                          ? 'Consultando horarios…'
                          : (_selectedSlot ?? 'Selecciona un horario'),
                      valueColor: _selectedSlot == null
                          ? null
                          : AppColors.textPrimary,
                      onTap: _loadingSlots ? null : _pickSlot,
                    ),
                    if (!_loadingSlots && _slots.isEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'No hay horarios disponibles para esta fecha.',
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 12,
                          color: AppColors.textSecondaryMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    AppSelectField(
                      label: 'Nuevo profesional',
                      placeholder: _professional?.nombreCompleto ??
                          'Selecciona un profesional',
                      valueColor: _professional == null
                          ? null
                          : AppColors.textPrimary,
                      onTap: _pickProfessional,
                    ),
                  ],
                ],
              ),
            ),
          ),
          AppFormActions(
            primaryLabel: 'Confirmar Reagendamiento',
            onCancel: () => Navigator.of(context).maybePop(),
            onPrimary: _saving ? null : _confirm,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 0.4,
            color: AppColors.textSecondaryFaint,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}
