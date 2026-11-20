import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';




class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, this.currentIndex = 0, this.onTap});

  final int currentIndex;
  final ValueChanged<int>? onTap;

  static const List<({IconData icon, String label})> items =
      <({IconData icon, String label})>[
    (icon: Icons.grid_view_outlined, label: 'Inicio'),
    (icon: Icons.calendar_month_outlined, label: 'Agenda'),
    (icon: Icons.people_alt_outlined, label: 'Clientes'),
    (icon: Icons.more_horiz, label: 'Menú'),
  ];

  static const List<String> _routes = <String>[
    AppRoutes.dashboard,
    AppRoutes.agenda,
    AppRoutes.clients,
    AppRoutes.menu,
  ];

  void _onItemTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }
    if (index == currentIndex) return;
    Navigator.of(context).pushReplacementNamed(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
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
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: List<Widget>.generate(items.length, (int i) {
                final bool active = i == currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => _onItemTap(context, i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          items[i].icon,
                          size: 22,
                          color: active
                              ? AppColors.textPrimary
                              : AppColors.textBody,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w400,
                            fontSize: 11,
                            height: 14 / 11,
                            color: active
                                ? AppColors.textPrimary
                                : AppColors.textBody,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.textPrimary
                                : AppColors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
