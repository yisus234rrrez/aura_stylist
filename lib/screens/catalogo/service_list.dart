import 'package:flutter/material.dart';

import '../../models/especialidades/especialidad.dart';
import '../../models/servicios/servicio.dart';
import '../../routes/app_route_args.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_options_sheet.dart';
import '../../widgets/app_pickers.dart';
import '../../widgets/app_primary_button.dart';




class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key, this.empty = false});


  final bool empty;

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  String _query = '';
  int _selectedCategory = 0;
  int _selectedStatus = 0;
  int _sortMode = 0;
  List<Servicio> _services = <Servicio>[];
  List<Especialidad> _specialties = <Especialidad>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final responses = await Future.wait<dynamic>(<Future<dynamic>>[
        AuraApi.servicios.list(),
        AuraApi.especialidades.list(),
      ]);
      if (!mounted) return;
      final serviceResponse = responses[0];
      final specialtyResponse = responses[1];
      setState(() {
        if (serviceResponse.isSuccess) {
          _services = serviceResponse.data as List<Servicio>? ?? <Servicio>[];
        } else {
          _error = serviceResponse.message ??
              'No se pudieron cargar los servicios.';
        }
        if (specialtyResponse.isSuccess) {
          _specialties =
              specialtyResponse.data as List<Especialidad>? ?? <Especialidad>[];
        }
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

  String _categoryName(int id) {
    for (final Especialidad item in _specialties) {
      if (item.id == id) return item.nombre;
    }
    return 'Sin especialidad';
  }


  List<String> get _categoryOptions => <String>[
    'Todas',
    for (final Especialidad item in _specialties) item.nombre,
  ];

  int? get _selectedCategoryId {
    if (_selectedCategory <= 0 || _selectedCategory > _specialties.length) {
      return null;
    }
    return _specialties[_selectedCategory - 1].id;
  }

  List<
    ({
      int id,
      String code,
      String title,
      String category,
      String duration,
      String price,
      String description,
      int specialtyId,
      bool active,
    })
  >
  get _filteredServices {
    final String query = _query.trim().toLowerCase();
    final List<
      ({
        int id,
        String code,
        String title,
        String category,
        String duration,
        String price,
        String description,
        int specialtyId,
        bool active,
      })
    >
    items = _services
        .map(
          (Servicio item) => (
            id: item.id,
            code: 'SRV-${item.id}',
            title: item.nombre,
            category: _categoryName(item.especialidadId),
            duration: '${item.duracion} min',
            price: item.precioTexto,
            description: item.descripcion,
            specialtyId: item.especialidadId,
            active: item.activo,
          ),
        )
        .where((item) {
          final bool matchesQuery = query.isEmpty ||
              item.title.toLowerCase().contains(query) ||
              item.code.toLowerCase().contains(query);
          final int? categoryId = _selectedCategoryId;
          final bool matchesCategory =
              categoryId == null || item.specialtyId == categoryId;
          final bool matchesStatus = switch (_selectedStatus) {
            1 => item.active,
            2 => !item.active,
            _ => true,
          };
          return matchesQuery && matchesCategory && matchesStatus;
        })
        .toList();
    if (_sortMode == 0) {
      items.sort((a, b) => a.title.compareTo(b.title));
    } else {
      items.sort((a, b) => _priceValue(a.price).compareTo(_priceValue(b.price)));
    }
    return items;
  }

  int _priceValue(String price) {
    return int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  Future<void> _openSort() async {
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Ordenar servicios',
      options: const <String>[
        'Nombre (A-Z)',
        'Precio (menor a mayor)',
      ],
      selected: _sortMode == 0
          ? 'Nombre (A-Z)'
          : 'Precio (menor a mayor)',
    );
    if (picked != null) {
      setState(() => _sortMode = picked == 'Nombre (A-Z)' ? 0 : 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<
      ({
        int id,
        String code,
        String title,
        String category,
        String duration,
        String price,
        String description,
        int specialtyId,
        bool active,
      })
    >
    items = _filteredServices;

    final num average = items.isEmpty
        ? 0
        : items.fold<num>(0, (num sum, item) => sum + _priceValue(item.price)) /
              items.length;

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          const AppHeader(section: 'Servicios'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Servicios',
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      height: 32 / 24,
                      letterSpacing: -0.6,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Catálogo maestro de tratamientos y tarifas',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 20 / 14,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppPrimaryButton(
                    label: 'Nuevo servicio',
                    leadingIcon: Icons.add,
                    labelColor: AppColors.buttonLabelDark,
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.serviceNew),
                  ),
                  const SizedBox(height: 16),
                  _SearchBar(
                    onChanged: (String value) =>
                        setState(() => _query = value),
                    onFilterTap: _openSort,
                  ),
                  const SizedBox(height: 16),
                  _CategoryChips(
                    options: _categoryOptions,
                    selectedIndex: _selectedCategory,
                    onSelected: (int index) =>
                        setState(() => _selectedCategory = index),
                  ),
                  const SizedBox(height: 8),
                  _StatusFilters(
                    activeCount:
                        _services.where((Servicio item) => item.activo).length,
                    inactiveCount:
                        _services.where((Servicio item) => !item.activo).length,
                    selectedIndex: _selectedStatus,
                    onSelected: (int index) =>
                        setState(() => _selectedStatus = index),
                  ),
                  const SizedBox(height: 16),
                  _SummaryBar(
                    count: items.length,
                    trailing: items.isEmpty
                        ? null
                        : 'Tarifa prom. \$${average.toInt()}',
                  ),
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
                          onPressed: _loadServices,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  else if (widget.empty || items.isEmpty)
                    const _EmptyState()
                  else
                    for (int i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _ServiceCard(
                        item: items[i],
                        onChanged: _loadServices,
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


class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged, required this.onFilterTap});

  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMenuCard,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                color: AppColors.textBody,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Buscar por servicio o código...',
                hintStyle: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  color: AppColors.textPrimary40,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.tune,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}


class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
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
                options[i],
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 14 / 11,
                  letterSpacing: 0.33,
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


class _StatusFilters extends StatelessWidget {
  const _StatusFilters({
    required this.activeCount,
    required this.inactiveCount,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int activeCount;
  final int inactiveCount;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        _pill(
          AppColors.surfaceMuted,
          AppColors.primary,
          'Todos (${activeCount + inactiveCount})',
          AppColors.textPrimary,
          selectedIndex == 0,
          () => onSelected(0),
        ),
        _pill(
          AppColors.surfaceMuted,
          AppColors.primary,
          'Activos ($activeCount)',
          AppColors.textPrimary,
          selectedIndex == 1,
          () => onSelected(1),
        ),
        _pill(
          AppColors.secondaryButtonSurface,
          AppColors.danger,
          'Inactivos ($inactiveCount)',
          AppColors.textSecondaryFaint,
          selectedIndex == 2,
          () => onSelected(2),
        ),
      ],
    );
  }

  Widget _pill(
    Color background,
    Color dot,
    String label,
    Color textColor,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: selected ? Border.all(color: AppColors.secondary) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 14 / 11,
                  letterSpacing: 0.33,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.count, this.trailing});

  final int count;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.summaryBar,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.design_services_outlined,
            size: 14,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            '$count Servicios registrados',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 14 / 11,
              letterSpacing: 0.33,
              color: AppColors.textPrimary80,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            Flexible(
              child: Text(
                trailing!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 14 / 11,
                  letterSpacing: 0.33,
                  color: AppColors.textSecondaryMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No encontramos servicios',
          style: TextStyle(
            fontFamily: AppFonts.heading,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            height: 32 / 24,
            letterSpacing: -0.6,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Prueba con otro término de búsqueda o limpia los filtros para ver '
          'todos los servicios.',
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 20 / 14,
            color: AppColors.textSecondaryMuted,
          ),
        ),
      ],
    );
  }
}


class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item, required this.onChanged});

  final ({
    int id,
    String code,
    String title,
    String category,
    String duration,
    String price,
    String description,
    int specialtyId,
    bool active,
  })
  item;
  final VoidCallback onChanged;

  Future<void> _openEdit(BuildContext context) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.serviceEdit,
      arguments: ServiceRouteArgs(
        id: item.id,
        code: item.code,
        name: item.title,
        category: item.category,
        duration: item.duration,
        price: item.price,
        description: item.description,
        specialtyId: item.specialtyId,
        active: item.active,
      ),
    );
    onChanged();
  }

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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.code,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            height: 14 / 11,
                            letterSpacing: 0.55,
                            color: AppColors.hintOnWhite,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ActiveBadge(active: item.active),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        height: 28 / 20,
                        letterSpacing: -0.5,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      item.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              const SizedBox(width: 8),
              _CardIconButton(
                icon: Icons.edit_outlined,
                onTap: () => _openEdit(context),
              ),
              _CardIconButton(
                icon: Icons.more_vert,
                onTap: () => showAppOptionsSheet(
                  context,
                  options: [
                    (
                      icon: Icons.edit_outlined,
                      label: 'Editar servicio',
                      onTap: () => _openEdit(context),
                    ),
                    (
                      icon: Icons.copy_all_outlined,
                      label: 'Duplicar',
                      onTap: () async {
                        final int price = int.tryParse(
                              item.price.replaceAll(RegExp(r'[^0-9]'), ''),
                            ) ??
                            0;
                        final int duration = int.tryParse(
                              item.duration.replaceAll(RegExp(r'[^0-9]'), ''),
                            ) ??
                            0;
                        try {
                          final response = await AuraApi.servicios.createRaw(
                            <String, dynamic>{
                              'nombre': '${item.title} (copia)',
                              'precio': price,
                              'descripcion': item.description,
                              'duracion': duration,
                              'especialidad': item.specialtyId,
                            },
                          );
                          if (!context.mounted) return;
                          if (response.isSuccess) {
                            onChanged();
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  content: Text('Servicio duplicado.'),
                                ),
                              );
                          } else {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response.message ??
                                        'No se pudo duplicar el servicio.',
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
                      icon: item.active
                          ? Icons.toggle_off_outlined
                          : Icons.toggle_on_outlined,
                      label: item.active
                          ? 'Marcar como inactivo'
                          : 'Marcar como activo',
                      onTap: () async {
                        final bool accepted = await showAppConfirmDialog(
                          context,
                          title: item.active
                              ? 'Marcar servicio inactivo'
                              : 'Activar servicio',
                          message: item.active
                              ? 'El servicio dejará de estar disponible para '
                                  'nuevas reservas.'
                              : 'El servicio volverá a estar disponible para '
                                  'nuevas reservas.',
                          confirmLabel: item.active ? 'Marcar inactivo' : 'Activar',
                        );
                        if (!accepted || !context.mounted) return;
                        final int price = int.tryParse(
                              item.price.replaceAll(RegExp(r'[^0-9]'), ''),
                            ) ??
                            0;
                        final int duration = int.tryParse(
                              item.duration.replaceAll(RegExp(r'[^0-9]'), ''),
                            ) ??
                            0;
                        try {
                          final response = await AuraApi.servicios.updateRaw(
                            item.id,
                            <String, dynamic>{
                              'nombre': item.title,
                              'precio': price,
                              'activo': !item.active,
                              'duracion': duration,
                            },
                          );
                          if (!context.mounted) return;
                          if (response.isSuccess) {
                            onChanged();
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    item.active
                                        ? 'Servicio marcado como inactivo.'
                                        : 'Servicio activado.',
                                  ),
                                ),
                              );
                          } else {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response.message ??
                                        'No se pudo actualizar el servicio.',
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
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceOverlay,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 13,
                  color: AppColors.textBody,
                ),
                const SizedBox(width: 4),
                Text(
                  item.duration,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    height: 14 / 11,
                    letterSpacing: 0.33,
                    color: AppColors.textBody,
                  ),
                ),
                const Spacer(),
                Text(
                  item.price,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 18 / 13,
                    color: AppColors.textPrimary,
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

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color background =
        active ? AppColors.overlayGreen30 : AppColors.dangerSurface;
    final Color foreground =
        active ? AppColors.buttonLabelDark : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_outline : Icons.lock_outline,
            size: 11,
            color: foreground,
          ),
          const SizedBox(width: 4),
          Text(
            active ? 'Activo' : 'Inactivo',
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

class _CardIconButton extends StatelessWidget {
  const _CardIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}
