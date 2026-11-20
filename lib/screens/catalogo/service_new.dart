import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_admin_top_bar.dart';
import '../../widgets/app_form_actions.dart';
import '../../widgets/app_pickers.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_text_field.dart';
import '../../services/remote/aura_api.dart';
import '../../services/remote/api_service.dart';




class ServiceNewScreen extends StatefulWidget {
  const ServiceNewScreen({super.key});

  @override
  State<ServiceNewScreen> createState() => _ServiceNewScreenState();
}

class _ServiceNewScreenState extends State<ServiceNewScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _category;
  int? _categoryId;
  List<({String name, int id})> _categories = const [];
  bool _loadingCategories = true;
  bool _saving = false;

  @override
  void initState() { super.initState(); _loadCategories(); }

  Future<void> _loadCategories() async {
    try {
      final response = await AuraApi.getSpecialties();
      final raw = response.data;
      final values = raw is List ? raw : raw is Map && raw['data'] is List ? raw['data'] as List : <dynamic>[];
      final parsed = <({String name, int id})>[];
      for (final value in values.whereType<Map>()) {
        final name = (value['nombre'] ?? value['name'] ?? '').toString();
        final id = int.tryParse('${value['id'] ?? value['especialidadId']}');
        if (name.isNotEmpty && id != null) parsed.add((name:name,id:id));
      }
      if (!mounted) return;
      setState(() { _categories = parsed; _loadingCategories = false; });
    } on ApiException catch (e) { if (mounted) { setState(() => _loadingCategories = false); _showError(e.message); } }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Especialidad',
      options: _categories.map((item) => item.name).toList(),
      selected: _category,
    );
    if (picked != null) { final item = _categories.firstWhere((item) => item.name == picked); setState(() { _category = item.name; _categoryId = item.id; }); }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_category == null) {
      _showError('Selecciona una especialidad.');
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      _showError('Ingresa el nombre del servicio.');
      return;
    }
    final int? duration = int.tryParse(_durationController.text.trim());
    if (duration == null || duration < 0) {
      _showError('La duración debe ser un número mayor o igual a 0.');
      return;
    }
    final int? price = int.tryParse(
      _priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    if (price == null || price < 0) {
      _showError('El precio debe ser un número mayor o igual a 0.');
      return;
    }
    if (_categoryId == null) { _showError('La especialidad no tiene un ID válido de la API.'); return; }
    setState(() => _saving = true);
    try {
      final response = await AuraApi.createService({'nombre':_nameController.text.trim(),'precio':price,'descripcion':_descriptionController.text.trim(),'duracion':duration,'especialidad':_categoryId});
      if (!mounted) return;
      if (!response.isSuccess) { _showError(response.message ?? 'No se pudo guardar el servicio.'); return; }
      Navigator.of(context).pushReplacementNamed(AppRoutes.services);
    } on ApiException catch (e) { if (mounted) _showError(e.message); } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      height: 16 / 12,
      letterSpacing: 0.24,
      color: AppColors.textPrimary,
    );
    final TextStyle helperStyle = TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w500,
      fontSize: 11,
      height: 14 / 11,
      letterSpacing: 0.33,
      color: AppColors.textSecondaryMuted,
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          AppAdminTopBar(
            section: 'Crear Servicio',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nuevo Servicio',
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      height: 32 / 24,
                      letterSpacing: -0.24,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Configuración de tarifa y duración operativa',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 20 / 14,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppSelectField(
                    label: 'Especialidad',
                    required: true,
                    placeholder: _loadingCategories ? 'Cargando especialidades…' : _category ?? (_categories.isEmpty ? 'No hay especialidades disponibles' : 'Selecciona una especialidad'),
                    valueColor:
                        _category == null ? null : AppColors.textPrimary,
                    onTap: _loadingCategories || _categories.isEmpty ? null : _pickCategory,
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Nombre del servicio * · máx. 50 caracteres',
                    labelStyle: labelStyle,
                    controller: _nameController,
                    hintText: 'Ej. Corte de Estilo & Brushing',
                    hintColor: AppColors.hintOnWhite,
                    fillColor: AppColors.white,
                    elevated: true,
                    borderRadius: 12,
                    minHeight: 52,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Duración (min)',
                          labelSuffix: Text(
                            '*',
                            style: labelStyle.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                          labelStyle: labelStyle,
                          controller: _durationController,
                          hintText: 'Ej. 60',
                          hintColor: AppColors.hintOnWhite,
                          fillColor: AppColors.white,
                          elevated: true,
                          borderRadius: 12,
                          minHeight: 52,
                          keyboardType: TextInputType.number,
                          suffixIcon: const Icon(
                            Icons.schedule,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Precio (COP)',
                          labelSuffix: Text(
                            '*',
                            style: labelStyle.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                          labelStyle: labelStyle,
                          controller: _priceController,
                          hintText: '\$ 0',
                          hintColor: AppColors.hintOnWhite,
                          fillColor: AppColors.white,
                          elevated: true,
                          borderRadius: 12,
                          minHeight: 52,
                          keyboardType: TextInputType.number,
                          suffixIcon: const Icon(
                            Icons.payments_outlined,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text('Duración ≥ 0 min', style: helperStyle),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text('Precio ≥ \$ 0', style: helperStyle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Descripción técnica',
                    labelStyle: labelStyle,
                    controller: _descriptionController,
                    hintText: 'Describe brevemente el servicio',
                    hintColor: AppColors.hintOnWhite,
                    fillColor: AppColors.white,
                    elevated: true,
                    borderRadius: 12,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          AppFormActions(
            primaryLabel: _saving ? 'Guardando…' : 'Guardar servicio',
            onCancel: () => Navigator.of(context).maybePop(),
            onPrimary: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
