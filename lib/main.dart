import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/menu_screen.dart';
import 'services/sound_service.dart';
import 'services/app_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  try {
    await AppInitializer.init();
  } catch (e) {
    debugPrint("Init error: $e");
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
      // theme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color(0xFF6C5CE7),
      //   ),
      // ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
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
