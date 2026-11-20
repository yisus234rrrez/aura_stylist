import 'package:flutter/material.dart';

import '../../models/comisiones/comision.dart';
import '../../models/liquidaciones/liquidacion.dart';
import '../../routes/app_route_args.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_admin_top_bar.dart';
import '../../widgets/app_pickers.dart';




class CommissionListScreen extends StatefulWidget {
  const CommissionListScreen({
    super.key,
    this.filtered = false,
    this.liquidationId = 0,
  });

  final bool filtered;
  final int liquidationId;

  @override
  State<CommissionListScreen> createState() => _CommissionListScreenState();
}

class _CommissionListScreenState extends State<CommissionListScreen> {
  late String _professional;
  int _tabIndex = 1;
  int _selectedLiquidationId = 0;
  String _closureRange = '';
  List<Comision> _comisiones = <Comision>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _professional =
        widget.filtered ? 'Laura G.' : 'Todos los profesionales';
    _loadComisiones();
  }

  Future<void> _loadComisiones() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final closuresResponse = await AuraApi.liquidaciones.list();
      if (!mounted) return;
      if (!closuresResponse.isSuccess) {
        setState(() {
          _error =
              closuresResponse.message ?? 'No se pudieron cargar los cierres.';
          _loading = false;
        });
        return;
      }
      final List<Liquidacion> closures =
          closuresResponse.data ?? <Liquidacion>[];
      final Liquidacion? closure = widget.liquidationId > 0
          ? _findClosure(closures, widget.liquidationId)
          : (closures.isEmpty
                ? null
                : closures.reduce((a, b) => a.id >= b.id ? a : b));
      if (closure == null) {
        setState(() {
          _selectedLiquidationId = 0;
          _closureRange = '';
          _comisiones = <Comision>[];
          _loading = false;
        });
        return;
      }
      final response = await AuraApi.comisiones.list(
        liquidacionComisionId: closure.id,
      );
      if (!mounted) return;
      if (response.isSuccess) {
        setState(() {
          _selectedLiquidationId = closure.id;
          _closureRange = '${closure.fechaInicio} – ${closure.fechaFin}';
          _comisiones = response.data ?? <Comision>[];
          _loading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'No se pudieron cargar las comisiones.';
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

  Liquidacion? _findClosure(List<Liquidacion> closures, int id) {
    for (final Liquidacion closure in closures) {
      if (closure.id == id) return closure;
    }
    return null;
  }

  List<
    ({
      int id,
      int liquidacionId,
      String initials,
      String name,
      String specialty,
      String services,
      String amount,
      String pct,
    })
  >
  get _items {
    return _comisiones.map((Comision item) {
      final String name = item.profesionalNombre.isEmpty
          ? 'Profesional ${item.profesionalId}'
          : item.profesionalNombre;
      final List<String> parts = name.split(' ');
      final String initials = parts
          .where((String part) => part.isNotEmpty)
          .take(2)
          .map((String part) => part[0])
          .join()
          .toUpperCase();
      return (
        id: item.id,
        liquidacionId: item.liquidacionComisionId,
        initials: initials,
        name: name,
        specialty: item.estado.isEmpty ? 'Comisión' : item.estado,
        services: '${item.servicios} servicios',
        amount: '\$${item.total.toStringAsFixed(0)}',
        pct: '${item.porcentaje.toStringAsFixed(0)}%',
      );
    }).toList();
  }

  List<
    ({
      int id,
      int liquidacionId,
      String initials,
      String name,
      String specialty,
      String services,
      String amount,
      String pct,
    })
  >
  get _filteredItems {
    if (_professional == 'Todos los profesionales') return _items;
    return _items
        .where((item) => item.name == _professional)
        .toList();
  }

  Future<void> _pickProfessional() async {
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Profesional',
      options: <String>[
        'Todos los profesionales',
        ..._items.map((item) => item.name).toSet(),
      ],
      selected: _professional,
    );
    if (picked != null) setState(() => _professional = picked);
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    final num total = _comisiones.fold<num>(
      0,
      (num sum, Comision item) => sum + item.total,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppAdminTopBar(
            title: widget.filtered ? 'Comisiones · Filtradas' : 'Comisiones',
            section: 'Liquidación por profesional',
            onBack: () => Navigator.of(context).maybePop(),
          ),
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
                              _closureRange.isEmpty
                                  ? 'SIN CIERRE SELECCIONADO'
                                  : 'CIERRE · $_closureRange',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                              _selectedLiquidationId == 0
                                  ? 'Sin liquidación'
                                  : 'Liquidación #$_selectedLiquidationId',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.closures),
                          child: Text(
                            'Cambiar cierre',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.overlayGreen40,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          _selectedLiquidationId == 0
                              ? 'Sin cierre'
                              : 'Liquidada',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: AppColors.buttonLabelDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.controlPanel,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL A LIQUIDAR',
                                style: TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 0.4,
                                  color: AppColors.infoPill,
                                ),
                              ),
                              Text(
                                '\$${total.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontFamily: AppFonts.heading,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 28,
                                  height: 1.1,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'COP',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: AppColors.infoPill,
                              ),
                            ),
                            Text(
                                _selectedLiquidationId == 0
                                    ? 'Sin cierre'
                                    : 'Liquidada',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                color: AppColors.infoPill,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.filtered
                        ? 'PROFESIONAL FILTRADO'
                        : 'PROFESIONALES',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      height: 14 / 11,
                      letterSpacing: 0.55,
                      color: AppColors.textSecondaryFaint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickProfessional,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
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
                              _professional,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.expand_more,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
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
                          onPressed: _loadComisiones,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  else if (items.isEmpty)
                    Text(
                      _comisiones.isEmpty
                          ? 'No hay comisiones registradas.'
                          : 'No hay comisiones para el profesional seleccionado.',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        color: AppColors.textSecondaryMuted,
                      ),
                    ),
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _CommissionRow(item: items[i]),
                  ],
                ],
              ),
            ),
          ),
          _BottomTabs(
            selectedIndex: _tabIndex,
            onSelected: (int index) => setState(() => _tabIndex = index),
          ),
        ],
      ),
    );
  }
}

class _CommissionRow extends StatelessWidget {
  const _CommissionRow({required this.item});

  final ({
    int id,
    int liquidacionId,
    String initials,
    String name,
    String specialty,
    String services,
    String amount,
    String pct,
  })
  item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.commissionDetail,
        arguments: CommissionRouteArgs(
          id: item.id,
          liquidacionId: item.liquidacionId,
          professionalName: item.name,
          total: double.tryParse(
                item.amount.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0,
          percentage: double.tryParse(
                item.pct.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0,
        ),
      ),
      child: Container(
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
              item.initials,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 13,
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
                  item.name,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${item.specialty} · ${item.services}',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amount,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                item.pct,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: AppColors.accentDark,
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.commissionDetail,
                  arguments: CommissionRouteArgs(
                    id: item.id,
                    liquidacionId: item.liquidacionId,
                    professionalName: item.name,
                    total: double.tryParse(
                          item.amount.replaceAll(RegExp(r'[^0-9]'), ''),
                        ) ??
                        0,
                    percentage: double.tryParse(
                          item.pct.replaceAll(RegExp(r'[^0-9]'), ''),
                        ) ??
                        0,
                  ),
                ),
                child: Text(
                  'Ver detalle ›',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: AppColors.textPrimary,
                  ),
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

class _BottomTabs extends StatelessWidget {
  const _BottomTabs({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.95),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              _tab('Resumen', 0),
              _tab('Por profesional', 1),
              _tab('Historial', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, int index) {
    final bool active = index == selectedIndex;
    return Expanded(
      child: InkWell(
        onTap: () => onSelected(index),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: active
                  ? AppColors.textPrimary
                  : AppColors.textSecondaryMuted,
              decoration: active ? TextDecoration.underline : null,
              decorationColor: AppColors.textPrimary,
              decorationThickness: 2,
            ),
          ),
        ),
      ),
    );
  }
}
