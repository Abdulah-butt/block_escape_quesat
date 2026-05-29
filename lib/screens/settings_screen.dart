import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../game/services/progress_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProgressService progress = context.watch<ProgressService>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          context.go('/menu');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/menu'),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(kPagePadding),
          children: <Widget>[
            _ToggleTile(
              title: 'Sound',
              subtitle: 'Game sound effects',
              value: progress.soundEnabled,
              onChanged: (bool value) => progress.setSoundEnabled(value),
            ),
            const SizedBox(height: 12),
            _ToggleTile(
              title: 'Music',
              subtitle: 'Background music',
              value: progress.musicEnabled,
              onChanged: (bool value) => progress.setMusicEnabled(value),
            ),
            const SizedBox(height: 12),
            _ToggleTile(
              title: 'Vibration',
              subtitle: 'Haptic feedback',
              value: progress.vibrationEnabled,
              onChanged: (bool value) => progress.setVibrationEnabled(value),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: kTextPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(color: kTextSecondary)),
        value: value,
        activeThumbColor: kAccent,
        onChanged: onChanged,
      ),
    );
  }
}
