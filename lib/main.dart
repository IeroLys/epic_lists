import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'data/models/epic.dart';
import 'data/models/display_list.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Hive
  await Hive.initFlutter();
  Hive.registerAdapter(EpicAdapter());
  Hive.registerAdapter(DisplayListAdapter());

  // Инициализация локализации (ОБЯЗАТЕЛЬНО до runApp)
  await EasyLocalization.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  final appProvider = AppProvider();
  await appProvider.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('ru'),
      saveLocale: true, // запоминает выбор пользователя
      useOnlyLangCode: true, // использует только код языка (ru, en)
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: appProvider),
        ],
        child: const EpicListsApp(),
      ),
    ),
  );
}

class EpicListsApp extends StatelessWidget {
  const EpicListsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Epic Lists',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      // Локализация
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const HomeScreen(),
    );
  }
}