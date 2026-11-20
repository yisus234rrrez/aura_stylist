import 'package:flutter/material.dart';

import '../../models/agenda/agenda.dart';
import '../../models/clientes/cliente.dart';
import '../../models/profesionales/profesional.dart';
import '../../models/reservas/reserva.dart';
import '../../models/servicios/servicio.dart';
import '../../routes/app_route_args.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_pickers.dart';




class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key, this.calendarView = false});

  final bool calendarView;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  static const List<String> _monthNames = <String>[
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
  static const List<String> _weekdayNames = <String>[
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  DateTime _selectedDate = DateTime.now();
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _professionalFilter = 'Todos';
  String _serviceFilter = 'Todos';
  String _clientFilter = 'Todos los clientes';
  List<String> _professionalOptions = <String>['Todos'];
  List<String> _serviceOptions = <String>['Todos'];
  List<String> _clientOptions = <String>['Todos los clientes'];
  List<AgendaDay> _days = <AgendaDay>[];
  List<Reserva> _reservasDelDia = <Reserva>[];
  Map<int, int> _estadoPorReserva = <int, int>{};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAgenda();
    _loadFilters();
  }

  Future<void> _loadAgenda() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final String apiDate = _apiDate(_selectedDate);
      final responses = await Future.wait<dynamic>(<Future<dynamic>>[
        AuraApi.agenda.day(apiDate),
        AuraApi.reservas.list(fechaInicio: apiDate, fechaFin: apiDate),
      ]);
      if (!mounted) return;
      final response = responses[0];
      final reservasResponse = responses[1];
      if (reservasResponse.isSuccess) {
        _reservasDelDia =
            reservasResponse.data as List<Reserva>? ?? <Reserva>[];
        _estadoPorReserva = <int, int>{
          for (final Reserva item in _reservasDelDia) item.id: item.estado,
        };
      }
      if (response.isSuccess) {
        setState(() {
          _days = response.data ?? <AgendaDay>[];
          _loading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'No se pudo cargar la agenda.';
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _loadFilters() async {
    try {
      final responses = await Future.wait<dynamic>(<Future<dynamic>>[
        AuraApi.profesionales.list(),
        AuraApi.servicios.list(),
        AuraApi.clientes.list(),
      ]);
      if (!mounted) return;
      final proResponse = responses[0];
      final serResponse = responses[1];
      final cliResponse = responses[2];
      setState(() {
        if (proResponse.isSuccess) {
          _professionalOptions = <String>[
            'Todos',
            for (final Profesional item
                in proResponse.data as List<Profesional>? ?? <Profesional>[])
              item.nombreCompleto,
          ];
        }
        if (serResponse.isSuccess) {
          _serviceOptions = <String>[
            'Todos',
            for (final Servicio item
                in serResponse.data as List<Servicio>? ?? <Servicio>[])
              item.nombre,
          ];
        }
        if (cliResponse.isSuccess) {
          _clientOptions = <String>[
            'Todos los clientes',
            for (final Cliente item
                in cliResponse.data as List<Cliente>? ?? <Cliente>[])
              item.nombreCompleto,
          ];
        }
      });
    } on ApiException {
      return;
    }
  }

  static String _apiDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}'
      '-${date.day.toString().padLeft(2, '0')}';

  String get _selectedDateLong {
    final String weekday = _weekdayNames[_selectedDate.weekday - 1];
    final String month = _monthNames[_selectedDate.month - 1];
    return '$weekday, ${_selectedDate.day} de $month de ${_selectedDate.year}';
  }

  String get _selectedDateShort =>
      '${_selectedDate.day} ${_monthNames[_selectedDate.month - 1].substring(0, 3)}';

  String get _selectedDayLabel =>
      _weekdayNames[_selectedDate.weekday - 1].substring(0, 3).toUpperCase();

  String get _selectedDayNumber => '${_selectedDate.day}';

  bool get _isToday {
    final DateTime now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _visibleMonth = DateTime(date.year, date.month);
    });
    _loadAgenda();
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  static String _timeOnly(String value) {
    final List<String> parts = value.split(' ');
    if (parts.length < 2) return value;
    final List<String> time = parts[1].split(':');
    return time.length >= 2 ? '${time[0]}:${time[1]}' : parts[1];
  }


  static String _estadoTexto(int estado) => estadoReservaTexto(estado);

  List<
    ({
      int id,
      int clienteId,
      int servicioId,
      int profesionalId,
      String professional,
      String time,
      String client,
      String service,
      String price,
      String duration,
      String status,
    })
  >
  get _reservedSlots {
    final Map<
      int,
      ({
        int id,
        int clienteId,
        int servicioId,
        int profesionalId,
        String professional,
        String time,
        String client,
        String service,
        String price,
        String duration,
        String status,
      })
    >
    unique = <
      int,
      ({
        int id,
        int clienteId,
        int servicioId,
        int profesionalId,
        String professional,
        String time,
        String client,
        String service,
        String price,
        String duration,
        String status,
      })
    >{};
    for (final AgendaDay day in _days) {
      if (_professionalFilter != 'Todos' &&
          day.profesionalNombre != _professionalFilter) {
        continue;
      }
      for (final AgendaTimeSlot slot in day.slots) {
        final Map<String, dynamic>? reserva = slot.reserva;
        if (reserva == null) continue;
        final int id = int.tryParse('${reserva['id']}') ?? -1;
        if (unique.containsKey(id)) continue;
        final dynamic cliente = reserva['cliente'];
        final dynamic servicio = reserva['servicio'];
        final String clientName = cliente is Map
            ? (cliente['nombre'] ??
                      '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}')
                  .toString()
                  .trim()
            : 'Cliente';
        final String serviceName = servicio is Map
            ? (servicio['nombre'] ?? 'Servicio').toString()
            : 'Servicio';
        if (_serviceFilter != 'Todos' && serviceName != _serviceFilter) continue;
        if (_clientFilter != 'Todos los clientes' &&
            clientName != _clientFilter) {
          continue;
        }
        final String start = (reserva['fechaInicio'] ?? slot.horaInicio).toString();
        final String end = (reserva['fechaFin'] ?? slot.horaFin).toString();
        final num precio = servicio is Map
            ? num.tryParse('${servicio['precio'] ?? 0}') ?? 0
            : 0;
        final DateTime? inicio = DateTime.tryParse(start.replaceFirst(' ', 'T'));
        final DateTime? fin = DateTime.tryParse(end.replaceFirst(' ', 'T'));
        unique[id] = (
          id: id,
          clienteId: cliente is Map
              ? int.tryParse('${cliente['id']}') ?? 0
              : 0,
          servicioId: servicio is Map
              ? int.tryParse('${servicio['id']}') ?? 0
              : 0,
          profesionalId: day.profesionalId,
          professional: day.profesionalNombre,
          time: '${_timeOnly(start)} – ${_timeOnly(end)}',
          client: clientName.isEmpty ? 'Cliente' : clientName,
          service: serviceName,
          price: precio > 0 ? '\$${precio.toInt()} COP' : '',
          duration: inicio != null && fin != null
              ? '${fin.difference(inicio).inMinutes} min'
              : '',
          status: _estadoTexto(_estadoPorReserva[id] ?? 0),
        );
      }
    }
    final List<
      ({
        int id,
        int clienteId,
        int servicioId,
        int profesionalId,
        String professional,
        String time,
        String client,
        String service,
        String price,
        String duration,
        String status,
      })
    >
    result = unique.values.toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return result;
  }



  List<
    ({
      int id,
      int clienteId,
      int servicioId,
      int profesionalId,
      String time,
      String client,
      String service,
      String professional,
      String status,
    })
  >
  get _otherReservations {
    final Set<int> ocupadas = <int>{
      for (final item in _reservedSlots) item.id,
    };
    final List<
      ({
        int id,
        int clienteId,
        int servicioId,
        int profesionalId,
        String time,
        String client,
        String service,
        String professional,
        String status,
      })
    >
    result = <
      ({
        int id,
        int clienteId,
        int servicioId,
        int profesionalId,
        String time,
        String client,
        String service,
        String professional,
        String status,
      })
    >[];
    for (final Reserva item in _reservasDelDia) {
      if (item.estado == 0 || ocupadas.contains(item.id)) continue;
      if (_professionalFilter != 'Todos' &&
          item.profesionalNombre != _professionalFilter) {
        continue;
      }
      if (_serviceFilter != 'Todos' && item.servicioNombre != _serviceFilter) {
        continue;
      }
      if (_clientFilter != 'Todos los clientes' &&
          item.clienteNombre != _clientFilter) {
        continue;
      }
      final String start = item.horaInicio.length >= 5
          ? item.horaInicio.substring(0, 5)
          : item.horaInicio;
      final String end = item.horaFin.length >= 5
          ? item.horaFin.substring(0, 5)
          : item.horaFin;
      result.add((
        id: item.id,
        clienteId: item.clienteId,
        servicioId: item.servicioId,
        profesionalId: item.profesionalId,
        time: '$start – $end',
        client: item.clienteNombre.isEmpty ? 'Cliente' : item.clienteNombre,
        service: item.servicioNombre.isEmpty ? 'Servicio' : item.servicioNombre,
        professional: item.profesionalNombre,
        status: estadoReservaTexto(item.estado),
      ));
    }
    result.sort((a, b) => a.time.compareTo(b.time));
    return result;
  }

  Future<void> _pickFilter({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) async {
    final String? picked = await showAppOptionPicker(
      context,
      title: title,
      options: options,
      selected: selected,
    );
    if (picked != null) setState(() => onSelected(picked));
  }

  @override
  Widget build(BuildContext context) {
    final reserved = _reservedSlots;
    final others = _otherReservations;
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          const AppHeader(section: 'Agenda'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Agenda',
                              style: TextStyle(
                                fontFamily: AppFonts.heading,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                height: 32 / 24,
                                letterSpacing: -0.6,
                                color: AppColors.secondary,
                              ),
                            ),
                            Text(
                              'Programación y control de turnos en cabina',
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
                      const SizedBox(width: 8),
                      _NewReservationButton(
                        onReturned: () {
                          if (mounted) _loadAgenda();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ViewToggle(calendar: widget.calendarView),
                  const SizedBox(height: 12),
                  if (widget.calendarView)
                    _CalendarCard(
                      month: _visibleMonth,
                      selectedDate: _selectedDate,
                      monthName: _monthNames[_visibleMonth.month - 1],
                      selectedLabel: _selectedDateLong,
                      onSelect: _selectDate,
                      onPrevMonth: () => _changeMonth(-1),
                      onNextMonth: () => _changeMonth(1),
                    )
                  else
                    _DayBar(
                      label: _selectedDateLong,
                      onPrev: () => _selectDate(
                        _selectedDate.subtract(const Duration(days: 1)),
                      ),
                      onNext: () => _selectDate(
                        _selectedDate.add(const Duration(days: 1)),
                      ),
                      onToday: () => _selectDate(DateTime.now()),
                    ),
                  const SizedBox(height: 12),
                  _Filters(
                    professional: _professionalFilter,
                    service: _serviceFilter,
                    client: _clientFilter,
                    onProfessional: () => _pickFilter(
                      title: 'Profesional',
                      options: _professionalOptions,
                      selected: _professionalFilter,
                      onSelected: (String value) =>
                          setState(() => _professionalFilter = value),
                    ),
                    onService: () => _pickFilter(
                      title: 'Servicio',
                      options: _serviceOptions,
                      selected: _serviceFilter,
                      onSelected: (String value) =>
                          setState(() => _serviceFilter = value),
                    ),
                    onClient: () => _pickFilter(
                      title: 'Cliente',
                      options: _clientOptions,
                      selected: _clientFilter,
                      onSelected: (String value) =>
                          setState(() => _clientFilter = value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isToday
                              ? 'Turnos de hoy'
                              : 'Turnos del día seleccionado',
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
                      const SizedBox(width: 8),
                      _DateBadge(label: _selectedDateShort),
                      const SizedBox(width: 8),
                      Text(
                        reserved.length == 1
                            ? '1 cita asignada'
                            : '${reserved.length} citas asignadas',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          height: 14 / 11,
                          color: AppColors.textSecondaryMuted,
                        ),
                      ),
                    ],
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
                          onPressed: _loadAgenda,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  else if (reserved.isEmpty)
                    Text(
                      'No hay turnos reservados para $_selectedDateShort.',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        color: AppColors.textSecondaryMuted,
                      ),
                    )
                  else
                    for (int i = 0; i < reserved.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      _ApiTurnCard(
                        time: reserved[i].time,
                        professional: reserved[i].professional,
                        client: reserved[i].client,
                        service: reserved[i].service,
                        status: reserved[i].status,
                        onTap: () async {
                          await Navigator.of(context).pushNamed(
                            AppRoutes.reservationDetail,
                            arguments: ReservationRouteArgs(
                              id: reserved[i].id,
                              clienteId: reserved[i].clienteId,
                              servicioId: reserved[i].servicioId,
                              profesionalId: reserved[i].profesionalId,
                              estado: reserved[i].status,
                              clientName: reserved[i].client,
                              serviceName: reserved[i].service,
                              professionalName: reserved[i].professional,
                              price: reserved[i].price,
                              duration: reserved[i].duration,
                              dayLabel: _selectedDayLabel,
                              dayNumber: _selectedDayNumber,
                              dateLong: _selectedDateLong,
                              time: reserved[i].time,
                            ),
                          );
                          if (!mounted) return;
                          _loadAgenda();
                        },
                      ),
                    ],
                    if (others.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Canceladas y reagendadas',
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 24 / 16,
                          letterSpacing: -0.4,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (int i = 0; i < others.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _ApiTurnCard(
                          time: others[i].time,
                          professional: others[i].professional,
                          client: others[i].client,
                          service: others[i].service,
                          status: others[i].status,
                          onTap: () async {
                            await Navigator.of(context).pushNamed(
                              AppRoutes.reservationDetail,
                              arguments: ReservationRouteArgs(
                                id: others[i].id,
                                clienteId: others[i].clienteId,
                                servicioId: others[i].servicioId,
                                profesionalId: others[i].profesionalId,
                                estado: others[i].status,
                                clientName: others[i].client,
                                serviceName: others[i].service,
                                professionalName: others[i].professional,
                                dayLabel: _selectedDayLabel,
                                dayNumber: _selectedDayNumber,
                                dateLong: _selectedDateLong,
                                time: others[i].time,
                              ),
                            );
                            if (!mounted) return;
                            _loadAgenda();
                          },
                        ),
                      ],
                    ],
                ],
              ),
            ),
          ),
          const AppBottomNav(currentIndex: 1),
        ],
      ),
    );
  }
}

class _NewReservationButton extends StatelessWidget {
  const _NewReservationButton({this.onReturned});

  final VoidCallback? onReturned;

  @override
  Widget build(BuildContext context) {
    const BorderRadius radius = BorderRadius.all(Radius.circular(12));
    return Material(
      color: AppColors.primary,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () async {
          await Navigator.of(context).pushNamed(AppRoutes.newReservation);
          onReturned?.call();
        },
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 16, color: AppColors.buttonLabelDark),
              const SizedBox(width: 4),
              Text(
                'Nueva reserva',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.buttonLabelDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.calendar});

  final bool calendar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondaryButtonSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tab(
              context,
              'Vista Lista',
              Icons.list_alt_outlined,
              !calendar,
              AppRoutes.agenda,
            ),
          ),
          Expanded(
            child: _tab(
              context,
              'Vista Calendario',
              Icons.calendar_month_outlined,
              calendar,
              AppRoutes.agendaCalendar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    String label,
    IconData icon,
    bool selected,
    String route,
  ) {
    return Material(
      color: selected ? AppColors.secondary : AppColors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.of(context).pushReplacementNamed(route),
        child: Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? AppColors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: selected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.month,
    required this.selectedDate,
    required this.monthName,
    required this.selectedLabel,
    required this.onSelect,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final DateTime month;
  final DateTime selectedDate;
  final String monthName;
  final String selectedLabel;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  static const List<String> _weekdays = <String>['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final int offset = DateTime(month.year, month.month, 1).weekday - 1;
    final int rows = ((offset + daysInMonth) / 7).ceil();
    final DateTime today = DateTime.now();

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
        children: [
          Row(
            children: [
              InkWell(
                onTap: onPrevMonth,
                customBorder: const CircleBorder(),
                child: Icon(
                  Icons.chevron_left,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      selectedLabel,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 18 / 13,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      '$monthName ${month.year}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: AppColors.textSecondaryMuted,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onNextMonth,
                customBorder: const CircleBorder(),
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final String day in _weekdays)
                Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: AppColors.textSecondaryFaint,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (int row = 0; row < rows; row++)
            Row(
              children: [
                for (int column = 0; column < 7; column++)
                  Expanded(
                    child: _buildCell(
                      row * 7 + column - offset + 1,
                      daysInMonth,
                      today,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCell(int dayNumber, int daysInMonth, DateTime today) {
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox(height: 34);
    }
    final DateTime date = DateTime(month.year, month.month, dayNumber);
    final bool selected = date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
    final bool isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    return InkWell(
      onTap: () => onSelect(date),
      customBorder: const CircleBorder(),
      child: Container(
        height: 34,
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.transparent,
          shape: BoxShape.circle,
          border: isToday && !selected
              ? Border.all(color: AppColors.accentDark)
              : null,
        ),
        child: Text(
          '$dayNumber',
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: selected
                ? AppColors.white
                : AppColors.textSecondaryFaint,
          ),
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.label,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
          InkWell(
            onTap: onPrev,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.chevron_left,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 18 / 13,
                color: AppColors.secondary,
              ),
            ),
          ),
          InkWell(
            onTap: onNext,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onToday,
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryButtonSurface,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                'Hoy',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.professional,
    required this.service,
    required this.client,
    required this.onProfessional,
    required this.onService,
    required this.onClient,
  });

  final String professional;
  final String service;
  final String client;
  final VoidCallback onProfessional;
  final VoidCallback onService;
  final VoidCallback onClient;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _filter('Profesional', professional, onProfessional),
            ),
            const SizedBox(width: 8),
            Expanded(child: _filter('Servicio', service, onService)),
          ],
        ),
        const SizedBox(height: 8),
        _filter('Cliente', client, onClient, full: true),
      ],
    );
  }

  Widget _filter(String label, String value, VoidCallback onTap, {bool full = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 9,
                height: 13 / 9,
                letterSpacing: 0.4,
                color: AppColors.textSecondaryFaint,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.expand_more,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.overlayGreen30,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          height: 14 / 11,
          color: AppColors.accentDark,
        ),
      ),
    );
  }
}

class _ApiTurnCard extends StatelessWidget {
  const _ApiTurnCard({
    required this.time,
    required this.professional,
    required this.client,
    required this.service,
    required this.status,
    this.onTap,
  });

  final String time;
  final String professional;
  final String client;
  final String service;
  final String status;
  final VoidCallback? onTap;

  Color get _statusBackground {
    switch (status) {
      case 'Completada':
        return AppColors.overlayGreen40;
      case 'Cancelada':
        return AppColors.dangerSurface;
      case 'Reagendada':
        return AppColors.overlayBlue50;
      default:
        return AppColors.secondaryButtonSurface;
    }
  }

  Color get _statusForeground {
    switch (status) {
      case 'Cancelada':
        return AppColors.danger;
      case 'Completada':
        return AppColors.buttonLabelDark;
      default:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowMenuCard,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              time,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _statusBackground,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                color: _statusForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 8),
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
                              professional.isEmpty
                                  ? 'Sin profesional'
                                  : professional,
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
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 5, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
