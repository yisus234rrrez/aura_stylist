import 'package:flutter/material.dart';

import '../../models/agenda/agenda.dart';
import '../../models/reservas/reserva.dart';
import '../../routes/app_route_args.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_bottom_nav.dart';




class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Reserva> _reservas = <Reserva>[];
  List<AgendaDay> _days = <AgendaDay>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final DateTime now = DateTime.now();
      final String date = '${now.year}-${_two(now.month)}-${_two(now.day)}';
      final responses = await Future.wait<dynamic>(<Future<dynamic>>[
        AuraApi.reservas.list(fechaInicio: date, fechaFin: date),
        AuraApi.agenda.day(date),
      ]);
      if (!mounted) return;
      final reservasResponse = responses[0];
      final agendaResponse = responses[1];
      setState(() {
        _reservas = reservasResponse.data as List<Reserva>? ?? <Reserva>[];
        _days = agendaResponse.data as List<AgendaDay>? ?? <AgendaDay>[];
        _loading = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  static DateTime? _start(Reserva item) =>
      DateTime.tryParse('${item.fechaCorta}T${item.horaInicio}');

  static DateTime? _end(Reserva item) =>
      DateTime.tryParse('${item.fechaCorta}T${item.horaFin}');

  List<Reserva> get _activas => _reservas
      .where((Reserva item) => item.estado == 0 || item.estado == 3)
      .toList();

  int get _atendidas =>
      _reservas.where((Reserva item) => item.estado == 2).length;

  int get _enCurso {
    final DateTime now = DateTime.now();
    return _activas.where((Reserva item) {
      final DateTime? start = _start(item);
      final DateTime? end = _end(item);
      return start != null &&
          end != null &&
          now.isAfter(start) &&
          now.isBefore(end);
    }).length;
  }

  double get _ocupacion {
    int ocupados = 0;
    int total = 0;
    for (final AgendaDay day in _days) {
      ocupados += day.totalOcupados;
      total += day.totalSlots;
    }
    return total == 0 ? 0 : ocupados / total;
  }

  List<Reserva> get _proximas {
    final List<Reserva> items = _activas.toList();
    items.sort((Reserva a, Reserva b) {
      final DateTime? startA = _start(a);
      final DateTime? startB = _start(b);
      if (startA == null) return 1;
      if (startB == null) return -1;
      return startA.compareTo(startB);
    });
    return items.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Reserva> activas = _activas;
    final int total = activas.length + _atendidas;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(section: 'Inicio'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Greeting(),
                    const SizedBox(height: 24),
                    _MetricsSection(
                      total: total,
                      atendidas: _atendidas,
                      enCurso: _enCurso,
                      ocupacion: _ocupacion,
                      loading: _loading,
                    ),
                    const SizedBox(height: 24),
                    _QuickAccessSection(onReturned: _load),
                    const SizedBox(height: 24),
                    _UpcomingSection(
                      items: _proximas,
                      total: activas.length,
                      loading: _loading,
                    ),
                    const SizedBox(height: 24),
                    const _EditorialTip(),
                  ],
                ),
              ),
            ),
          ),
          const AppBottomNav(currentIndex: 0),
        ],
      ),
    );
  }
}


class _Greeting extends StatelessWidget {
  const _Greeting();

  static const List<String> _months = <String>[
    'ENERO',
    'FEBRERO',
    'MARZO',
    'ABRIL',
    'MAYO',
    'JUNIO',
    'JULIO',
    'AGOSTO',
    'SEPTIEMBRE',
    'OCTUBRE',
    'NOVIEMBRE',
    'DICIEMBRE',
  ];
  static const List<String> _weekdays = <String>[
    'LUNES',
    'MARTES',
    'MIÉRCOLES',
    'JUEVES',
    'VIERNES',
    'SÁBADO',
    'DOMINGO',
  ];

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String today =
        '${_weekdays[now.weekday - 1]}, ${now.day} DE ${_months[now.month - 1]}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          today,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 16 / 12,
            letterSpacing: 0.6,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          'Hola, Administrador',
          style: TextStyle(
            fontFamily: AppFonts.heading,
            fontWeight: FontWeight.w700,
            fontSize: 30,
            height: 38 / 30,
            letterSpacing: -0.3,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}


class _MetricsSection extends StatelessWidget {
  const _MetricsSection({
    required this.total,
    required this.atendidas,
    required this.enCurso,
    required this.ocupacion,
    required this.loading,
  });

  final int total;
  final int atendidas;
  final int enCurso;
  final double ocupacion;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ReservasHoyCard(
          total: total,
          atendidas: atendidas,
          pendientes: total - atendidas,
          loading: loading,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniMetricCard(
                title: 'EN CURSO',
                titleColor: AppColors.textPrimary,
                overlayColor: AppColors.overlayBlue50,
                icon: Icons.spa_outlined,
                iconColor: AppColors.textPrimary,
                value: '$enCurso activos',
                subtitle: enCurso == 1 ? 'cita en cabina' : 'citas en cabina',
                subtitleColor: AppColors.textBody,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniMetricCard(
                title: 'OCUPACIÓN',
                titleColor: AppColors.textPrimary,
                overlayColor: AppColors.overlayGreen30,
                icon: Icons.pie_chart_outline,
                iconColor: AppColors.textPrimary,
                value: '${(ocupacion * 100).round()}%',
                subtitle: 'Agenda de hoy',
                subtitleColor: AppColors.accentDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReservasHoyCard extends StatelessWidget {
  const _ReservasHoyCard({
    required this.total,
    required this.atendidas,
    required this.pendientes,
    required this.loading,
  });

  final int total;
  final int atendidas;
  final int pendientes;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESERVAS DE HOY',
                  style: _labelStyle,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      loading ? '…' : '$total',
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                        height: 30 / 30,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      total == 1 ? 'cita pautada' : 'citas pautadas',
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
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 12,
                          color: AppColors.accentDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$atendidas atendidas',
                          style: _metaBold(AppColors.accentDark),
                        ),
                      ],
                    ),
                    Text(
                      '•',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 14,
                        color: AppColors.dotMuted,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 12,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$pendientes pendientes',
                          style: _metaBold(AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ProgressRing(
            value: total == 0 ? 0 : atendidas / total,
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 4,
              backgroundColor: AppColors.progressTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          Text(
            '${(value * 100).round()}%',
            style: _metaBold(AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({
    required this.title,
    required this.titleColor,
    required this.overlayColor,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
  });

  final String title;
  final Color titleColor;
  final Color overlayColor;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String subtitle;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    height: 14 / 11,
                    letterSpacing: 0.33,
                    color: titleColor,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: overlayColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.heading,
              fontWeight: FontWeight.w700,
              fontSize: 24,
              height: 30 / 24,
              letterSpacing: -0.24,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w400,
              fontSize: 12,
              height: 16 / 12,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}


class _QuickAccessSection extends StatelessWidget {
  const _QuickAccessSection({this.onReturned});

  final VoidCallback? onReturned;

  static const List<({String label, IconData icon, Color overlay, String route})>
      _items =
      <({String label, IconData icon, Color overlay, String route})>[
    (label: 'Agenda', icon: Icons.calendar_today_outlined, overlay: AppColors.overlayBlue40, route: AppRoutes.agenda),
    (label: 'Reserva', icon: Icons.add, overlay: AppColors.overlayGreen40, route: AppRoutes.newReservation),
    (label: 'Clientes', icon: Icons.people_outline, overlay: AppColors.secondaryButtonSurface, route: AppRoutes.clients),
    (label: 'Servicios', icon: Icons.content_cut_outlined, overlay: AppColors.secondaryButtonSurface, route: AppRoutes.services),
    (label: 'Especialidad', icon: Icons.auto_awesome_outlined, overlay: AppColors.secondaryButtonSurface, route: AppRoutes.specialties),
    (label: 'Equipo', icon: Icons.groups_outlined, overlay: AppColors.secondaryButtonSurface, route: AppRoutes.professionals),
    (label: 'Cierres', icon: Icons.lock_outline, overlay: AppColors.secondaryButtonSurface, route: AppRoutes.closures),
    (label: 'Comisiones', icon: Icons.pie_chart_outline, overlay: AppColors.secondaryButtonSurface, route: AppRoutes.commissions),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Accesos Rápidos',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                height: 24 / 16,
                letterSpacing: -0.4,
                color: AppColors.textDark,
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showQuickAccessList(context, onReturned: onReturned),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  'Lista',
                  style: _metaBold(AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (int row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (int col = 0; col < 4; col++) ...[
                if (col > 0) const SizedBox(width: 8),
                Expanded(
                  child: _QuickAccessItem(
                    item: _items[row * 4 + col],
                    onReturned: onReturned,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

void _showQuickAccessList(BuildContext context, {VoidCallback? onReturned}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                'Accesos rápidos',
                style: TextStyle(
                  fontFamily: AppFonts.heading,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              for (final item in _QuickAccessSection._items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: item.overlay,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await Navigator.of(context).pushNamed(item.route);
                    onReturned?.call();
                  },
                ),
            ],
          ),
        ),
        ),
        ),
      );
    },
  );
}

class _QuickAccessItem extends StatelessWidget {
  const _QuickAccessItem({required this.item, this.onReturned});

  final ({String label, IconData icon, Color overlay, String route}) item;
  final VoidCallback? onReturned;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.of(context).pushNamed(item.route);
          onReturned?.call();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: _cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.overlay,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 18, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 14 / 11,
                  letterSpacing: 0.33,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection({
    required this.items,
    required this.total,
    required this.loading,
  });

  final List<Reserva> items;
  final int total;
  final bool loading;

  static List<
    ({
      int id,
      int clienteId,
      String initials,
      String name,
      String service,
      String badge,
      String time,
      String pro,
      Color bar,
    })
  >
  _map(List<Reserva> reservas) {
    return reservas.map((Reserva item) {
      final List<String> parts = item.clienteNombre
          .split(' ')
          .where((String part) => part.isNotEmpty)
          .take(2)
          .toList();
      final String initials = parts
          .map((String part) => part[0])
          .join()
          .toUpperCase();
      final String start = item.horaInicio.length >= 5
          ? item.horaInicio.substring(0, 5)
          : item.horaInicio;
      final String end = item.horaFin.length >= 5
          ? item.horaFin.substring(0, 5)
          : item.horaFin;
      return (
        id: item.id,
        clienteId: item.clienteId,
        initials: initials.isEmpty ? '?' : initials,
        name: item.clienteNombre.isEmpty ? 'Cliente' : item.clienteNombre,
        service: item.servicioNombre.isEmpty ? 'Servicio' : item.servicioNombre,
        badge: estadoReservaTexto(item.estado),
        time: '$start – $end',
        pro: item.profesionalNombre.isEmpty
            ? 'Sin profesional'
            : item.profesionalNombre,
        bar: item.estado == 3 ? AppColors.accentDark : AppColors.primary,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<
      ({
        int id,
        int clienteId,
        String initials,
        String name,
        String service,
        String badge,
        String time,
        String pro,
        Color bar,
      })
    >
    rows = _map(items);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Próximas Reservas de Hoy',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 24 / 16,
                        letterSpacing: -0.4,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      loading ? '…' : '$total',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        height: 1,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.agenda),
              child: Text(
                'Ver agenda',
                style: _metaBold(AppColors.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (rows.isEmpty)
          Text(
            loading
                ? 'Cargando reservas…'
                : 'No hay próximas reservas para hoy.',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              color: AppColors.textSecondaryMuted,
            ),
          )
        else
          for (int i = 0; i < rows.length; i++) ...[
            _ReservationCard(item: rows[i]),
            if (i < rows.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.item});

  final ({
    int id,
    int clienteId,
    String initials,
    String name,
    String service,
    String badge,
    String time,
    String pro,
    Color bar,
  })
  item;

  ({Color background, IconData icon}) get _badgeStyle {
    switch (item.badge) {
      case 'Completada':
        return (
          background: AppColors.overlayGreen25,
          icon: Icons.check_circle_outline,
        );
      case 'Reagendada':
        return (
          background: AppColors.overlayBlue60,
          icon: Icons.event_repeat_outlined,
        );
      case 'Cancelada':
        return (
          background: AppColors.dangerSurface,
          icon: Icons.cancel_outlined,
        );
      default:
        return (
          background: AppColors.secondaryButtonSurface,
          icon: Icons.schedule,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.reservationDetail,
        arguments: ReservationRouteArgs(
          id: item.id,
          clienteId: item.clienteId,
          clientName: item.name,
          clientInitials: item.initials,
          serviceName: item.service,
          professionalName: item.pro,
          estado: item.badge,
          time: item.time,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: _cardDecoration,
          child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          item.initials,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                height: 20 / 14,
                                letterSpacing: 0.14,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              item.service,
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
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Badge(
                        label: item.badge,
                        background: _badgeStyle.background,
                        icon: _badgeStyle.icon,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.time,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          height: 16 / 12,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.person_outline,
                        size: 13,
                        color: AppColors.textBody,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item.pro,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 6, color: item.bar),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.icon,
  });

  final String label;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textPrimary),
          const SizedBox(width: 4),
          Text(
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
        ],
      ),
    );
  }
}


class _EditorialTip extends StatelessWidget {
  const _EditorialTip();

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
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              size: 18,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atención personalizada',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 16 / 12,
                    letterSpacing: 0.24,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Recuerda ofrecer la infusión de jazmín orgánico a las '
                  'clientes con tratamientos de más de 90 minutos.',
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
    );
  }
}



const BoxDecoration _cardDecoration = BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.all(Radius.circular(12)),
  boxShadow: [
    BoxShadow(
      color: AppColors.shadowSoft,
      blurRadius: 1,
      offset: Offset(0, 1),
    ),
  ],
);

TextStyle get _labelStyle => TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w700,
      fontSize: 11,
      height: 14 / 11,
      letterSpacing: 0.275,
      color: AppColors.textPrimary,
    );

TextStyle _metaBold(Color color) => TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w700,
      fontSize: 11,
      height: 14 / 11,
      letterSpacing: 0.33,
      color: color,
    );

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: child,
    );
  }
}
