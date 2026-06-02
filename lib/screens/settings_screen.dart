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

  void _confirmResetProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Reset Progress?"),
        content: const Text(
          "Are you sure you want to clear all your learning progress? This cannot be undone.",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PreferencesService.resetProgress();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Progress reset successfully!")),
              );
            },
            child: const Text("Reset", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
                const SizedBox(height: 30),
                const Text(
                  'Account & Data',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    title: const Text('Reset All Progress', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Clear all learned letters and stars'),
                    trailing: const Icon(Icons.delete_forever, color: Colors.redAccent),
                    onTap: _confirmResetProgress,
                  ),
                ),
              ],
            ),
    );
  }
}
