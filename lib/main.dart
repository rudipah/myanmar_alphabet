import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
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
