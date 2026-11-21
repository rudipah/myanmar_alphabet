import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/menu_screen.dart';
import 'services/app_initializer.dart';
import 'data/data_loader.dart';
import 'utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // All initialisation (AdMob, Unity Ads, Sound) is done in one place
  try {
    await AppInitializer.init();
  } catch (e) {
    debugPrint('Init error: $e');
  }

  // Load letter / number / flashcard data from JSON assets
  try {
    await DataLoader.init();
    debugPrint('Data loaded from JSON successfully!');
  } catch (e) {
    debugPrint('DataLoader init error (using fallback): $e');
  }

  runApp(const MyanmarAlphabetApp());
}

class MyanmarAlphabetApp extends StatelessWidget {
  const MyanmarAlphabetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn Myanmar Alphabet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: const MenuScreen(),
    );
  }
}
