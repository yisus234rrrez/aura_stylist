import 'package:flutter/material.dart';

import '../../routes/app_route_args.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/app_admin_top_bar.dart';
import '../../widgets/app_form_actions.dart';
import '../../widgets/app_form_section.dart';
import '../../widgets/app_pickers.dart';
import '../../widgets/app_text_field.dart';
import '../../services/remote/aura_api.dart';
import '../../services/remote/api_service.dart';




class ClientFormScreen extends StatefulWidget {
  const ClientFormScreen({
    super.key,
    this.isEdit = false,
    this.initial = const ClientRouteArgs(),
  });

  final bool isEdit;
  final ClientRouteArgs initial;

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  late final TextEditingController _docController = TextEditingController(
    text: _valueOr(widget.initial.document, '1.033.452.890'),
  );
  late final TextEditingController _namesController = TextEditingController(
    text: _valueOr(widget.initial.names, 'Valentina'),
  );
  late final TextEditingController _lastNamesController = TextEditingController(
    text: _valueOr(widget.initial.lastNames, 'Restrepo Duque'),
  );
  late final TextEditingController _birthController = TextEditingController(
    text: _valueOr(widget.initial.birthDate, '14 / 09 / 1995'),
  );
  late final TextEditingController _phoneController = TextEditingController(
    text: _valueOr(widget.initial.phone, '315 892 4110'),
  );
  late final TextEditingController _emailController = TextEditingController(
    text: widget.initial.email,
  );
  late String _docType = widget.initial.documentType.isEmpty
      ? 'C.C.'
      : widget.initial.documentType;
  late DateTime? _birthDate =
      widget.isEdit ? DateTime(1995, 9, 14) : null;

  String _valueOr(String value, String fallback) {
    if (value.isNotEmpty) return value;
    return widget.isEdit ? fallback : '';
  }

  Future<void> _pickDocType() async {
    final String? picked = await showAppOptionPicker(
      context,
      title: 'Tipo de documento',
      options: const <String>['C.C.', 'C.E.', 'Pasaporte', 'TI'],
      selected: _docType,
    );
    if (picked != null) setState(() => _docType = picked);
  }

  Future<void> _pickBirthDate() async {
    final DateTime? picked = await pickAppDate(
      context,
      initial: _birthDate ?? DateTime(1995, 9, 14),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthController.text = formatAppDate(picked);
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (_docController.text.trim().isEmpty) {
      _showError('Ingresa el documento de identidad.');
      return;
    }
    if (_namesController.text.trim().isEmpty) {
      _showError('Ingresa los nombres del cliente.');
      return;
    }
    if (_lastNamesController.text.trim().isEmpty) {
      _showError('Ingresa los apellidos del cliente.');
      return;
    }
    if (_phoneController.text.trim().length < 7) {
      _showError('Ingresa un número de celular válido.');
      return;
    }
    final body = <String,dynamic>{'documento':_docController.text.replaceAll(RegExp(r'\D'),''),'nombres':_namesController.text.trim(),'apellidos':_lastNamesController.text.trim(),'celular':_phoneController.text.replaceAll(RegExp(r'\D'),''),'correo':_emailController.text.trim()};
    if (_birthDate != null) body['fechaNacimiento']='${_birthDate!.year.toString().padLeft(4,'0')}-${_birthDate!.month.toString().padLeft(2,'0')}-${_birthDate!.day.toString().padLeft(2,'0')}';
    try {
      final response = widget.isEdit
          ? await AuraApi.updateClient(widget.initial.id, body)
          : await AuraApi.createClient(body);
      if (!mounted) return;
      if (!response.isSuccess) { _showError(response.message ?? 'No se pudo guardar el cliente.'); return; }
      Navigator.of(context).pushReplacementNamed(AppRoutes.clientsSaved);
    } on ApiException catch (e) { if (mounted) _showError(e.message); }
  }

  @override
  void dispose() {
    _docController.dispose();
    _namesController.dispose();
    _lastNamesController.dispose();
    _birthController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w700,
      fontSize: 11,
      height: 14 / 11,
      letterSpacing: 0.33,
      color: AppColors.textPrimary,
    );
    final TextStyle helperStyle = TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w500,
      fontSize: 10,
      height: 14 / 10,
      color: AppColors.textSecondaryMuted,
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: Column(
        children: [
          const AppAdminTopBar(title: 'Aura Stylist', section: ''),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _Badge(
                        label: widget.isEdit ? 'Ficha #CLI-089' : 'Nuevo',
                        accent: !widget.isEdit,
                      ),
                      if (widget.isEdit) ...[
                        const SizedBox(width: 6),
                        const _Badge(label: 'Modo Edición', accent: false),
                      ],
                      const Spacer(),
                      Flexible(
                        child: Text(
                          '* Campos obligatorios',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: helperStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isEdit ? 'Editar Cliente' : 'Nuevo Cliente',
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      height: 32 / 24,
                      letterSpacing: -0.24,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    widget.isEdit
                        ? 'Actualiza el expediente clínico, dermocosmético y '
                              'de estilismo personalizado.'
                        : 'Registra los datos del cliente para asociarlo a sus '
                              'reservas.',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 18 / 13,
                      color: AppColors.textSecondaryMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppFormSection(
                    icon: Icons.badge_outlined,
                    title: 'Identidad y Documento',
                    children: [
                      Row(
                        children: [
                          Text('Documento de identidad', style: labelStyle),
                          Text(
                            ' *',
                            style: labelStyle.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _pickDocType,
                            child: Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryButtonSurface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _docType,
                                    style: TextStyle(
                                      fontFamily: AppFonts.body,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.expand_more,
                                    size: 16,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppTextField(
                              label: '',
                              controller: _docController,
                              hintText: 'Número de documento',
                              hintColor: AppColors.hintOnWhite,
                              fillColor: AppColors.background,
                              borderRadius: 12,
                              minHeight: 52,
                              textColor: AppColors.textPrimary,
                              suffixIcon: widget.isEdit
                                  ? const Icon(
                                      Icons.check_circle,
                                      size: 17,
                                      color: AppColors.accentDark,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      if (widget.isEdit)
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 13,
                              color: AppColors.accentDark,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Documento único validado en Registraduría / '
                                'Sistema.',
                                style: helperStyle,
                              ),
                            ),
                          ],
                        ),
                      AppTextField(
                        label: 'NOMBRES',
                        labelSuffix: Text(
                          ' *',
                          style: labelStyle.copyWith(color: AppColors.danger),
                        ),
                        labelStyle: labelStyle,
                        controller: _namesController,
                        hintText: 'Nombres',
                        hintColor: AppColors.hintOnWhite,
                        fillColor: AppColors.background,
                        borderRadius: 12,
                        minHeight: 52,
                        textColor: AppColors.textPrimary,
                      ),
                      AppTextField(
                        label: 'APELLIDOS',
                        labelSuffix: Text(
                          ' *',
                          style: labelStyle.copyWith(color: AppColors.danger),
                        ),
                        labelStyle: labelStyle,
                        controller: _lastNamesController,
                        hintText: 'Apellidos',
                        hintColor: AppColors.hintOnWhite,
                        fillColor: AppColors.background,
                        borderRadius: 12,
                        minHeight: 52,
                        textColor: AppColors.textPrimary,
                      ),
                      AppTextField(
                        label: 'Fecha de Nacimiento',
                        labelStyle: labelStyle,
                        controller: _birthController,
                        hintText: 'dd / mm / aaaa',
                        hintColor: AppColors.hintOnWhite,
                        fillColor: AppColors.background,
                        borderRadius: 12,
                        minHeight: 52,
                        textColor: AppColors.textPrimary,
                        readOnly: true,
                        onTap: _pickBirthDate,
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.isEdit
                                  ? 'No se permiten fechas futuras · '
                                        'Verificado (29 años)'
                                  : 'No se permiten fechas futuras',
                              style: helperStyle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppFormSection(
                    icon: Icons.phone_iphone_outlined,
                    title: 'Canales de Contacto',
                    children: [
                      Text('Celular / Teléfono', style: labelStyle),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryButtonSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+57',
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppTextField(
                              label: '',
                              controller: _phoneController,
                              hintText: 'Número de celular',
                              hintColor: AppColors.hintOnWhite,
                              fillColor: AppColors.background,
                              borderRadius: 12,
                              minHeight: 52,
                              textColor: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Correo electrónico',
                        labelStyle: labelStyle,
                        controller: _emailController,
                        hintText: 'cliente@correo.com',
                        hintColor: AppColors.hintOnWhite,
                        fillColor: AppColors.background,
                        borderRadius: 12,
                        minHeight: 52,
                        textColor: AppColors.textPrimary,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Se utiliza para confirmaciones automáticas de '
                              'cita por WhatsApp.',
                              style: helperStyle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppFormActions(
            primaryLabel: 'Guardar cliente',
            primaryIcon: Icons.check,
            onCancel: () => Navigator.of(context).maybePop(),
            onPrimary: _save,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.accent});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent
            ? AppColors.overlayGreen40
            : AppColors.secondaryButtonSurface,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (accent) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              height: 14 / 11,
              letterSpacing: 0.33,
              color: AppColors.buttonLabelDark,
            ),
          ),
        ],
      ),
    );
  }
}
