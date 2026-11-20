# Aura Stylist

Aplicación móvil Flutter para la gestión de clientes, servicios, profesionales, agenda, reservas, cierres y comisiones.

## Guía de estudio

Consulta [GUIA_ESTUDIO.md](GUIA_ESTUDIO.md) para ver la arquitectura del código, la navegación pantalla por pantalla, servicios y endpoints API, manejo del token, almacenamiento local, modelos, tema y widgets.

## Ejecutar

Requiere Flutter y Dart compatibles con la versión declarada en `pubspec.yaml`.

```powershell
flutter pub get
flutter run
```

La URL de API configurada por defecto está en `lib/config/app_config.dart`. Para usar otro servidor:

```powershell
flutter run --dart-define=API_BASE_URL=https://servidor-de-pruebas
```
