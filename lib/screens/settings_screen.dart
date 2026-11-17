import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/sound_service.dart';
import '../utils/app_colors.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/nav_icon_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AudioFormat _currentFormat = AudioFormat.long;
  bool _soundEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final format = await PreferencesService.getAudioFormat();
    final soundEnabled = await PreferencesService.isSoundEnabled();
    if (mounted) {
      setState(() {
        _currentFormat = format;
        _soundEnabled = soundEnabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAudioFormat(AudioFormat format) async {
    await PreferencesService.setAudioFormat(format);
    setState(() => _currentFormat = format);
  }

  Future<void> _toggleSound(bool value) async {
    await PreferencesService.setSoundEnabled(value);
    if (!value) await SoundService.stop(); // Cut off any audio already playing
    setState(() => _soundEnabled = value);
  }

  void _confirmResetProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Progress?'),
        content: const Text(
          'Are you sure you want to clear all your learning progress? This cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PreferencesService.resetProgress();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Progress reset successfully!')),
                );
              }
            },
            child: const Text('Reset',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEFF),
      bottomNavigationBar: const BannerAdWidget(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    // ---- Header (matches all other screens) ----
                    Row(
                      children: [
                        NavIconButton(
                          icon: Icons.arrow_back_ios_rounded,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2D2D4E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // ---- Sound Section ----
                    const Text(
                      'Sound',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          // Master sound on/off
                          SwitchListTile(
                            title: const Text('Sound Effects'),
                            subtitle: const Text('Play letter sounds and feedback'),
                            value: _soundEnabled,
                            activeColor: AppColors.primary,
                            onChanged: _toggleSound,
                          ),
                          const Divider(height: 1),
                          // Audio format (only relevant when sound is on)
                          ListTile(
                            title: const Text('Short Audio'),
                            subtitle: const Text('Plays the quick letter sound'),
                            enabled: _soundEnabled,
                            trailing: Radio<AudioFormat>(
                              value: AudioFormat.short,
                              groupValue: _currentFormat,
                              onChanged: _soundEnabled
                                  ? (val) {
                                      if (val != null) _toggleAudioFormat(val);
                                    }
                                  : null,
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: const Text('Long Audio'),
                            subtitle:
                                const Text('Plays expanded pronunciation'),
                            enabled: _soundEnabled,
                            trailing: Radio<AudioFormat>(
                              value: AudioFormat.long,
                              groupValue: _currentFormat,
                              onChanged: _soundEnabled
                                  ? (val) {
                                      if (val != null) _toggleAudioFormat(val);
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ---- Data Section ----
                    const Text(
                      'Account & Data',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: const Text('Reset All Progress',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold)),
                        subtitle: const Text(
                            'Clear all learned letters, stars and streak'),
                        trailing: const Icon(Icons.delete_forever,
                            color: Colors.redAccent),
                        onTap: _confirmResetProgress,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
