import 'package:flutter/material.dart';

import '../../models/especialidades/especialidad.dart';
import '../../routes/app_route_args.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_options_sheet.dart';




class SpecialtyListScreen extends StatefulWidget {
  const SpecialtyListScreen({super.key});

  @override
  State<SpecialtyListScreen> createState() => _SpecialtyListScreenState();
}

class _SpecialtyListScreenState extends State<SpecialtyListScreen> {
  String _query = '';
  int _selectedTab = 0;
  List<Especialidad> _specialties = <Especialidad>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSpecialties();
  }

  Future<void> _loadSpecialties() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await AuraApi.especialidades.list();
      if (!mounted) return;
      if (response.isSuccess) {
        setState(() {
          _specialties = response.data ?? <Especialidad>[];
          _loading = false;
        });
      } else {
        setState(() {
          _error =
              response.message ?? 'No se pudieron cargar las especialidades.';
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

  List<
    ({
      int id,
      IconData icon,
      String title,
      String services,
      String shift,
      bool activa,
    })
  >
  get _items {
    return _specialties
        .map(
          (Especialidad item) => (
            id: item.id,
            icon: _iconFor(item.nombre),
            title: item.nombre,
            services: 'Especialidad de la API',
            shift: item.activa ? 'Activa' : 'Inactiva',
            activa: item.activa,
          ),
        )
        .toList();
  }

  IconData _iconFor(String nombre) {
    final String value = nombre.toLowerCase();
    if (value.contains('uña') || value.contains('manicure')) {
      return Icons.brush_outlined;
    }
    if (value.contains('facial') || value.contains('piel')) {
      return Icons.spa_outlined;
    }
    if (value.contains('color') || value.contains('cabello')) {
      return Icons.content_cut_outlined;
    }
    return Icons.auto_awesome_outlined;
  }

  List<
    ({
      int id,
      IconData icon,
      String title,
      String services,
      String shift,
      bool activa,
    })
  >
  get _filteredItems {
    final String query = _query.trim().toLowerCase();
    return _items.where((item) {
      final bool matchesQuery =
          query.isEmpty || item.title.toLowerCase().contains(query);
      final bool matchesTab = switch (_selectedTab) {
        1 => item.activa,
        2 => !item.activa,
        _ => true,
      };
      return matchesQuery && matchesTab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final int activeCount =
        _specialties.where((Especialidad item) => item.activa).length;
    final List<
      ({
        int id,
        IconData icon,
        String title,
        String services,
        String shift,
        bool activa,
      })
    >
    items = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(section: 'Menú'),
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
                              'Especialidades',
                              style: TextStyle(
                                fontFamily: AppFonts.heading,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                height: 32 / 24,
                                letterSpacing: -0.24,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Catálogo de líneas maestras y servicios',
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
                      const SizedBox(width: 8),
                      _ActionButton(
                        label: 'Nueva',
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.specialtyNew),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SearchField(
                    hint: 'Buscar especialidad o técnica...',
                    onChanged: (String value) =>
                        setState(() => _query = value),
                  ),
                  const SizedBox(height: 16),
                  _SegmentedTabs(
                    selectedIndex: _selectedTab,
                    onSelected: (int index) =>
                        setState(() => _selectedTab = index),
                    tabs: <({IconData icon, String label, int count})>[
                      (
                        icon: Icons.grid_view_outlined,
                        label: 'Todas',
                        count: _specialties.length,
                      ),
                      (
                        icon: Icons.check_circle_outline,
                        label: 'Activas',
                        count: activeCount,
                      ),
                      (
                        icon: Icons.lock_outline,
                        label: 'Inactivas',
                        count: _specialties.length - activeCount,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SummaryCard(count: _specialties.length),
                  const SizedBox(height: 16),
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
                          onPressed: _loadSpecialties,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  else if (items.isEmpty)
                    Text(
                      _specialties.isEmpty
                          ? 'No hay especialidades registradas.'
                          : 'No hay especialidades que coincidan con el filtro.',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        color: AppColors.textSecondaryMuted,
                      ),
                    ),
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    _SpecialtyCard(
                      item: items[i],
                      onChanged: _loadSpecialties,
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


class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.infoPill,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.layers_outlined,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count Especialidades registradas',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 24 / 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Catálogo maestro de la API',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'ACTIVO 83%',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              height: 14 / 11,
              letterSpacing: 0.55,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}


class _SpecialtyCard extends StatelessWidget {
  const _SpecialtyCard({required this.item, required this.onChanged});

  final ({
    int id,
    IconData icon,
    String title,
    String services,
    String shift,
    bool activa,
  })
  item;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 23, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 24 / 16,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.event_available_outlined,
                          size: 13,
                          color: AppColors.textBody,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.services,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 16 / 12,
                              color: AppColors.textBody,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(active: item.activa),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceOverlay,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 14,
                  color: AppColors.textBody,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.shift,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      height: 14 / 11,
                      letterSpacing: 0.33,
                      color: AppColors.textBody,
                    ),
                  ),
                ),
                _IconButton(
                  icon: Icons.edit_outlined,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.specialtyEdit,
                    arguments: SpecialtyRouteArgs(
                      id: item.id,
                      name: item.title,
                    ),
                  ),
                ),
                _IconButton(
                  icon: Icons.more_vert,
                  onTap: () => showAppOptionsSheet(
                    context,
                    options: [
                      (
                        icon: Icons.edit_outlined,
                        label: 'Editar especialidad',
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.specialtyEdit,
                          arguments: SpecialtyRouteArgs(
                            id: item.id,
                            name: item.title,
                          ),
                        ),
                      ),
                      (
                        icon: Icons.copy_all_outlined,
                        label: 'Duplicar',
                        onTap: () async {
                          try {
                            final response = await AuraApi.especialidades.create(
                              '${item.title} (copia)',
                            );
                            if (!context.mounted) return;
                            if (response.isSuccess) {
                              onChanged();
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  const SnackBar(
                                    content: Text('Especialidad duplicada.'),
                                  ),
                                );
                            } else {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      response.message ??
                                          'No se pudo duplicar la especialidad.',
                                    ),
                                  ),
                                );
                            }
                          } on ApiException catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(content: Text(e.message)));
                          }
                        },
                      ),
                      (
                        icon: Icons.delete_outline,
                        label: 'Eliminar especialidad',
                        onTap: () async {
                          final bool accepted = await showAppConfirmDialog(
                            context,
                            title: 'Eliminar especialidad',
                            message:
                                'La especialidad se eliminará del catálogo. '
                                'Esta acción no se puede deshacer.',
                            confirmLabel: 'Eliminar',
                          );
                          if (!accepted || !context.mounted) return;
                          try {
                            final response =
                                await AuraApi.especialidades.delete(item.id);
                            if (!context.mounted) return;
                            if (response.isSuccess) {
                              onChanged();
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  const SnackBar(
                                    content: Text('Especialidad eliminada.'),
                                  ),
                                );
                            } else {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      response.message ??
                                          'No se pudo eliminar la especialidad.',
                                    ),
                                  ),
                                );
                            }
                          } on ApiException catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(content: Text(e.message)));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color background =
        active ? AppColors.statusActive : AppColors.dangerSurface;
    final Color foreground =
        active ? AppColors.statusActiveText : AppColors.danger;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_outline : Icons.lock_outline,
            size: 12,
            color: foreground,
          ),
          const SizedBox(width: 4),
          Text(
            active ? 'Activa' : 'Inactiva',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              height: 14 / 11,
              letterSpacing: 0.33,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 40,
        height: 32,
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}


class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const BorderRadius radius = BorderRadius.all(Radius.circular(12));
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: AppColors.primary,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16, color: AppColors.buttonLabelDark),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 20 / 14,
                    letterSpacing: 0.14,
                    color: AppColors.buttonLabelDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _SearchField extends StatelessWidget {
  const _SearchField({this.hint = 'Buscar...', required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColors.textBody,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  color: AppColors.textBodyFaint,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}


class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.tabs,
    required this.onSelected,
    this.selectedIndex = 0,
  });

  final List<({IconData icon, String label, int count})> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: _Tab(
                icon: tabs[i].icon,
                label: tabs[i].label,
                count: tabs[i].count,
                selected: i == selectedIndex,
                onTap: () => onSelected(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected ? AppColors.white : AppColors.textBody;
    return Material(
      color: selected
          ? AppColors.secondary
          : AppColors.secondaryButtonSurface,
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        borderRadius: BorderRadius.circular(9999),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: foreground),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 16 / 12,
                    letterSpacing: 0.24,
                    color: foreground,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.tabSelectedBadge
                      : AppColors.countdownBadge,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 14 / 11,
                  letterSpacing: 0.33,
                  color: selected
                      ? AppColors.tabSelectedBadgeText
                      : AppColors.textDark,
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
