import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/sound_service.dart';
import '../utils/app_colors.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/nav_icon_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/mesh_background.dart';

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
    if (!mounted) return;
    setState(() => _currentFormat = format);
  }

  Future<void> _toggleSound(bool value) async {
    await PreferencesService.setSoundEnabled(value);
    if (!value) await SoundService.stop(); // Cut off any audio already playing
    if (!mounted) return;
    setState(() => _soundEnabled = value);
  }

  void _confirmResetProgress() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Progress?'),
        content: const Text(
          'Are you sure you want to clear all your learning progress? This cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Grab what we need from the screen's context BEFORE any await.
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);
              await PreferencesService.resetProgress();
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(
                    content: Text('Progress reset successfully!')),
              );
            },
            child: const Text('Reset',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// One selectable row of the audio-format "radio group". Built from a
  /// ListTile + icon instead of Radio, whose groupValue/onChanged API is
  /// deprecated in recent Flutter versions (replaced by RadioGroup).
  Widget _buildFormatTile({
    required String title,
    required String subtitle,
    required AudioFormat format,
  }) {
    final selected = _currentFormat == format;
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      enabled: _soundEnabled,
      selected: selected,
      selectedColor: AppColors.primaryLight,
      trailing: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: !_soundEnabled
            ? AppColors.white(0.25)
            : (selected ? AppColors.primaryLight : AppColors.white(0.7)),
      ),
      onTap: _soundEnabled ? () => _toggleAudioFormat(format) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      bottomNavigationBar: const BannerAdWidget(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
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
                            color: AppColors.onGlass,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // ---- Sound Section ----
                    const Text(
                      'Sound',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onGlass),
                    ),
                    const SizedBox(height: 16),
                    GlassContainer(
                      borderRadius: 16,
                      blur: 14,
                      darkMaterial: true,
                      child: Column(
                        children: [
                          // Master sound on/off
                          SwitchListTile(
                            title: const Text('Sound Effects'),
                            subtitle: const Text('Play letter sounds and feedback'),
                            value: _soundEnabled,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.primary,
                            inactiveThumbColor: AppColors.white(0.7),
                            inactiveTrackColor: AppColors.white(0.12),
                            trackOutlineColor:
                                WidgetStatePropertyAll(AppColors.white(0.25)),
                            onChanged: _toggleSound,
                          ),
                          const Divider(height: 1),
                          // Audio format (only relevant when sound is on)
                          _buildFormatTile(
                            title: 'Short Audio',
                            subtitle: 'Plays the quick letter sound',
                            format: AudioFormat.short,
                          ),
                          const Divider(height: 1),
                          _buildFormatTile(
                            title: 'Long Audio',
                            subtitle: 'Plays expanded pronunciation',
                            format: AudioFormat.long,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ---- Data Section ----
                    const Text(
                      'Account & Data',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onGlass),
                    ),
                    const SizedBox(height: 16),
                    GlassContainer(
                      borderRadius: 16,
                      blur: 14,
                      darkMaterial: true,
                      child: ListTile(
                        title: const Text('Reset All Progress',
                            style: TextStyle(
                                color: AppColors.glassWrong,
                                fontWeight: FontWeight.bold)),
                        subtitle: const Text(
                            'Clear all learned letters, stars and streak'),
                        trailing: const Icon(Icons.delete_forever,
                            color: AppColors.glassWrong),
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
