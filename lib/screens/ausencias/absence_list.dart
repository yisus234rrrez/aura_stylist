import 'package:flutter/material.dart';

import '../../models/eventualidades/eventualidad.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_admin_top_bar.dart';
import '../../widgets/app_options_sheet.dart';
import '../../widgets/app_pickers.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_success_toast.dart';




class AbsenceListScreen extends StatefulWidget {
  const AbsenceListScreen({super.key});

  @override
  State<AbsenceListScreen> createState() => _AbsenceListScreenState();
}

class _AbsenceListScreenState extends State<AbsenceListScreen> {
  String _filter = 'Todos';
  List<Eventualidad> _eventualidades = <Eventualidad>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEventualidades();
  }

  Future<void> _loadEventualidades() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await AuraApi.eventualidades.list();
      if (!mounted) return;
      if (response.isSuccess) {
        setState(() {
          _eventualidades = response.data ?? <Eventualidad>[];
          _loading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'No se pudieron cargar las inasistencias.';
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

  List<Eventualidad> get _filteredItems {
    return _eventualidades.where((Eventualidad item) {
      if (_filter == 'Médicas') return item.motivo == 0;
      if (_filter == 'Permisos') return item.motivo != 0;
      return true;
    }).toList();
  }

  Future<void> _pickFilter() async {
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Filtrar inasistencias',
      options: const <String>['Todos', 'Médicas', 'Permisos'],
      selected: _filter,
    );
    if (picked != null) setState(() => _filter = picked);
  }

  @override
  Widget build(BuildContext context) {
    final List<Eventualidad> items = _filteredItems;
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
                  const AppSuccessToast(
                    title: 'Inasistencia sincronizada',
                    message:
                        'La agenda técnica fue bloqueada automáticamente y se '
                        'notificó a recepción para reprogramar turnos.',
                  ),
                  Row(
                    children: [
                      Text(
                        'GESTIÓN DE STAFF',
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
                        '3 ausencias activas',
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
                  const SizedBox(height: 4),
                  Text(
                    'Inasistencias y Permisos',
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
                    'Registro de ausencias justificadas y bloqueo preventivo '
                    'de agenda del equipo técnico.',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 18 / 13,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppPrimaryButton(
                    label: 'Registrar inasistencia',
                    leadingIcon: Icons.add,
                    labelColor: AppColors.buttonLabelDark,
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.registerAbsence),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: 'CITAS BLOQUEADAS',
                          value: '14',
                          highlight: 'Esta semana',
                          description:
                              '8 ya reorganizadas o citas existentes.',
                          icon: Icons.event_busy_outlined,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          label: 'DÍAS JUSTIFICADOS',
                          value: '7',
                          highlight: '100% amparados',
                          description: 'Con soporte legal anexo en nómina.',
                          icon: Icons.verified_user_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Historial y Registro Activo',
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 24 / 16,
                          letterSpacing: -0.4,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          '3 registros',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            height: 14 / 10,
                            color: AppColors.background,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: _pickFilter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Text(
                            _filter == 'Todos' ? 'Filtrar' : _filter,
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              height: 14 / 11,
                              color: AppColors.textPrimary,
                            ),
                          ),
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
                          onPressed: _loadEventualidades,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  else if (items.isEmpty)
                    Text(
                      _eventualidades.isEmpty
                          ? 'No hay inasistencias registradas.'
                          : 'No hay inasistencias para el filtro seleccionado.',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        color: AppColors.textSecondaryMuted,
                      ),
                    )
                  else
                    for (final Eventualidad item in items) ...[
                      _AbsenceCard(item: item),
                      const SizedBox(height: 12),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.highlight,
    required this.description,
    required this.icon,
  });

  final String label;
  final String value;
  final String highlight;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
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
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    height: 13 / 9,
                    letterSpacing: 0.4,
                    color: AppColors.textSecondaryFaint,
                  ),
                ),
              ),
              const Spacer(),
              Icon(icon, size: 14, color: AppColors.textPrimary),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppFonts.heading,
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  height: 1,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  highlight,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 14 / 10,
                    color: AppColors.accentDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
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
    );
  }
}

class _AbsenceCard extends StatelessWidget {
  const _AbsenceCard({required this.item});

  final Eventualidad item;

  String get _initials {
    final List<String> parts = item.profesionalNombre.split(' ');
    return parts
        .where((String part) => part.isNotEmpty)
        .take(2)
        .map((String part) => part[0])
        .join()
        .toUpperCase();
  }

  String get _name => item.profesionalNombre.isEmpty
      ? 'Profesional ${item.profesionalId}'
      : item.profesionalNombre;

  String get _range {
    final String start = item.fechaInicio.split('T').first;
    final String end = item.fechaFin.split('T').first;
    if (start.isEmpty && end.isEmpty) return 'Sin fechas';
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
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
                  _initials.isEmpty ? 'PR' : _initials,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
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
                      _name,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 20 / 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      item.motivoTexto,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.dangerSurface,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  item.motivoTexto,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    height: 14 / 11,
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                _range,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 18 / 13,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                'Registrada',
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceOverlay,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.link,
                      size: 14,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '6 citas programadas bloqueadas',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 16 / 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'REPROGRAMADAS',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        height: 14 / 10,
                        letterSpacing: 0.4,
                        color: AppColors.accentDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.observacion.isEmpty
                      ? 'Sin observación adicional.'
                      : item.observacion,
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _showPdfPreview(context),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryButtonSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 15,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Ver Incapacidad (PDF)',
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
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => showAppOptionsSheet(
                  context,
                  options: [
                    (
                      icon: Icons.edit_outlined,
                      label: 'Editar registro',
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.registerAbsence),
                    ),
                    (
                      icon: Icons.notifications_outlined,
                      label: 'Reenviar notificación',
                      onTap: () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Notificación reenviada a recepción.',
                              ),
                            ),
                          );
                      },
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () async {
                  await showAppConfirmDialog(
                    context,
                    title: 'Eliminar registro',
                    message:
                        '¿Seguro que deseas eliminar esta inasistencia del '
                        'historial?',
                    confirmLabel: 'Eliminar',
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.danger,
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

void _showPdfPreview(BuildContext context) {
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
                'Incapacidad médica',
                style: TextStyle(
                  fontFamily: AppFonts.heading,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Soporte PDF · Reposo por otitis aguda\n'
                'Validada y anexada a nómina.',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  height: 19 / 13,
                  color: AppColors.textBody,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Vista previa no disponible sin conexión al gestor documental.',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 11,
                  color: AppColors.textSecondaryMuted,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
