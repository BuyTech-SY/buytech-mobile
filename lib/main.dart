import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/state/app_settings.dart';
import 'data/services/storage_service.dart';
import 'ui/dashboard/dashboard_screen.dart';
import 'ui/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.init();
  final isLoggedIn = await StorageService.isLoggedIn();
  runApp(AccessApp(isLoggedIn: isLoggedIn));
}

class AccessApp extends StatelessWidget {
  final bool isLoggedIn;
  const AccessApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettings.themeModeNotifier,
      builder: (context, currentThemeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: AppSettings.localeNotifier,
          builder: (context, currentLocale, _) {
            return MaterialApp(
              title: 'Access Cards',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentThemeMode,
              locale: currentLocale,
              supportedLocales: const [
                Locale('ar', 'SA'),
                Locale('en', 'US'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
            );
          },
        );
      },
    );
  }
}
