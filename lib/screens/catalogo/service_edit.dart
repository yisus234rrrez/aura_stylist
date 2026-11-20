import 'package:flutter/material.dart';

import '../../routes/app_route_args.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/aura_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_admin_top_bar.dart';
import '../../widgets/app_form_actions.dart';
import '../../widgets/app_success_toast.dart';
import '../../widgets/app_text_field.dart';




class ServiceEditScreen extends StatefulWidget {
  const ServiceEditScreen({
    super.key,
    this.title = 'Editar Servicio',
    this.initialActive = true,
    this.showToast = false,
    this.initial = const ServiceRouteArgs(),
  });

  final String title;
  final bool initialActive;
  final bool showToast;
  final ServiceRouteArgs initial;

  @override
  State<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends State<ServiceEditScreen> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initial.name.isEmpty
        ? 'Balayage Iluminado Botánico'
        : widget.initial.name,
  );
  late final TextEditingController _durationController = TextEditingController(
    text: widget.initial.duration.isEmpty
        ? '180'
        : widget.initial.duration.replaceAll(RegExp(r'[^0-9]'), ''),
  );
  late final TextEditingController _priceController = TextEditingController(
    text: widget.initial.price.isEmpty ? '\$280.000' : widget.initial.price,
  );
  late bool _active = widget.initial.id != 0
      ? widget.initial.active
      : widget.initialActive;

  @override
  void initState() {
    super.initState();
    _active = widget.initial.id != 0
        ? widget.initial.active
        : widget.initialActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
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
    if (widget.initial.id == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    try {
      final response = await AuraApi.servicios.updateRaw(
        widget.initial.id,
        <String, dynamic>{
          'nombre': _nameController.text.trim(),
          'precio': price,
          'activo': _active,
          'duracion': duration,
        },
      );
      if (!mounted) return;
      if (response.isSuccess) {
        Navigator.of(context).maybePop();
      } else {
        _showError(response.message ?? 'No se pudo actualizar el servicio.');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
                  if (widget.showToast)
                    const AppSuccessToast(
                      title: 'Servicio actualizado correctamente',
                      message: 'Los cambios se guardaron en el catálogo.',
                    ),
                  Text(
                    widget.title,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Configuración de tarifa y duración operativa',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 20 / 14,
                            color: AppColors.textSecondaryMuted,
                          ),
                        ),
                      ),
                      Text(
                        widget.initial.code.isEmpty
                            ? 'ID: SRV-101'
                            : 'ID: ${widget.initial.code}',
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          height: 14 / 11,
                          letterSpacing: 0.55,
                          color: AppColors.textSecondaryMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _ProtectedCard(),
                  const SizedBox(height: 16),
                  _ReadonlyField(
                    label: 'Especialidad asociada (solo lectura)',
                    value: widget.initial.category.isEmpty
                        ? 'Peluquería y Colorimetría'
                        : widget.initial.category,
                    labelStyle: labelStyle,
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Nombre del servicio * · máx. 50 caracteres',
                    labelStyle: labelStyle,
                    controller: _nameController,
                    fillColor: AppColors.white,
                    elevated: true,
                    borderRadius: 12,
                    minHeight: 52,
                    textColor: AppColors.textPrimary,
                    suffixIcon: const Icon(
                      Icons.check_circle,
                      size: 17,
                      color: AppColors.accentDark,
                    ),
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
                          fillColor: AppColors.white,
                          elevated: true,
                          borderRadius: 12,
                          minHeight: 52,
                          textColor: AppColors.textPrimary,
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
                          fillColor: AppColors.white,
                          elevated: true,
                          borderRadius: 12,
                          minHeight: 52,
                          textColor: AppColors.textPrimary,
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
                  const SizedBox(height: 16),
                  const _InfoNote(),
                  const SizedBox(height: 16),
                  _StatusCard(
                    active: _active,
                    onToggle: () => setState(() => _active = !_active),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Descripción técnica',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          'Bloqueado para preservar historial',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: helperStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryButtonSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Diagnóstico capilar integral, balayage, decoloración '
                      'botánica y rituales de sellado térmico.',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 20 / 14,
                        color: AppColors.textSecondaryMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppFormActions(
            primaryLabel: 'Guardar cambios',
            onCancel: () => Navigator.of(context).maybePop(),
            onPrimary: _save,
          ),
        ],
      ),
    );
  }
}


class _ProtectedCard extends StatelessWidget {
  const _ProtectedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 18,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campos protegidos',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'La especialidad y la descripción técnica son de solo lectura '
                  'en modo edición para preservar el historial de citas y '
                  'métricas anteriores.',
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
    );
  }
}


class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({
    required this.label,
    required this.value,
    required this.labelStyle,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.secondaryButtonSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.lock_outline,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _InfoNote extends StatelessWidget {
  const _InfoNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.percent,
            size: 16,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tarifa sujeta a comisión del 45% según profesional asignado.',
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
    );
  }
}


class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.active, required this.onToggle});

  final bool active;
  final VoidCallback onToggle;

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
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active
                      ? 'Servicio Activo en Agenda'
                      : 'Servicio inactivo en agenda',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 20 / 14,
                    letterSpacing: 0.14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  active
                      ? 'Disponible para nuevas reservas de clientes.'
                      : 'No disponible para nuevas reservas de clientes.',
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
          _ActiveSwitch(active: active, onTap: onToggle),
        ],
      ),
    );
  }
}

class _ActiveSwitch extends StatelessWidget {
  const _ActiveSwitch({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        width: 48,
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.secondaryButtonSurface,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: active
              ? const Icon(Icons.check, size: 14, color: AppColors.textPrimary)
              : null,
        ),
      ),
    );
  }
}


