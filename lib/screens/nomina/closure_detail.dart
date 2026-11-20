import 'package:flutter/material.dart';

import '../../models/comisiones/comision.dart';
import '../../models/liquidaciones/liquidacion.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_admin_top_bar.dart';
import '../../widgets/app_form_actions.dart';
import '../../widgets/app_success_toast.dart';




class ClosureDetailScreen extends StatefulWidget {
  const ClosureDetailScreen({super.key, this.id = 0, this.showToast = false});

  final int id;
  final bool showToast;

  @override
  State<ClosureDetailScreen> createState() => _ClosureDetailScreenState();
}

class _ClosureDetailScreenState extends State<ClosureDetailScreen> {
  Liquidacion? _liquidacion;
  int _servicios = 0;
  int _equipo = 0;
  bool _loadingClosure = true;
  bool _loadingComisiones = false;
  String? _closureError;
  String? _commissionError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loadingClosure = true;
      _loadingComisiones = false;
      _closureError = null;
      _commissionError = null;
      _liquidacion = null;
      _servicios = 0;
      _equipo = 0;
    });
    try {
      final response = await AuraApi.liquidaciones.list();
      if (!mounted) return;
      if (!response.isSuccess) {
        setState(() {
          _closureError =
              response.message ?? 'No se pudieron cargar los cierres.';
          _loadingClosure = false;
        });
        return;
      }
      final List<Liquidacion> items = response.data ?? <Liquidacion>[];
      Liquidacion? found;
      if (widget.id > 0) {
        for (final Liquidacion item in items) {
          if (item.id == widget.id) {
            found = item;
            break;
          }
        }
      } else if (items.isNotEmpty) {

        found = items.reduce(
          (Liquidacion a, Liquidacion b) => a.id >= b.id ? a : b,
        );
      }
      if (found == null) {
        setState(() {
          _loadingClosure = false;
          _closureError = items.isEmpty
              ? 'No hay liquidaciones registradas.'
              : 'No se encontró la liquidación solicitada.';
        });
        return;
      }
      setState(() {
        _liquidacion = found;
        _loadingClosure = false;
      });
      await _loadComisiones(found.id);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _closureError = error.message;
        _loadingClosure = false;
      });
    }
  }

  Future<void> _loadComisiones(int liquidacionId) async {
    setState(() {
      _loadingComisiones = true;
      _commissionError = null;
      _servicios = 0;
      _equipo = 0;
    });
    try {
      final response = await AuraApi.comisiones.list(
        liquidacionComisionId: liquidacionId,
      );
      if (!mounted) return;
      if (!response.isSuccess) {
        setState(() {
          _commissionError =
              response.message ?? 'No se pudieron cargar las comisiones.';
          _loadingComisiones = false;
        });
        return;
      }
      final List<Comision> items = response.data ?? <Comision>[];
      setState(() {
        _servicios = items.fold<int>(
          0,
          (int sum, Comision item) => sum + item.servicios,
        );
        _equipo = items.length;
        _loadingComisiones = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _commissionError = error.message;
        _loadingComisiones = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Liquidacion? item = _liquidacion;
    final String code = item == null ? 'CIE' : 'LIE-${item.id}';
    final String range = item == null
        ? 'Sin liquidación registrada'
        : '${item.fechaInicio} - ${item.fechaFin}';
    final String total = item == null
        ? '—'
        : '\$${item.totalFacturado.toStringAsFixed(0)} COP';

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
                  if (widget.showToast)
                    const AppSuccessToast(
                      title: 'Cierre creado correctamente',
                      message:
                          'El periodo quedó cerrado y listo para liquidar '
                          'comisiones.',
                    ),
                  Text(
                    'CIERRE DE PERÍODO',
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
                    'Detalle del cierre',
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
                    'Consolidado del periodo ya cerrado: totales, medios de '
                    'pago y equipo.',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 18 / 13,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loadingClosure)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (_closureError != null)
                    _LoadErrorCard(
                      message: _closureError!,
                      onRetry: _load,
                    ),
                  if (!_loadingClosure && _closureError == null && item != null)
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _IdentifierRow(code: code),
                          const SizedBox(height: 10),
                          _RangeRow(range: range),
                        ],
                      ),
                    ),
                  if (!_loadingClosure && _closureError == null && item != null)
                    ...[
                      const SizedBox(height: 16),
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL FACTURADO BRUTO',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 0.4,
                                color: AppColors.textSecondaryFaint,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              total,
                              style: TextStyle(
                                fontFamily: AppFonts.heading,
                                fontWeight: FontWeight.w700,
                                fontSize: 26,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total facturado en el período',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: AppColors.textSecondaryMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.content_cut_outlined,
                              value: _loadingComisiones
                                  ? '…'
                                  : _commissionError == null
                                  ? '$_servicios'
                                  : '—',
                              label: 'Servicios liquidados',
                              title: 'Servicios',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.groups_outlined,
                              value: _loadingComisiones
                                  ? '…'
                                  : _commissionError == null
                                  ? '$_equipo'
                                  : '—',
                              label: 'Profesionales con comisión',
                              title: 'Equipo',
                            ),
                          ),
                        ],
                      ),
                      if (_commissionError != null) ...[
                        const SizedBox(height: 12),
                        _LoadErrorCard(
                          message: _commissionError!,
                          onRetry: () => _loadComisiones(item.id),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _PaymentBreakdown(
                        negocio: item.subtotalComisionNegocio,
                        profesionales: item.subtotalComisionProfesionales,
                      ),
                      if (!_loadingComisiones && _commissionError == null) ...[
                        const SizedBox(height: 16),
                        _LiquidationRow(
                          count: _equipo,
                          liquidationId: item.id,
                        ),
                      ],
                    ],
                ],
              ),
            ),
          ),
          AppFormActions(
            primaryLabel: 'Ver comisiones',
            primaryIcon: Icons.arrow_forward,
            cancelLabel: 'Volver a cierres',
            onCancel: () => Navigator.of(context).maybePop(),
            onPrimary: item == null
                ? null
                : () => Navigator.of(context).pushNamed(
                    AppRoutes.commissions,
                    arguments: item.id,
                  ),
          ),
        ],
      ),
    );
  }
}

class _IdentifierRow extends StatelessWidget {
  const _IdentifierRow({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Identificador Oficial',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: AppColors.textSecondaryMuted,
                ),
              ),
              Text(
                code,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.overlayGreen40,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 12,
                color: AppColors.buttonLabelDark,
              ),
              const SizedBox(width: 4),
              Text(
                'AUDITADO',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  color: AppColors.buttonLabelDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RangeRow extends StatelessWidget {
  const _RangeRow({required this.range});

  final String range;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceOverlay,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              range,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.title,
  });

  final IconData icon;
  final String value;
  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.heading,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              height: 1,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w400,
              fontSize: 11,
              color: AppColors.textSecondaryMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentBreakdown extends StatelessWidget {
  const _PaymentBreakdown({required this.negocio, required this.profesionales});

  final double negocio;
  final double profesionales;

  @override
  Widget build(BuildContext context) {
    final double total = negocio + profesionales;
    final int negocioPct = total <= 0 ? 0 : (negocio / total * 100).round();
    final int profesionalesPct = total <= 0 ? 0 : 100 - negocioPct;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Reparto del período',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                total <= 0 ? 'Sin liquidar' : '100% conciliado',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: AppColors.accentDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Row(
              children: [
                Expanded(
                  flex: negocioPct == 0 && profesionalesPct == 0
                      ? 1
                      : negocioPct,
                  child: Container(height: 8, color: AppColors.secondary),
                ),
                Expanded(
                  flex: negocioPct == 0 && profesionalesPct == 0
                      ? 1
                      : profesionalesPct,
                  child: Container(height: 8, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _payRow(
            'Comisión del negocio',
            'Lo que queda para el salón',
            '\$${negocio.toStringAsFixed(0)} COP',
            '$negocioPct%',
          ),
          const SizedBox(height: 10),
          _payRow(
            'Comisión profesionales',
            'Pago al equipo',
            '\$${profesionales.toStringAsFixed(0)} COP',
            '$profesionalesPct%',
          ),
        ],
      ),
    );
  }
  Widget _payRow(
    String title,
    String subtitle,
    String value,
    String pct,
  ) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 8, color: AppColors.primary),
        const SizedBox(width: 8),
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
                  color: AppColors.textDark,
                ),
              ),
              Text(
                subtitle,
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
              value,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              pct,
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
    );
  }
}

class _LiquidationRow extends StatelessWidget {
  const _LiquidationRow({required this.count, required this.liquidationId});

  final int count;
  final int liquidationId;

  @override
  Widget build(BuildContext context) {
    return _Card(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.commissions,
        arguments: liquidationId,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.secondaryButtonSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.groups_outlined,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              count == 1
                  ? '1 profesional con comisión'
                  : '$count profesionales con comisión',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _LoadErrorCard extends StatelessWidget {
  const _LoadErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 13,
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

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
      child: onTap == null
          ? child
          : InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: child,
            ),
    );
  }
}
