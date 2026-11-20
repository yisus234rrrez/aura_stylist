import 'package:flutter/material.dart';

import 'config/app_navigator.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'services/remote/aura_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuraApi.restoreSession();
  runApp(const AuraStylistApp());
}

class AuraStylistApp extends StatelessWidget {
  const AuraStylistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Stylist',
      navigatorKey: appNavigatorKey,
      scaffoldMessengerKey: appMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
