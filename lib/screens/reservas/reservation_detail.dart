import 'package:flutter/material.dart';

import '../../models/clientes/cliente.dart';
import '../../routes/app_route_args.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_admin_top_bar.dart';
import '../../widgets/app_success_toast.dart';

String _initials(String name) {
  return name
      .split(' ')
      .where((String part) => part.isNotEmpty)
      .take(2)
      .map((String part) => part[0])
      .join();
}





class ReservationDetailScreen extends StatefulWidget {
  const ReservationDetailScreen({
    super.key,
    this.status = '',
    this.showToast = false,
    this.toastTitle = '',
    this.toastMessage = '',
    this.dayLabel = 'VIE',
    this.dayNumber = '25',
    this.dateLong = 'Viernes, 25 de Octubre de 2024',
    this.time = '09:00 AM – 12:00 PM',
    this.initial = const ReservationRouteArgs(),
  });

  final String status;
  final bool showToast;
  final String toastTitle;
  final String toastMessage;
  final String dayLabel;
  final String dayNumber;
  final String dateLong;
  final String time;
  final ReservationRouteArgs initial;

  @override
  State<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  ReservationRouteArgs get initial => widget.initial;
  String get status => widget.status;
  bool get showToast => widget.showToast;
  String get toastTitle => widget.toastTitle;
  String get toastMessage => widget.toastMessage;
  String get dayLabel => widget.dayLabel;
  String get dayNumber => widget.dayNumber;
  String get dateLong => widget.dateLong;
  String get time => widget.time;

  Cliente? _cliente;

  @override
  void initState() {
    super.initState();
    _loadCliente();
  }

  Future<void> _loadCliente() async {
    final int id = initial.clienteId;
    final String document = initial.clientDocument.trim();
    final String name = initial.clientName.trim();
    if (id <= 0 && document.isEmpty && name.isEmpty) return;
    try {
      if (document.isNotEmpty) {
        final response = await AuraApi.clientes.byDocumento(document);
        if (!mounted) return;
        if (response.isSuccess && response.data != null) {
          setState(() => _cliente = response.data);
          return;
        }
      }
      if (id <= 0 && name.isEmpty) return;
      final response = await AuraApi.clientes.list();
      if (!mounted) return;
      final List<Cliente> items = response.data ?? <Cliente>[];
      Cliente? match;
      for (final Cliente item in items) {
        if ((id > 0 && item.id == id) || (name.isNotEmpty && item.nombreCompleto == name)) {
          match = item;
          break;
        }
      }
      if (match != null) setState(() => _cliente = match);
    } on ApiException {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Cliente? cliente = _cliente;
    final String clientName = cliente != null && cliente.nombreCompleto.isNotEmpty
        ? cliente.nombreCompleto
        : (initial.clientName.isEmpty ? 'Cliente' : initial.clientName);
    final String clientDocument = cliente != null
        ? cliente.documento
        : initial.clientDocument;
    final String clientInitials = initial.clientInitials.isEmpty
        ? _initials(clientName)
        : initial.clientInitials;
    final String clientPhone = cliente?.celular ?? '';
    final String clientEmail = cliente?.correo ?? '';
    final String serviceName = initial.serviceName.isEmpty
        ? 'Servicio'
        : initial.serviceName;
    final String professionalName = initial.professionalName.isEmpty
        ? 'Profesional'
        : initial.professionalName;
    final String price = initial.price;
    final String duration = initial.duration;
    final String dayLabelValue =
        initial.dayLabel.isEmpty ? dayLabel : initial.dayLabel;
    final String dayNumberValue =
        initial.dayNumber.isEmpty ? dayNumber : initial.dayNumber;
    final String dateLongValue =
        initial.dateLong.isEmpty ? dateLong : initial.dateLong;
    final String timeValue = initial.time.isEmpty ? time : initial.time;
    final String statusValue = initial.estado.isNotEmpty
        ? initial.estado
        : (status.isEmpty
              ? 'Agendada'
              : (status == 'Atendida' ? 'Completada' : status));
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
                  if (showToast)
                    AppSuccessToast(
                      title: toastTitle,
                      message: toastMessage,
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DETALLE DE RESERVA',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                height: 14 / 11,
                                letterSpacing: 0.55,
                                color: AppColors.textSecondaryFaint,
                              ),
                            ),
                            Text(
                              initial.id > 0
                                  ? 'Cita #RES-${initial.id}'
                                  : 'Detalle de reserva',
                              style: TextStyle(
                                fontFamily: AppFonts.heading,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                height: 32 / 24,
                                letterSpacing: -0.24,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(status: statusValue),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.event_available_outlined,
                    title: 'Horario y Ubicación',
                    child: Column(
                      children: [
                        Row(
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
                                    dayLabelValue,
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
                                    dayNumberValue,
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
                                    dateLongValue,
                                    style: TextStyle(
                                      fontFamily: AppFonts.body,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      height: 18 / 13,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        size: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          timeValue,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: AppFonts.body,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              duration,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                color: AppColors.textSecondaryMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.meeting_room_outlined,
                              size: 14,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Cabina 02 · Tocador Principal',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ClientCard(
                    name: clientName,
                    document: clientDocument,
                    initials: clientInitials,
                    phone: clientPhone,
                    email: clientEmail,
                  ),
                  const SizedBox(height: 16),
                  _ServiceCard(
                    name: serviceName,
                    professional: professionalName,
                    price: price,
                  ),
                  if (initial.id > 0 &&
                      (statusValue == 'Agendada' ||
                          statusValue == 'Reagendada')) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(
                                color: AppColors.secondaryButtonSurface,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Navigator.of(context).pushNamed(
                              AppRoutes.rescheduleReservation,
                              arguments: initial,
                            ),
                            icon: const Icon(
                              Icons.event_repeat_outlined,
                              size: 18,
                            ),
                            label: const Text('Reagendar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(
                                color: AppColors.dangerSurface,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Navigator.of(context).pushNamed(
                              AppRoutes.cancelReservation,
                              arguments: initial,
                            ),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Cancelar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final bool cancelled = status == 'Cancelada';
    final bool completed = status == 'Completada';
    final bool rescheduled = status == 'Reagendada';
    final Color bg = cancelled
        ? AppColors.dangerSurface
        : (completed
              ? AppColors.overlayGreen40
              : (rescheduled
                    ? AppColors.overlayBlue50
                    : AppColors.secondaryButtonSurface));
    final Color fg = cancelled
        ? AppColors.danger
        : (completed ? AppColors.buttonLabelDark : AppColors.textPrimary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            cancelled
                ? Icons.cancel_outlined
                : (completed
                      ? Icons.check_circle_outline
                      : (rescheduled
                            ? Icons.event_repeat_outlined
                            : Icons.schedule)),
            size: 12,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              height: 14 / 11,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.name,
    required this.document,
    required this.initials,
    this.phone = '',
    this.email = '',
  });

  final String name;
  final String document;
  final String initials;
  final String phone;
  final String email;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 17,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ficha de Cliente',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryButtonSurface,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Habitual',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                  initials,
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
                      name,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 20 / 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      document,
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
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 15,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  phone.isEmpty ? 'Sin celular' : phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _MiniAction(label: 'Llamar', icon: Icons.call_outlined),
              const SizedBox(width: 6),
              _MiniAction(
                label: 'WhatsApp',
                icon: Icons.chat_bubble_outline,
                filled: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.mail_outline,
                size: 15,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  email.isEmpty ? 'Sin correo' : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.label,
    required this.icon,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color bg = filled
        ? AppColors.primary
        : AppColors.secondaryButtonSurface;
    final Color fg = filled ? AppColors.buttonLabelDark : AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.name,
    required this.professional,
    required this.price,
  });

  final String name;
  final String professional;
  final String price;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.content_cut_outlined,
                size: 17,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Servicio & Facturación',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 20 / 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      professional,
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
              Text(
                price,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
