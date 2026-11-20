import 'package:flutter/material.dart';

import '../../models/liquidaciones/liquidacion.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_pickers.dart';




class ClosureListScreen extends StatefulWidget {
  const ClosureListScreen({super.key});

  @override
  State<ClosureListScreen> createState() => _ClosureListScreenState();
}

class _ClosureListScreenState extends State<ClosureListScreen> {
  String _statusFilter = 'Todos los cierres';
  String _yearFilter = '2026';
  int _monthIndex = 1;
  List<Liquidacion> _liquidaciones = <Liquidacion>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLiquidaciones();
  }

  Future<void> _loadLiquidaciones() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await AuraApi.liquidaciones.list();
      if (!mounted) return;
      if (response.isSuccess) {
        setState(() {
          _liquidaciones = response.data ?? <Liquidacion>[];
          _loading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'No se pudieron cargar los cierres.';
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

  List<Liquidacion> get _filteredLiquidaciones {
    if (_statusFilter == 'Preliminar') return <Liquidacion>[];
    final int month = _chipMonth(_monthIndex);
    final int? year = int.tryParse(_yearFilter);
    return _liquidaciones.where((Liquidacion item) {
      final DateTime? date = DateTime.tryParse(item.fechaFin);
      if (date == null) return true;
      return date.month == month && (year == null || date.year == year);
    }).toList();
  }

  String _money(double value) => '\$${value.toStringAsFixed(0)}';

  Future<void> _pickStatus() async {
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Filtrar cierres',
      options: const <String>[
        'Todos los cierres',
        'Preliminar',
        'Cerrados',
      ],
      selected: _statusFilter,
    );
    if (picked != null) setState(() => _statusFilter = picked);
  }

  Future<void> _pickYear() async {
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Año',
      options: const <String>['2026', '2025', '2024'],
      selected: _yearFilter,
    );
    if (picked != null) setState(() => _yearFilter = picked);
  }

  @override
  Widget build(BuildContext context) {
    final List<Liquidacion> items = _filteredLiquidaciones;
    final bool hasResults = items.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          const AppHeader(section: 'Cierres'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'CONTABILIDAD · AURA STUDIO',
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
                    'Cierres de Periodo',
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      height: 32 / 24,
                      letterSpacing: -0.5,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    'Control de corte contable, ingresos y consolidación '
                    'operativa.',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 18 / 13,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.newClosure);
                        if (!mounted) return;
                        _loadLiquidaciones();
                      },
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 16,
                              color: AppColors.buttonLabelDark,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Nuevo cierre de periodo',
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
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterBox(
                          label: 'Año: $_yearFilter',
                          onTap: _pickYear,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterBox(
                          label: _statusFilter,
                          onTap: _pickStatus,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MonthChips(
                    selectedIndex: _monthIndex,
                    onSelected: (int index) =>
                        setState(() => _monthIndex = index),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'HISTORIAL RECIENTE (3)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                      const Spacer(),
                      Flexible(
                        child: Text(
                          'Filtrado por $_yearFilter',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            color: AppColors.textSecondaryMuted,
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
                          onPressed: _loadLiquidaciones,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  else if (!hasResults)
                    Text(
                      'No hay cierres que coincidan con el filtro.',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        color: AppColors.textSecondaryMuted,
                      ),
                    )
                  else
                    for (int i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      _ClosureCard(
                        id: items[i].id,
                        code: 'LIE-${items[i].id}',
                        range: '${items[i].fechaInicio} – ${items[i].fechaFin}',
                        status: items[i].totalFacturado > 0
                            ? 'Cerrado'
                            : 'Sin movimientos',
                        total: _money(items[i].totalFacturado),
                        services:
                            'Profesionales: ${_money(items[i].subtotalComisionProfesionales)}',
                        staff:
                            'Negocio: ${_money(items[i].subtotalComisionNegocio)}',
                        closed: items[i].totalFacturado > 0,
                      ),
                    ],
                ],
              ),
            ),
          ),
          const AppBottomNav(currentIndex: 3),
        ],
      ),
    );
  }
}

class _FilterBox extends StatelessWidget {
  const _FilterBox({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
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
            const Icon(Icons.expand_more, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}


int _chipMonth(int index) {
  final int current = DateTime.now().month;
  switch (index) {
    case 0:
      return current == 1 ? 12 : current - 1;
    case 2:
      return current == 12 ? 1 : current + 1;
    default:
      return current;
  }
}

class _MonthChips extends StatelessWidget {
  const _MonthChips({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

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

  @override
  Widget build(BuildContext context) {
    final List<String> months = <String>[
      _monthNames[_chipMonth(0) - 1],
      '${_monthNames[_chipMonth(1) - 1]} (Actual)',
      _monthNames[_chipMonth(2) - 1],
    ];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int i) {
          final bool selected = selectedIndex == i;
          return InkWell(
            borderRadius: BorderRadius.circular(9999),
            onTap: () => onSelected(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.secondary
                    : AppColors.secondaryButtonSurface,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                months[i],
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: selected ? AppColors.white : AppColors.textPrimary80,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClosureCard extends StatelessWidget {
  const _ClosureCard({
    required this.id,
    required this.code,
    required this.range,
    required this.status,
    required this.total,
    required this.services,
    required this.staff,
    this.closed = false,
  });

  final int id;
  final String code;
  final String range;
  final String status;
  final String total;
  final String services;
  final String staff;
  final bool closed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
                      Flexible(
                        child: Text(
                          code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: AppColors.textSecondaryMuted,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: closed
                                ? AppColors.overlayGreen40
                                : AppColors.overlayBlue50,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: closed
                                  ? AppColors.buttonLabelDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    range,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      height: 20 / 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Recaudado',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                  Text(
                    total,
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      height: 1,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.content_cut_outlined,
                          label: 'Servicios',
                          value: services,
                        ),
                      ),
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.groups_outlined,
                          label: 'Personal',
                          value: staff,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: AppColors.secondaryButtonSurface,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.closureDetail,
                        arguments: id,
                      ),
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                          'Consultar detalle  ›',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 5,
                color: closed ? AppColors.accentDark : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: AppColors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                  color: AppColors.textSecondaryMuted,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
