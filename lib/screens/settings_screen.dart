import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AudioFormat _currentFormat = AudioFormat.long;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final format = await PreferencesService.getAudioFormat();
    setState(() {
      _currentFormat = format;
      _isLoading = false;
    });
  }

  Future<void> _toggleAudioFormat(AudioFormat format) async {
    await PreferencesService.setAudioFormat(format);
    setState(() {
      _currentFormat = format;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Audio Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Short Audio'),
                        subtitle: const Text('Plays the quick letter sound'),
                        trailing: Radio<AudioFormat>(
                          value: AudioFormat.short,
                          groupValue: _currentFormat,
                          onChanged: (val) {
                            if (val != null) _toggleAudioFormat(val);
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Long Audio'),
                        subtitle: const Text('Plays expanded pronunciation'),
                        trailing: Radio<AudioFormat>(
                          value: AudioFormat.long,
                          groupValue: _currentFormat,
                          onChanged: (val) {
                            if (val != null) _toggleAudioFormat(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
