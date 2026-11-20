import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/settings_provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/worker_controller.dart';
import 'controllers/booking_controller.dart';
import 'models/service.dart';
import 'views/auth/splash_screen.dart';
import 'views/home/home_screen.dart';
import 'views/category/category_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CategoryController()),
        ChangeNotifierProvider(create: (_) => WorkerController()),
        ChangeNotifierProvider(create: (_) => BookingController()),
      ],
      child: const CoopGigApp(),
    ),
  );
}

class CoopGigApp extends StatelessWidget {
  const CoopGigApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'CoopGig',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      locale: settings.locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      onGenerateRoute: (routeSettings) {
        final rawName = routeSettings.name ?? '/';
        final uri = Uri.parse(rawName);

        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'category') {
          final catName = uri.pathSegments.length > 1
              ? Uri.decodeComponent(uri.pathSegments[1])
              : 'Cleaning';
          final idMap = {'Cleaning': 1, 'Electrical': 2, 'Plumbing': 3, 'Carpentry': 4};
          final catId = idMap[catName] ?? 1;
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (_) => CategoryScreen(
              category: CategoryItem(id: catId, name: catName),
            ),
          );
        }

        if (rawName == '/home') {
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (_) => const HomeScreen(),
          );
        }

        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const SplashScreen(),
        );
      },
    );
  }
}
