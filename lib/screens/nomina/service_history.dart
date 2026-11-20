import 'package:flutter/material.dart';

import '../../models/reservas/reserva.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_header.dart';


class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  List<Reserva> _realizadas = <Reserva>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRealizadas();
  }

  Future<void> _loadRealizadas() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await AuraApi.reservas.list();
      if (!mounted) return;
      if (!response.isSuccess) {
        setState(() {
          _error = response.message ?? 'No se pudieron cargar las reservas.';
          _loading = false;
        });
        return;
      }
      final List<Reserva> reservas = response.data ?? <Reserva>[];
      reservas.sort((Reserva a, Reserva b) => b.fecha.compareTo(a.fecha));
      final DateTime now = DateTime.now();
      setState(() {
        _realizadas = reservas.where((Reserva reserva) {
          if (reserva.estado == 1) return false;
          if (reserva.estado == 2) return true;
          final DateTime? fin = DateTime.tryParse(
            '${reserva.fechaCorta}T${reserva.horaFin}',
          );
          return fin != null && fin.isBefore(now);
        }).toList();
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final num totalFacturado = _realizadas.fold<num>(
      0,
      (num total, Reserva reserva) => total + reserva.precio,
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          const AppHeader(section: 'Servicios'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRealizadas,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Text(
                    'AUDITORÍA & VENTAS',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.55,
                      color: AppColors.textSecondaryFaint,
                    ),
                  ),
                  Text(
                    'Servicios Realizados',
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    'Reservas atendidas o ya finalizadas.',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 13,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: 'TOTAL FACTURADO',
                          value: '\$${totalFacturado.toStringAsFixed(0)}',
                          hint: 'COP · servicios completados',
                          icon: Icons.receipt_long_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          label: 'REALIZADOS',
                          value: '${_realizadas.length}',
                          hint: 'Citas completadas',
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_error != null)
                    Center(
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
                            onPressed: _loadRealizadas,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  else if (_realizadas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'No hay citas realizadas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 14,
                          color: AppColors.textSecondaryMuted,
                        ),
                      ),
                    )
                  else ...[
                    Text(
                      'CITAS REALIZADAS',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.55,
                        color: AppColors.textSecondaryFaint,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final Reserva reserva in _realizadas)
                      _ReservationCard(reserva: reserva),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
  });

  final String label;
  final String value;
  final String hint;
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
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    color: AppColors.textSecondaryFaint,
                  ),
                ),
              ),
              Icon(icon, size: 15, color: AppColors.textPrimary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.heading,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11,
              color: AppColors.textSecondaryMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reserva});

  final Reserva reserva;

  @override
  Widget build(BuildContext context) {
    final String cliente = reserva.clienteNombre.isEmpty
        ? 'Cliente ${reserva.clienteId}'
        : reserva.clienteNombre;
    final String servicio = reserva.servicioNombre.isEmpty
        ? 'Servicio ${reserva.servicioId}'
        : reserva.servicioNombre;
    final String profesional = reserva.profesionalNombre.isEmpty
        ? 'Especialista ${reserva.profesionalId}'
        : reserva.profesionalNombre;

    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cliente,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text('$servicio · \$${reserva.precio.toStringAsFixed(0)} COP'),
            Text('Especialista: $profesional'),
            Text('${reserva.fechaCorta} · ${reserva.hora}'),
          ],
        ),
      ),
    );
  }
}
