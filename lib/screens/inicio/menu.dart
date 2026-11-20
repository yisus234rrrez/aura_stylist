import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_bottom_nav.dart';




class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          const AppHeader(section: 'Más'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  _ControlCard(),
                  SizedBox(height: 20),
                  _MenuSection(
                    title: 'Gestión',
                    items: [
                      (
                        icon: Icons.auto_awesome_outlined,
                        title: 'Especialidades',
                        subtitle: 'Catálogo de líneas y técnicas',
                        route: AppRoutes.specialties,
                      ),
                      (
                        icon: Icons.content_cut_outlined,
                        title: 'Servicios',
                        subtitle: 'Tarifas, duración y estado',
                        route: AppRoutes.services,
                      ),
                      (
                        icon: Icons.badge_outlined,
                        title: 'Profesionales',
                        subtitle: 'Equipo y comisión',
                        route: AppRoutes.professionals,
                      ),
                      (
                        icon: Icons.people_outline,
                        title: 'Clientes',
                        subtitle: 'Fichas y contacto',
                        route: AppRoutes.clients,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _MenuSection(
                    title: 'Operación',
                    items: [
                      (
                        icon: Icons.schedule,
                        title: 'Horarios',
                        subtitle: 'Jornadas semanales',
                        route: AppRoutes.schedule,
                      ),
                      (
                        icon: Icons.event_busy_outlined,
                        title: 'Inasistencias',
                        subtitle: 'Ausencias y permisos',
                        route: AppRoutes.absences,
                      ),
                      (
                        icon: Icons.task_alt,
                        title: 'Servicios realizados',
                        subtitle: 'Historial y comisión por servicio',
                        route: AppRoutes.servicesDone,
                      ),
                      (
                        icon: Icons.lock_outline,
                        title: 'Cierres',
                        subtitle: 'Periodos y liquidación',
                        route: AppRoutes.closures,
                      ),
                      (
                        icon: Icons.pie_chart_outline,
                        title: 'Comisiones',
                        subtitle: 'Liquidación por profesional',
                        route: AppRoutes.commissions,
                      ),
                    ],
                  ),
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


class _ControlCard extends StatelessWidget {
  const _ControlCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.controlPanel,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.controlPanelShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestiona Aura Stylist',
            style: TextStyle(
              fontFamily: AppFonts.heading,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              height: 28 / 22,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Catálogo, equipo, agenda y operación',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w400,
              fontSize: 13,
              height: 18 / 13,
              color: AppColors.infoPill,
            ),
          ),
        ],
      ),
    );
  }
}


class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});

  final String title;
  final List<({IconData icon, String title, String subtitle, String? route})>
      items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            height: 16 / 12,
            letterSpacing: 1,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.controlPanelShadow,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.secondaryButtonSurface,
                  ),
                _ListTile(
                  icon: items[i].icon,
                  title: items[i].title,
                  subtitle: items[i].subtitle,
                  onTap: items[i].route == null
                      ? null
                      : () => Navigator.of(
                          context,
                        ).pushNamed(items[i].route!),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}


class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.iconCircle,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 20, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 18 / 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 22,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
