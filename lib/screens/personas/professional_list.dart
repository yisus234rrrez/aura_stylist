import 'package:flutter/material.dart';

import '../../models/profesionales/profesional.dart';
import '../../routes/app_route_args.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_bottom_nav.dart';




class ProfessionalListScreen extends StatefulWidget {
  const ProfessionalListScreen({super.key});

  @override
  State<ProfessionalListScreen> createState() =>
      _ProfessionalListScreenState();
}

class _ProfessionalListScreenState extends State<ProfessionalListScreen> {
  String _query = '';
  int _selectedChip = 0;
  List<Profesional> _professionals = <Profesional>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfessionals();
  }

  Future<void> _loadProfessionals() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await AuraApi.profesionales.list();
      if (!mounted) return;
      if (response.isSuccess) {
        setState(() {
          _professionals = response.data ?? <Profesional>[];
          _loading = false;
        });
      } else {
        setState(() {
          _error =
              response.message ?? 'No se pudieron cargar los profesionales.';
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


  List<({int id, String name})> get _specialtyChips {
    final Map<int, String> names = <int, String>{};
    for (final Profesional item in _professionals) {
      names.putIfAbsent(
        item.especialidadId,
        () => item.especialidad?.nombre ?? 'Sin especialidad',
      );
    }
    return <({int id, String name})>[
      for (final MapEntry<int, String> entry in names.entries)
        (id: entry.key, name: entry.value),
    ];
  }

  List<String> get _chipLabels {
    final List<({int id, String name})> chips = _specialtyChips;
    return <String>[
      'Todas (${_professionals.length})',
      for (final ({int id, String name}) chip in chips)
        '${chip.name} (${_professionals.where((Profesional item) => item.especialidadId == chip.id).length})',
    ];
  }

  String _dateText(DateTime? date) {    if (date == null) return 'Sin fecha';
    const List<String> months = <String>[
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  List<
    ({
      int id,
      String initials,
      String name,
      String doc,
      String specialty,
      int specialtyId,
      String commission,
      String birth,
      String birthIso,
      bool active,
    })
  >
  get _filteredItems {
    final String query = _query.trim().toLowerCase();
    final List<
      ({
        int id,
        String initials,
        String name,
        String doc,
        String specialty,
        int specialtyId,
        String commission,
        String birth,
        String birthIso,
        bool active,
      })
    >
    items = _professionals
        .map(
          (Profesional item) => (
            id: item.id,
            initials: item.iniciales,
            name: item.nombreCompleto,
            doc: 'CC ${item.documento}',
            specialty: item.especialidad?.nombre ?? 'Sin especialidad',
            specialtyId: item.especialidadId,
            commission: '${item.porcentaje.toStringAsFixed(0)}% por servicio',
            birth: _dateText(item.fechaNacimiento),
            birthIso: item.fechaNacimiento == null
                ? ''
                : item.fechaNacimiento!.toIso8601String().split('T').first,
            active: item.estado,
          ),
        )
        .where((item) {
          final bool matchesQuery = query.isEmpty ||
              item.name.toLowerCase().contains(query) ||
              item.doc.toLowerCase().contains(query) ||
              item.specialty.toLowerCase().contains(query);
          final List<({int id, String name})> chips = _specialtyChips;
          final bool matchesChip = _selectedChip <= 0 ||
              _selectedChip > chips.length ||
              item.specialtyId == chips[_selectedChip - 1].id;
          return matchesQuery && matchesChip;
        })
        .toList();
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final List<
      ({
        int id,
        String initials,
        String name,
        String doc,
        String specialty,
        int specialtyId,
        String commission,
        String birth,
        String birthIso,
        bool active,
      })
    >
    items = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          const AppHeader(section: 'Profesionales'),
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
                              'Profesionales',
                              style: TextStyle(
                                fontFamily: AppFonts.heading,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                height: 32 / 24,
                                letterSpacing: -0.6,
                                color: AppColors.secondary,
                              ),
                            ),
                            Text(
                              'Equipo técnico y especialistas habilitados',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 20 / 14,
                                color: AppColors.textSecondaryMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const _NewButton(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _PerformanceBanner(
                    activeCount: _professionals
                        .where((Profesional item) => item.estado)
                        .length,
                  ),
                  const SizedBox(height: 16),
                  _SearchBar(
                    onChanged: (String value) =>
                        setState(() => _query = value),
                  ),
                  const SizedBox(height: 16),
                  _CategoryChips(
                    options: _chipLabels,
                    selectedIndex: _selectedChip,
                    onSelected: (int index) =>
                        setState(() => _selectedChip = index),
                  ),
                  const SizedBox(height: 8),
                  _StatusRow(
                    activeCount: _professionals
                        .where((Profesional item) => item.estado)
                        .length,
                    inactiveCount: _professionals
                        .where((Profesional item) => !item.estado)
                        .length,
                    shown: items.length,
                    total: _professionals.length,
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
                          onPressed: _loadProfessionals,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  else if (items.isEmpty)
                    Text(
                      _professionals.isEmpty
                          ? 'No hay profesionales registrados.'
                          : 'No hay profesionales que coincidan con la búsqueda.',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        color: AppColors.textSecondaryMuted,
                      ),
                    ),
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _ProfessionalCard(
                      item: items[i],
                      onChanged: _loadProfessionals,
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

class _NewButton extends StatelessWidget {
  const _NewButton();

  @override
  Widget build(BuildContext context) {
    const BorderRadius radius = BorderRadius.all(Radius.circular(12));
    return Material(
      color: AppColors.primary,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.professionalNew);
        },
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_add_alt_1_outlined,
                size: 16,
                color: AppColors.buttonLabelDark,
              ),
              const SizedBox(width: 4),
              Text(
                'Nuevo',
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
    );
  }
}

class _PerformanceBanner extends StatelessWidget {
  const _PerformanceBanner({required this.activeCount});

  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryButtonSurface,
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
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.overlayGreen30,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insights_outlined,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OPERACIÓN EN CURSO',
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
                  '$activeCount estilistas activos',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 20 / 14,
                    letterSpacing: 0.14,
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

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
                hintText: 'Buscar por nombre, documento o RUT...',
                hintStyle: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  color: AppColors.textPrimary40,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 14),
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

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.activeCount,
    required this.inactiveCount,
    required this.shown,
    required this.total,
  });

  final int activeCount;
  final int inactiveCount;
  final int shown;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill(
          AppColors.surfaceMuted,
          AppColors.primary,
          'Activos ($activeCount)',
          AppColors.textPrimary,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: _pill(
            AppColors.secondaryButtonSurface,
            AppColors.danger,
            'Inactivos ($inactiveCount)',
            AppColors.textSecondaryFaint,
          ),
        ),
        const Spacer(),
        Text(
          'Mostrando $shown de $total',
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w500,
            fontSize: 10,
            height: 14 / 10,
            color: AppColors.textSecondaryMuted,
          ),
        ),
      ],
    );
  }

  Widget _pill(Color background, Color dot, String label, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
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
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  const _ProfessionalCard({required this.item, required this.onChanged});

  final ({
    int id,
    String initials,
    String name,
    String doc,
    String specialty,
    int specialtyId,
    String commission,
    String birth,
    String birthIso,
    bool active,
  })
  item;
  final VoidCallback onChanged;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
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
                    fontSize: 16,
                    height: 1,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
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
                        ),
                        const SizedBox(width: 8),
                        _ActiveBadge(active: item.active),
                      ],
                    ),
                    Text(
                      item.doc,
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
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _GridCell(
                        label: 'ESPECIALIDAD',
                        value: item.specialty,
                      ),
                    ),
                    Expanded(
                      child: _GridCell(
                        label: 'COMISIÓN',
                        value: item.commission,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _GridCell(
                        label: 'NACIMIENTO',
                        value: item.birth,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CardButton(
                  label: 'Editar',
                  icon: Icons.edit_outlined,
                  filled: false,
                  onTap: () {
                    final List<String> docParts = item.doc.split(' ');
                    final String docNumber = docParts.length > 1
                        ? docParts.sublist(1).join(' ')
                        : item.doc;
                    final List<String> nameParts = item.name.split(' ');
                    final String lastNames = nameParts.length >= 3
                        ? nameParts.sublist(nameParts.length - 2).join(' ')
                        : (nameParts.length == 2 ? nameParts.last : '');
                    final String names = lastNames.isEmpty
                        ? item.name
                        : nameParts
                            .sublist(
                              0,
                              nameParts.length -
                                  (nameParts.length >= 3 ? 2 : 1),
                            )
                            .join(' ');
                    Navigator.of(context).pushNamed(
                      AppRoutes.professionalEdit,
                      arguments: ProfessionalRouteArgs(
                        id: item.id,
                        document: docNumber,
                        names: names,
                        lastNames: lastNames,
                        birthDate: item.birthIso,
                        commission: item.commission.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        ),
                        specialty: item.specialty,
                        specialtyId: item.specialtyId,
                        active: item.active,
                      ),
                    ).then((_) => onChanged());
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CardButton(
                  label: 'Ver Horario',
                  icon: Icons.calendar_month_outlined,
                  filled: true,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.schedule),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            height: 14 / 10,
            letterSpacing: 0.55,
            color: AppColors.textSecondaryFaint,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            height: 16 / 12,
            color: AppColors.textPrimary,
          ),
        ),
      ],
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

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.label,
    required this.icon,
    required this.filled,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color background = filled
        ? AppColors.secondary
        : AppColors.secondaryButtonSurface;
    final Color foreground = filled ? AppColors.white : AppColors.textPrimary;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 18 / 13,
                    letterSpacing: 0.14,
                    color: foreground,
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
