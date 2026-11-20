import 'package:flutter/material.dart';

import '../../models/clientes/cliente.dart';
import '../../routes/app_route_args.dart';
import '../../routes/app_routes.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_success_toast.dart';




class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key, this.showToast = false});

  final bool showToast;

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  String _query = '';
  int _selectedChip = 0;
  List<Cliente> _clients = <Cliente>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await AuraApi.clientes.list();
      if (!mounted) return;
      if (response.isSuccess) {
        setState(() {
          _clients = response.data ?? <Cliente>[];
          _loading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'No se pudieron cargar los clientes.';
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

  List<Cliente> get _filteredItems {
    final String query = _query.trim().toLowerCase();
    return _clients.where((Cliente item) {
      final bool matchesQuery = query.isEmpty ||
          item.nombreCompleto.toLowerCase().contains(query) ||
          item.documento.toLowerCase().contains(query) ||
          item.celular.toLowerCase().contains(query);
      final bool matchesChip = switch (_selectedChip) {
        1 => item.correo.isNotEmpty,
        2 => item.correo.isEmpty,
        _ => true,
      };
      return matchesQuery && matchesChip;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Cliente> items = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          const AppHeader(section: 'Clientes'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.showToast)
                    const AppSuccessToast(
                      title: 'Cliente guardado correctamente',
                      message:
                          'El cliente ya aparece en la lista de clientes.',
                    ),
                  _SummaryBanner(count: _clients.length),
                  const SizedBox(height: 12),
                  _SearchBar(
                    onChanged: (String value) =>
                        setState(() => _query = value),
                  ),
                  const SizedBox(height: 12),
                  _CategoryChips(
                    selectedIndex: _selectedChip,
                    onSelected: (int index) =>
                        setState(() => _selectedChip = index),
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
                          onPressed: _loadClients,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  else if (items.isEmpty)
                    Text(
                      _clients.isEmpty
                          ? 'No hay clientes registrados.'
                          : 'No hay clientes que coincidan con la búsqueda.',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        color: AppColors.textSecondaryMuted,
                      ),
                    ),
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _ClientCard(item: items[i]),
                  ],
                ],
              ),
            ),
          ),
          const AppBottomNav(currentIndex: 2),
        ],
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondaryButtonSurface,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 14,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '$count Clientes registrados',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      height: 14 / 11,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '28 visitas este mes',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 14 / 11,
              color: AppColors.textSecondaryMuted,
            ),
          ),
        ),
      ],
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
                hintText: 'Buscar por documento, nombre o celular...',
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
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const List<String> _chips = <String>[
    'Todos',
    'Con correo',
    'Sin correo',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _chips.length,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (i == 1) ...[
                    Icon(
                      Icons.star_outline,
                      size: 13,
                      color: selected
                          ? AppColors.white
                          : AppColors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    _chips[i],
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      height: 14 / 11,
                      letterSpacing: 0.33,
                      color: selected
                          ? AppColors.white
                          : AppColors.textPrimary80,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.item});

  final Cliente item;

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
                  item.iniciales,
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
                            item.nombreCompleto,
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
                        _TagBadge(
                          label: item.correo.isEmpty ? 'Sin correo' : 'Cliente',
                        ),
                      ],
                    ),
                    Text(
                      item.documento,
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
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 15,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                item.celular,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              const _CircleIcon(icon: Icons.chat_bubble_outline),
              const SizedBox(width: 6),
              const _CircleIcon(icon: Icons.call_outlined),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.mail_outline,
                size: 15,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.correo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.textBody,
                  ),
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
                        label: 'TRATAMIENTO PREFERIDO',
                        value: '—',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GridCell(
                        label: 'ÚLTIMA VISITA',
                        value: '—',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 14,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Cliente #${item.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    height: 14 / 11,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.secondaryButtonSurface,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.clientEdit,
                      arguments: ClientRouteArgs(
                        id: item.id,
                        documentType: 'C.C.',
                        document: item.documento,
                        names: item.nombres,
                        lastNames: item.apellidos,
                        birthDate: item.fechaNacimiento == null
                            ? ''
                            : '${item.fechaNacimiento!.day.toString().padLeft(2, '0')} / '
                                '${item.fechaNacimiento!.month.toString().padLeft(2, '0')} / '
                                '${item.fechaNacimiento!.year}',
                        phone: item.celular.replaceFirst('+57 ', ''),
                        email: item.correo,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Text(
                      'Ver ficha',
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
            fontSize: 9,
            height: 13 / 9,
            letterSpacing: 0.4,
            color: AppColors.textSecondaryFaint,
          ),
        ),
        Text(
          value,
          maxLines: 2,
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

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.overlayGreen30,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium_outlined,
            size: 11,
            color: AppColors.buttonLabelDark,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              height: 14 / 11,
              color: AppColors.buttonLabelDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.secondaryButtonSurface,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 15, color: AppColors.textPrimary),
    );
  }
}
