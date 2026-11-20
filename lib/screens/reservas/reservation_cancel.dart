import 'package:flutter/material.dart';

import '../../routes/app_route_args.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_admin_top_bar.dart';
import '../../widgets/app_form_actions.dart';
import '../../widgets/app_options_sheet.dart';
import '../../widgets/app_text_field.dart';




class ReservationCancelScreen extends StatefulWidget {
  const ReservationCancelScreen({
    super.key,
    this.initial = const ReservationRouteArgs(),
  });

  final ReservationRouteArgs initial;

  @override
  State<ReservationCancelScreen> createState() =>
      _ReservationCancelScreenState();
}

class _ReservationCancelScreenState extends State<ReservationCancelScreen> {
  int _selected = 0;
  bool _saving = false;

  static const List<({String title, String subtitle})> _reasons =
      <({String title, String subtitle})>[
        (
          title: 'Solicitud del cliente (previo aviso)',
          subtitle: 'Notificado por llamada o WhatsApp oficial',
        ),
        (
          title: 'Inasistencia no justificada (No-Show)',
          subtitle: 'Más de 20 minutos de retraso sin contacto',
        ),
        (
          title: 'Imprevisto de salud del profesional',
          subtitle: 'Baja médica del profesional asignado',
        ),
        (
          title: 'Fuerza mayor o cierre extraordinario',
          subtitle: 'Corte de suministro o incidencia edilicia',
        ),
      ];

  Future<void> _cancelar() async {
    final bool accepted = await showAppConfirmDialog(
      context,
      title: 'Cancelar reserva',
      message:
          'El turno quedará disponible y la clienta recibirá la '
          'notificación de cancelación.',
      confirmLabel: 'Cancelar reserva',
    );
    if (!accepted || !mounted) return;
    if (widget.initial.id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se identificó la reserva a cancelar.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final response = await AuraApi.reservas.cancel(widget.initial.id);
      if (!mounted) return;
      if (!response.isSuccess) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ?? 'No se pudo cancelar la reserva.',
            ),
          ),
        );
        return;
      }
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.reservationCancelled,
        arguments: ReservationRouteArgs(
          id: widget.initial.id,
          estado: 'Cancelada',
          clientName: widget.initial.clientName,
          clientDocument: widget.initial.clientDocument,
          clientInitials: widget.initial.clientInitials,
          serviceName: widget.initial.serviceName,
          professionalName: widget.initial.professionalName,
          price: widget.initial.price,
          duration: widget.initial.duration,
          dayLabel: widget.initial.dayLabel,
          dayNumber: widget.initial.dayNumber,
          dateLong: widget.initial.dateLong,
          time: widget.initial.time,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

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
                  _ActiveAppointmentCard(initial: widget.initial),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.dangerSurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 26,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'GESTIÓN DE CANCELACIÓN',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        height: 14 / 11,
                        letterSpacing: 0.55,
                        color: AppColors.textSecondaryFaint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      '¿Deseas cancelar esta reserva?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        height: 32 / 24,
                        letterSpacing: -0.24,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esta acción liberará el turno en la agenda y notificará '
                    'la anulación de la cita de inmediato.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 18 / 13,
                      color: AppColors.textBody,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 16,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Acción crítica irreversible. El horario quedará '
                            'disponible en el calendario online de estilistas.',
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 16 / 12,
                              color: AppColors.textBody,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Motivo administrativo de cancelación',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            height: 16 / 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        ' *',
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < _reasons.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _ReasonOption(
                      title: _reasons[i].title,
                      subtitle: _reasons[i].subtitle,
                      selected: _selected == i,
                      onTap: () => setState(() => _selected = i),
                    ),
                  ],
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Observaciones internas de cancelación (Opcional)',
                    labelStyle: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 16 / 12,
                      color: AppColors.textPrimary,
                    ),
                    hintText: 'Detalles adicionales para el registro interno',
                    hintColor: AppColors.hintOnWhite,
                    fillColor: AppColors.white,
                    elevated: true,
                    borderRadius: 12,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          AppFormActions(
            primaryLabel: 'Cancelar Reserva',
            primaryIcon: Icons.cancel_outlined,
            onCancel: () => Navigator.of(context).maybePop(),
            onPrimary: _saving ? null : _cancelar,
          ),
        ],
      ),
    );
  }
}

class _ActiveAppointmentCard extends StatelessWidget {
  const _ActiveAppointmentCard({required this.initial});

  final ReservationRouteArgs initial;

  String _initials(String name) {
    final List<String> parts = name
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .take(2)
        .toList();
    return parts.isEmpty
        ? '?'
        : parts.map((String part) => part[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String client = initial.clientName.isEmpty
        ? 'Cliente'
        : initial.clientName;
    final String service = initial.serviceName.isEmpty
        ? 'Servicio'
        : initial.serviceName;
    final String professional = initial.professionalName.isEmpty
        ? 'Sin profesional'
        : initial.professionalName;
    final String when = initial.dateLong.isEmpty
        ? initial.time
        : '${initial.dateLong}${initial.time.isEmpty ? '' : ' · ${initial.time}'}';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CITA ACTIVA',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  height: 14 / 10,
                  letterSpacing: 0.4,
                  color: AppColors.textSecondaryFaint,
                ),
              ),
              const Spacer(),
              Text(
                initial.id > 0 ? '#RES-${initial.id}' : '',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: AppColors.textSecondaryMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryButtonSurface,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initials(client),
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
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
                      client,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      service,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 14,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  professional,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 14,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  when,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReasonOption extends StatelessWidget {
  const _ReasonOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.overlayGreen25 : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.secondaryButtonSurface,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.secondary : AppColors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.secondary
                      : AppColors.textSecondaryFaint,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 13, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 18 / 13,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      height: 15 / 11,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
