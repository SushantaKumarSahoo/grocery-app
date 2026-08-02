import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/config/supabase_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/order_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  // Loaded before runApp so the correct theme paints on the very first
  // frame — no flash of light mode while a saved dark preference loads.
  final savedThemeMode = await AppThemeProvider.loadSavedMode();
  runApp(MainApp(initialThemeMode: savedThemeMode));
}

class MainApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  const MainApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => AppThemeProvider(initialMode: initialThemeMode)),
      ],
      child: const _AppRoot(),
    );
  }
}

/// Builds the GoRouter exactly once. GoRouter already listens to
/// AuthProvider via `refreshListenable` to re-evaluate redirects — it must
/// never be reconstructed on provider changes (that used to happen on every
/// notifyListeners(), including trivial ones like a failed login or a theme
/// toggle), since a brand-new GoRouter means a brand-new Navigator, which
/// wiped all screen state and looked like the whole app was reloading.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  late final GoRouter _router = AppRouter.build(context.read<AuthProvider>());

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<AppThemeProvider>();
    return MaterialApp.router(
      title: 'BulkMart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.mode,
      routerConfig: _router,
    );
  }
}
