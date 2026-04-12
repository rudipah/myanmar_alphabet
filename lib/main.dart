import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize AdMob on Android/iOS — NOT on web
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }

  runApp(const MyanmarAlphabetApp());
}

class MyanmarAlphabetApp extends StatelessWidget {
  const MyanmarAlphabetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myanmar Alphabet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
