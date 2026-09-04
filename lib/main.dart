import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'data/models/epic.dart';
import 'data/models/display_list.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(EpicAdapter());
  Hive.registerAdapter(DisplayListAdapter());

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  final appProvider = AppProvider();
  await appProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: appProvider),
      ],
      child: const EpicListsApp(),
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
      home: const HomeScreen(),
    );
  }
}
