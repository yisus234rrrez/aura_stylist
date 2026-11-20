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
import '../../widgets/app_success_toast.dart';




class ReservationConfirmScreen extends StatefulWidget {
  const ReservationConfirmScreen({
    super.key,
    this.initial = const ReservationRouteArgs(),
  });

  final ReservationRouteArgs initial;

  @override
  State<ReservationConfirmScreen> createState() =>
      _ReservationConfirmScreenState();
}


String _time12(String value) {
  final List<String> parts = value.split(':');
  if (parts.length < 2) return value;
  final int? hour = int.tryParse(parts[0]);
  final int? minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return value;
  final int hour12 = hour % 12 == 0 ? 12 : hour % 12;
  final String period = hour < 12 ? 'AM' : 'PM';
  return '${hour12.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')} $period';
}

class _ReservationConfirmScreenState extends State<ReservationConfirmScreen> {
  ReservationRouteArgs get initial => widget.initial;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final List<String> slotParts = initial.fechaHora.split(' ');
    final String datePart = slotParts.isNotEmpty ? slotParts.first : '';
    final String rawTimePart =
        slotParts.length > 1 ? slotParts.sublist(1).join(' ') : '';
    final String timePart = _time12(rawTimePart);
    final DateTime? date = DateTime.tryParse(datePart);
    const List<String> months = <String>[
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC',
    ];
    final String dateText = date == null
        ? datePart
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final String monthLabel = date == null ? '' : months[date.month - 1];
    final String dayNumber = date == null ? '' : date.day.toString();

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
                  const AppSuccessToast(
                    title: '¡Reserva lista para confirmar!',
                    message:
                        'Se notificará a la clienta vía WhatsApp automáticamente '
                        'y se sincronizará la cabina en tiempo real.',
                  ),
                  Row(
                    children: [
                      Text(
                        'PASO 2 DE 2',
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          height: 14 / 11,
                          letterSpacing: 0.55,
                          color: AppColors.textSecondaryFaint,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Sincronización final',
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
                  Text(
                    'Confirmación de Reserva',
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      height: 34 / 26,
                      letterSpacing: -0.52,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    'Revisa y valida los datos de la cita antes de sincronizar '
                    'con la agenda técnica y bloquear el sillón de atención.',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 18 / 13,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _VerifiedCard(),
                  const SizedBox(height: 16),
                  const _VoucherCard(),
                  const SizedBox(height: 16),
                  _ClientCard(
                    name: initial.clientName,
                    initials: initial.clientInitials,
                    document: initial.clientDocument,
                  ),
                  const SizedBox(height: 12),
                  _DetailGrid(
                    serviceName: initial.serviceName,
                    professionalName: initial.professionalName,
                  ),
                  const SizedBox(height: 12),
                  _DateCard(
                    dateText: dateText,
                    timeText: timePart,
                    monthLabel: monthLabel,
                    dayNumber: dayNumber,
                  ),
                ],
              ),
            ),
          ),
          AppFormActions(
            primaryLabel: 'Confirmar Reserva',
            primaryIcon: Icons.check,
            onCancel: () => Navigator.of(context).maybePop(),
            onPrimary: _saving ? null : _confirm,
          ),
        ],
      ),
    );
  }

  Future<void> _confirm() async {
    final bool accepted = await showAppConfirmDialog(
      context,
      title: 'Confirmar reserva',
      message:
          'La cita se bloqueará en la agenda y se notificará a la clienta.',
      confirmLabel: 'Confirmar',
    );
    if (!accepted || !mounted) return;
    if (initial.clienteId == 0 || initial.servicioId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faltan datos del cliente o del servicio.'),
        ),
      );
      return;
    }
    final String fecha =
        '${initial.fechaHora.trim()}${initial.fechaHora.length == 16 ? ':00' : ''}';
    setState(() => _saving = true);
    try {
      final response = await AuraApi.reservas.create(
        fecha: fecha,
        servicioId: initial.servicioId,
        clienteId: initial.clienteId,
      );
      if (!mounted) return;
      if (!response.isSuccess) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'No se pudo crear la reserva.'),
          ),
        );
        return;
      }
      final dynamic raw = response.rawData;
      final dynamic data = raw is Map<String, dynamic> ? raw['data'] : null;
      final int reservaId = data is Map<String, dynamic>
          ? int.tryParse('${data['id']}') ?? 0
          : 0;


      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.reservationCreated,
        (Route<dynamic> route) {
          final String? name = route.settings.name;


          if (name == null) return false;
          return name != AppRoutes.newReservation &&
              name != AppRoutes.reservationConfirmation;
        },
        arguments: ReservationRouteArgs(
          id: reservaId,
          clienteId: initial.clienteId,
          servicioId: initial.servicioId,
          profesionalId: initial.profesionalId,
          fechaHora: initial.fechaHora,
          clientName: initial.clientName,
          clientDocument: initial.clientDocument,
          clientInitials: initial.clientInitials,
          serviceName: initial.serviceName,
          professionalName: initial.professionalName,
          price: initial.price,
          duration: initial.duration,
          time: initial.fechaHora,
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
}

class _VerifiedCard extends StatelessWidget {
  const _VerifiedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.overlayGreen25,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_outlined,
            size: 18,
            color: AppColors.accentDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen de cita verificado',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 18 / 13,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Cabina 02 reservada provisionalmente (15 min)',
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
          const Icon(
            Icons.lock_outline,
            size: 16,
            color: AppColors.textSecondaryMuted,
          ),
        ],
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  const _VoucherCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMenuCard,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.controlPanel,
              shape: BoxShape.circle,
            ),
            child: Text(
              'AS',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comprobante Interno',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 14 / 10,
                    letterSpacing: 0.4,
                    color: AppColors.textSecondaryFaint,
                  ),
                ),
                Text(
                  'VOUCHER #AR-84092',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.overlayBlue60,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 12,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Pre-Aprobada',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 14 / 10,
                    color: AppColors.textPrimary,
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

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.name,
    required this.initials,
    required this.document,
  });

  final String name;
  final String initials;
  final String document;

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
      child: Row(
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
              initials.isEmpty ? 'VR' : initials,
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name.isEmpty ? 'Valentina Restrepo Duque' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 20 / 15,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.overlayGreen40,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        'VIP DIAMANTE',
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          color: AppColors.buttonLabelDark,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  document.isEmpty ? 'Sin documento' : document,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.textSecondaryMuted,
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

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({
    required this.serviceName,
    required this.professionalName,
  });

  final String serviceName;
  final String professionalName;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _cell(
              'Servicio',
              serviceName.isEmpty ? 'Servicio' : serviceName,
              'Servicio de la API',
            ),
          ),
          Expanded(
            child: _cell(
              'Especialista',
              professionalName.isEmpty ? 'Sin asignar' : professionalName,
              'Profesional asignado',
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String label, String value, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            height: 14 / 10,
            letterSpacing: 0.4,
            color: AppColors.textSecondaryFaint,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            height: 20 / 15,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          sub,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 15 / 11,
            color: AppColors.textSecondaryMuted,
          ),
        ),
      ],
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.dateText,
    required this.timeText,
    required this.monthLabel,
    required this.dayNumber,
  });

  final String dateText;
  final String timeText;
  final String monthLabel;
  final String dayNumber;

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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.secondaryButtonSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  monthLabel.isEmpty ? 'OCT' : monthLabel,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 14 / 10,
                    letterSpacing: 0.4,
                    color: AppColors.textSecondaryFaint,
                  ),
                ),
                Text(
                  dayNumber.isEmpty ? '25' : dayNumber,
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 1,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText.isEmpty ? 'Fecha seleccionada' : dateText,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 18 / 13,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  timeText.isEmpty ? 'Hora seleccionada' : timeText,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Turno en bloque',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Duración 180 min (3h)',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: AppColors.textSecondaryMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
