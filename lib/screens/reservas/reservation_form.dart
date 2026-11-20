import 'package:flutter/material.dart';

import '../../models/clientes/cliente.dart';
import '../../models/especialidades/especialidad.dart';
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
import '../../widgets/app_pickers.dart';
import '../../widgets/app_select_field.dart';




class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  _Client? _client;
  String? _specialty;
  int? _specialtyId;
  _Service? _service;
  _Professional? _professional;
  List<_Client> _clients = <_Client>[];
  List<_Service> _services = <_Service>[];
  List<_Professional> _professionals = <_Professional>[];
  List<Especialidad> _specialties = <Especialidad>[];
  bool _loading = true;
  String? _error;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  List<String> _slots = <String>[];
  String? _selectedSlot;
  bool _loadingSlots = false;
  String? _slotsError;

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
        AuraApi.clientes.list(),
        AuraApi.servicios.list(),
        AuraApi.profesionales.list(),
        AuraApi.especialidades.list(),
      ]);
      if (!mounted) return;
      final clientResponse = responses[0];
      final serviceResponse = responses[1];
      final professionalResponse = responses[2];
      final specialtyResponse = responses[3];
      setState(() {
        if (clientResponse.isSuccess) {
          _clients = (clientResponse.data as List<Cliente>? ?? <Cliente>[])
              .map(
                (Cliente item) => _Client(
                  id: item.id,
                  initials: item.iniciales,
                  name: item.nombreCompleto,
                  document: item.documento,
                  phone: item.celular,
                  vip: false,
                ),
              )
              .toList();
        }
        if (serviceResponse.isSuccess) {
          _services = (serviceResponse.data as List<Servicio>? ?? <Servicio>[])
              .map(
                (Servicio item) => _Service(
                  id: item.id,
                  name: item.nombre,
                  description: item.descripcion,
                  price: item.precioTexto,
                  duration: '${item.duracion} min',
                  specialtyId: item.especialidadId,
                ),
              )
              .toList();
        }
        if (professionalResponse.isSuccess) {
          _professionals = (professionalResponse.data
                      as List<Profesional>? ??
                  <Profesional>[])
              .map(
                (Profesional item) => _Professional(
                  id: item.id,
                  initials: item.iniciales,
                  name: item.nombreCompleto,
                  role: item.especialidad?.nombre ?? 'Profesional',
                  specialtyId: item.especialidadId,
                ),
              )
              .toList();
        }
        if (specialtyResponse.isSuccess) {
          _specialties = specialtyResponse.data as List<Especialidad>? ??
              <Especialidad>[];
        }
        _service = _eligibleServices.isEmpty ? null : _eligibleServices.first;
        _professional = _eligibleProfessionals.isEmpty
            ? null
            : _eligibleProfessionals.first;
        _loading = false;
      });
      if (_service != null) _loadSlots();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<_Client> get _filteredClients {
    final String query = _query.trim().toLowerCase();
    if (query.isEmpty) return const <_Client>[];
    return _clients
        .where(
          (_Client client) =>
              client.name.toLowerCase().contains(query) ||
              client.document.toLowerCase().contains(query) ||
              client.phone.toLowerCase().contains(query),
        )
        .toList();
  }

  List<_Service> get _eligibleServices {
    if (_specialtyId == null) return _services;
    return _services
        .where((_Service service) => service.specialtyId == _specialtyId)
        .toList();
  }

  List<_Professional> get _eligibleProfessionals {
    final int? specialtyId =
        _service != null && _service!.specialtyId != 0
            ? _service!.specialtyId
            : _specialtyId;
    if (specialtyId == null || specialtyId == 0) return _professionals;
    return _professionals
        .where((_Professional professional) =>
            professional.specialtyId == specialtyId)
        .toList();
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectClient(_Client client) {
    setState(() {
      _client = client;
      _query = '';
      _searchController.text = client.name;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _pickSpecialty() async {
    if (_loading) {
      _showInfo('Cargando especialidades...');
      return;
    }
    if (_specialties.isEmpty) {
      _showInfo('No hay especialidades disponibles.');
      return;
    }
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Especialidad',
      options: _specialties.map((Especialidad item) => item.nombre).toList(),
      selected: _specialty,
    );
    if (picked == null) return;
    final Especialidad item = _specialties.firstWhere(
      (Especialidad value) => value.nombre == picked,
    );
    setState(() {
      _specialty = item.nombre;
      _specialtyId = item.id;
      _service = _eligibleServices.isEmpty ? null : _eligibleServices.first;
      _professional = _eligibleProfessionals.isEmpty
          ? null
          : _eligibleProfessionals.first;
      _selectedSlot = null;
    });
    if (_service != null) _loadSlots();
  }

  Future<void> _pickService() async {
    if (_loading) {
      _showInfo('Cargando servicios...');
      return;
    }
    final List<_Service> options = _eligibleServices;
    if (options.isEmpty) {
      _showInfo(
        _specialtyId == null
            ? 'No hay servicios disponibles.'
            : 'No hay servicios para esa especialidad.',
      );
      return;
    }
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Servicio',
      options: options.map((_Service service) => service.name).toList(),
      selected: _service?.name,
    );
    if (picked == null) return;
    setState(() {
      _service = options.firstWhere((_Service service) => service.name == picked);
      _professional = _eligibleProfessionals.isEmpty
          ? null
          : _eligibleProfessionals.first;
      _selectedSlot = null;
    });
    _loadSlots();
  }

  Future<void> _pickProfessional() async {
    if (_loading) {
      _showInfo('Cargando profesionales...');
      return;
    }
    final List<_Professional> options = _eligibleProfessionals;
    if (options.isEmpty) {
      _showInfo('No hay profesionales para esta especialidad.');
      return;
    }
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Profesional',
      options: options
          .map((_Professional professional) => professional.name)
          .toList(),
      selected: _professional?.name,
    );
    if (picked == null) return;
    setState(() {
      _professional = options.firstWhere(
        (_Professional professional) => professional.name == picked,
      );
      _selectedSlot = null;
    });
    _loadSlots();
  }

  String get _apiDate {
    final String month = _date.month.toString().padLeft(2, '0');
    final String day = _date.day.toString().padLeft(2, '0');
    return '${_date.year}-$month-$day';
  }

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

  Future<void> _loadSlots() async {
    if (_service == null) {
      setState(() {
        _slots = <String>[];
        _slotsError = 'Selecciona un servicio para consultar horarios.';
        _loadingSlots = false;
      });
      return;
    }
    if (_service!.id <= 0) {
      setState(() {
        _slots = <String>[];
        _slotsError = 'El servicio seleccionado no tiene un ID válido.';
        _loadingSlots = false;
      });
      return;
    }
    setState(() {
      _loadingSlots = true;
      _slots = <String>[];
      _slotsError = null;
      _selectedSlot = null;
    });
    try {
      final int? professionalId =
          (_professional?.id ?? 0) > 0 ? _professional!.id : null;
      final response = await AuraApi.agenda.availableSlots(
        fecha: _apiDate,
        servicioId: _service!.id,
        profesionalId: professionalId,
      );
      if (!mounted) return;
      if (!response.isSuccess) {
        setState(() {
          _slots = <String>[];
          _slotsError =
              response.message ?? 'No se pudieron consultar los horarios.';
          _loadingSlots = false;
        });
        _showInfo(_slotsError!);
        return;
      }
      final List<String> slots = response.data ?? <String>[];
      setState(() {
        _slots = slots;
        _slotsError = slots.isEmpty
            ? 'No hay horarios para ${formatAppDate(_date)} con '
                '${_service!.name}.'
            : null;
        _loadingSlots = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _slotsError = e.message;
        _loadingSlots = false;
      });
      _showInfo(e.message);
    }
  }

  Future<void> _findNextAvailableDate() async {
    if (_service == null) {
      _showInfo('Selecciona un servicio primero.');
      return;
    }
    setState(() {
      _loadingSlots = true;
      _slotsError = null;
    });
    try {
      final int? professionalId =
          (_professional?.id ?? 0) > 0 ? _professional!.id : null;
      for (int i = 1; i <= 14; i++) {
        final DateTime candidate = DateTime.now().add(Duration(days: i));
        final String month = candidate.month.toString().padLeft(2, '0');
        final String day = candidate.day.toString().padLeft(2, '0');
        final String fecha = '${candidate.year}-$month-$day';
        final response = await AuraApi.agenda.availableSlots(
          fecha: fecha,
          servicioId: _service!.id,
          profesionalId: professionalId,
        );
        if (!mounted) return;
        final List<String> slots = response.data ?? <String>[];
        if (response.isSuccess && slots.isNotEmpty) {
          setState(() {
            _date = candidate;
            _slots = slots;
            _selectedSlot = null;
            _loadingSlots = false;
            _slotsError = null;
          });
          _showInfo('Horarios encontrados para ${formatAppDate(candidate)}.');
          return;
        }
      }
      if (!mounted) return;
      setState(() {
        _loadingSlots = false;
        _slotsError = 'No hay horarios en los próximos 14 días.';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingSlots = false;
        _slotsError = e.message;
      });
    }
  }

  static const List<String> _slotMonths = <String>[
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  static const List<String> _slotWeekdays = <String>[
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];


  static String _formatSlot(String raw) {
    final DateTime? date = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (date == null) return raw;
    final int hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final String minute = date.minute.toString().padLeft(2, '0');
    final String period = date.hour < 12 ? 'AM' : 'PM';
    return '${_slotWeekdays[date.weekday - 1]} ${date.day} de '
        '${_slotMonths[date.month - 1]} · '
        '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _pickSlot() async {
    if (_loadingSlots) return;
    if (_service == null) {
      _showInfo('Selecciona un servicio primero.');
      return;
    }
    if (_slots.isEmpty) {
      _showInfo(_slotsError ?? 'No hay horarios disponibles.');
      if (_slotsError != null) _loadSlots();
      return;
    }
    final Map<String, String> rawByLabel = <String, String>{};
    for (final String slot in _slots) {
      rawByLabel[_formatSlot(slot)] = slot;
    }
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Horario disponible',
      options: rawByLabel.keys.toList(),
      selected: _selectedSlot == null ? null : _formatSlot(_selectedSlot!),
    );
    if (picked != null) setState(() => _selectedSlot = rawByLabel[picked]);
  }

  void _continue() {
    if (_client == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Selecciona un cliente para continuar.')),
        );
      return;
    }
    if (_service == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Selecciona un servicio para continuar.')),
        );
      return;
    }
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Selecciona una fecha y hora.')),
        );
      return;
    }
    Navigator.of(context).pushNamed(
      AppRoutes.reservationConfirmation,
      arguments: ReservationRouteArgs(
        clienteId: _client!.id,
        servicioId: _service!.id,
        profesionalId: _professional?.id ?? 0,
        fechaHora: _selectedSlot!,
        clientName: _client!.name,
        clientDocument: _client!.document,
        clientInitials: _client!.initials,
        serviceName: _service!.name,
        professionalName: _professional?.name ?? 'Sin asignar',
        price: _service!.price,
        duration: _service!.duration,
        time: _selectedSlot!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          const AppAdminTopBar(title: 'Aura Stylist', section: ''),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'PASO 1 DE 2',
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
                        '50% completado',
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
                    'Nueva Reserva',
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
                    'Selección de cita y disponibilidad en tiempo real',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 18 / 13,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
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
                            onPressed: _loadData,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  _StepSection(
                    number: '1',
                    title: 'Cliente',
                    trailing: 'Registrar nuevo',
                    onTrailing: () =>
                        Navigator.of(context).pushNamed(AppRoutes.clientNew),
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocus,
                                  onChanged: (String value) => setState(() {
                                    _query = value;
                                    if (_client != null &&
                                        value.trim() != _client!.name) {
                                      _client = null;
                                    }
                                  }),
                                  style: TextStyle(
                                    fontFamily: AppFonts.body,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText:
                                        'Buscar cliente por documento, '
                                        'nombre o celular',
                                    hintStyle: TextStyle(
                                      fontFamily: AppFonts.body,
                                      fontSize: 13,
                                      color: AppColors.textPrimary40,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                InkWell(
                                  onTap: () => setState(() {
                                    _searchController.clear();
                                    _query = '';
                                    _client = null;
                                  }),
                                  customBorder: const CircleBorder(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_query.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _ClientResults(
                            clients: _filteredClients,
                            onSelected: _selectClient,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _ClientSelectedCard(
                          client: _client,
                          onTap: () {
                            if (_client == null) {
                              _searchFocus.requestFocus();
                              return;
                            }
                            setState(() => _client = null);
                            _searchController.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StepSection(
                    number: '2',
                    title: 'Especialidad y Servicio',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppSelectField(
                          label: 'Especialidad (Filtro opcional)',
                          placeholder: _specialty ?? 'Todas las especialidades',
                          valueColor: _specialty == null
                              ? null
                              : AppColors.textPrimary,
                          onTap: _pickSpecialty,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Servicio requerido',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                height: 14 / 11,
                                letterSpacing: 0.33,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              ' *',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: AppColors.danger,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _service?.duration ?? '',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                color: AppColors.textSecondaryMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _ServiceSelectedCard(
                          service: _service,
                          onTap: _pickService,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StepSection(
                    number: '3',
                    title: 'Profesional Asignado',
                    trailing: 'Opcional',
                    child: _ProfessionalSelectedCard(
                      professional: _professional,
                      onTap: _pickProfessional,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StepSection(
                    number: '4',
                    title: 'Fecha y Hora',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppSelectField(
                          label: 'Fecha',
                          placeholder: formatAppDate(_date),
                          valueColor: AppColors.textPrimary,
                          icon: Icons.calendar_today_outlined,
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 16),
                        AppSelectField(
                          label: 'Horario disponible',
                          required: true,
                          placeholder: _loadingSlots
                              ? 'Cargando horarios...'
                              : (_selectedSlot == null
                                    ? 'Selecciona un horario'
                                    : _formatSlot(_selectedSlot!)),
                          valueColor: _selectedSlot == null
                              ? null
                              : AppColors.textPrimary,
                          icon: Icons.schedule,
                          onTap: _loadingSlots ? null : _pickSlot,
                        ),
                        if (!_loadingSlots && _slots.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            _slotsError ??
                                'No hay horarios disponibles para esta fecha.',
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 12,
                              color: AppColors.textSecondaryMuted,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 4,
                              children: [
                                TextButton(
                                  onPressed: _loadSlots,
                                  child: const Text('Reintentar horarios'),
                                ),
                                TextButton(
                                  onPressed: _findNextAvailableDate,
                                  child: const Text('Buscar otro día'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppFormActions(
            primaryLabel: 'Continuar a Confirmación',
            primaryIcon: Icons.arrow_forward,
            onCancel: () => Navigator.of(context).maybePop(),
            onPrimary: _continue,
          ),
        ],
      ),
    );
  }
}

class _Client {
  const _Client({
    required this.id,
    required this.initials,
    required this.name,
    required this.document,
    required this.phone,
    required this.vip,
  });

  final int id;
  final String initials;
  final String name;
  final String document;
  final String phone;
  final bool vip;
}

class _Service {
  const _Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.specialtyId,
  });

  final int id;
  final String name;
  final String description;
  final String price;
  final String duration;
  final int specialtyId;
}

class _Professional {
  const _Professional({
    required this.id,
    required this.initials,
    required this.name,
    required this.role,
    required this.specialtyId,
  });

  final int id;
  final String initials;
  final String name;
  final String role;
  final int specialtyId;
}

class _ClientResults extends StatelessWidget {
  const _ClientResults({required this.clients, required this.onSelected});

  final List<_Client> clients;
  final ValueChanged<_Client> onSelected;

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceOverlay,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Sin resultados para la búsqueda.',
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 12,
            color: AppColors.textSecondaryMuted,
          ),
        ),
      );
    }
    return Container(
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
        children: [
          for (int i = 0; i < clients.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                color: AppColors.secondaryButtonSurface,
              ),
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondaryButtonSurface,
                  child: Text(
                    clients[i].initials,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                title: Text(
                  clients[i].name,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                ),
                subtitle: Text(
                  '${clients[i].document} · ${clients[i].phone}',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 11,
                    color: AppColors.textSecondaryMuted,
                  ),
                ),
                onTap: () => onSelected(clients[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepSection extends StatelessWidget {
  const _StepSection({
    required this.number,
    required this.title,
    required this.child,
    this.trailing,
    this.onTrailing,
  });

  final String number;
  final String title;
  final String? trailing;
  final VoidCallback? onTrailing;
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
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
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
              const Spacer(),
              if (trailing != null)
                InkWell(
                  onTap: onTrailing,
                  child: Text(
                    trailing!,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ClientSelectedCard extends StatelessWidget {
  const _ClientSelectedCard({required this.client, required this.onTap});

  final _Client? client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (client == null) {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceOverlay,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Ningún cliente seleccionado',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: AppColors.textSecondaryMuted,
            ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceOverlay,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.secondaryButtonSurface,
              shape: BoxShape.circle,
            ),
            child: Text(
              client!.initials,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        client!.name,
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
                    if (client!.vip) ...[
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
                          'VIP',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                            color: AppColors.buttonLabelDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${client!.document} · ${client!.phone}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    color: AppColors.textSecondaryMuted,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.close,
                size: 16,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceSelectedCard extends StatelessWidget {
  const _ServiceSelectedCard({required this.service, required this.onTap});

  final _Service? service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondaryButtonSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.content_cut_outlined,
              size: 18,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: service == null
                  ? Text(
                      'Selecciona un servicio',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.textSecondaryMuted,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service!.name,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            height: 20 / 14,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          service!.description,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                            height: 15 / 11,
                            color: AppColors.textSecondaryMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service!.price,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
            ),
            const Icon(
              Icons.edit_outlined,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalSelectedCard extends StatelessWidget {
  const _ProfessionalSelectedCard({
    required this.professional,
    required this.onTap,
  });

  final _Professional? professional;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceOverlay,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.secondaryButtonSurface,
                shape: BoxShape.circle,
              ),
              child: Text(
                professional?.initials ?? '?',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professional?.name ?? 'Sin profesional asignado',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 20 / 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    professional?.role ?? 'Toca para seleccionar',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              professional == null
                  ? Icons.expand_more
                  : Icons.check_circle,
              size: 20,
              color: professional == null
                  ? AppColors.textMuted
                  : AppColors.accentDark,
            ),
          ],
        ),
      ),
    );
  }
}
