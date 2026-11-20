import 'package:flutter/material.dart';

import '../../models/comisiones/comision.dart';
import '../../routes/app_route_args.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_admin_top_bar.dart';
import '../../widgets/app_primary_button.dart';




class CommissionDetailScreen extends StatefulWidget {
  const CommissionDetailScreen({
    super.key,
    this.initial = const CommissionRouteArgs(),
  });

  final CommissionRouteArgs initial;

  @override
  State<CommissionDetailScreen> createState() => _CommissionDetailScreenState();
}

class _CommissionDetailScreenState extends State<CommissionDetailScreen> {
  List<ComisionServicio> _rows = <ComisionServicio>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.initial.id <= 0) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await AuraApi.comisiones.servicios(widget.initial.id);
      if (!mounted) return;
      setState(() {
        _rows = response.data ?? <ComisionServicio>[];
        _error = response.isSuccess
            ? null
            : (response.message ?? 'No se pudo cargar la comisión.');
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  static String _money(num value) => '\$${value.toInt()}';

  static String _initials(String name) {
    final List<String> parts = name
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .take(2)
        .toList();
    return parts.map((String part) => part[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final CommissionRouteArgs initial = widget.initial;
    final String name = initial.professionalName.isEmpty
        ? 'Profesional ${initial.id}'
        : initial.professionalName;
    final num base = _rows.fold<num>(
      0,
      (num sum, ComisionServicio item) => sum + item.precio,
    );
    final num total = initial.total > 0
        ? initial.total
        : _rows.fold<num>(0, (num sum, ComisionServicio item) => sum + item.monto);
    final bool liquidada = initial.liquidacionId > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppAdminTopBar(
            title: 'Detalle de comisión',
            section: initial.id > 0 ? 'Comisión #${initial.id}' : 'Comisión',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.controlPanel,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                _initials(name),
                                style: TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  height: 1,
                                  color: AppColors.controlPanel,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
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
                                      color: AppColors.white,
                                    ),
                                  ),
                                  Text(
                                    'Comisión ${initial.percentage.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontFamily: AppFonts.body,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: AppColors.infoPill,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _money(total),
                          style: TextStyle(
                            fontFamily: AppFonts.heading,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                            height: 1.1,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          liquidada ? 'LIQUIDADA' : 'PRELIMINAR',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.4,
                            color: AppColors.infoPill,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'DESGLOSE DE SERVICIOS',
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
                          onPressed: _load,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  else if (_rows.isEmpty)
                    Text(
                      'Esta comisión no tiene servicios registrados.',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        color: AppColors.textSecondaryMuted,
                      ),
                    )
                  else
                    for (int i = 0; i < _rows.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _DetailRow(
                        name: _rows[i].nombre.isEmpty
                            ? 'Servicio'
                            : _rows[i].nombre,
                        subtitle: _rows[i].fecha.isEmpty
                            ? 'Precio ${_money(_rows[i].precio)}'
                            : '${_rows[i].fecha.split('T').first} · '
                                  'Precio ${_money(_rows[i].precio)}',
                        amount: _money(_rows[i].monto),
                      ),
                    ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryButtonSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _totalRow('Base comisionable', _money(base)),
                        const SizedBox(height: 6),
                        _totalRow(
                          '${initial.percentage.toStringAsFixed(0)}% aplicado',
                          _money(total),
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ESTADO',
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
                  Container(
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
                        Icon(
                          liquidada
                              ? Icons.check_circle_outline
                              : Icons.schedule,
                          size: 15,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          liquidada
                              ? 'Liquidada · cierre #${initial.liquidacionId}'
                              : 'Preliminar · pendiente de liquidación',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: AppPrimaryButton(
                  label: 'Volver a Comisiones',
                  leadingIcon: Icons.arrow_back,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool bold = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w700,
            fontSize: bold ? 15 : 13,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.name,
    required this.subtitle,
    required this.amount,
  });

  final String name;
  final String subtitle;
  final String amount;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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
          Text(
            amount,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
