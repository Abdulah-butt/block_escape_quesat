import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../widgets/animated_panel.dart';
import '../widgets/game_button.dart';

class PauseMenu extends StatelessWidget {
  const PauseMenu({
    super.key,
    required this.visible,
    required this.onResume,
    required this.onRestart,
    required this.onLevels,
    required this.onMenu,
  });

  final bool visible;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onLevels;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: visible ? 1 : 0,
        child: Container(
          color: Colors.black.withValues(alpha: 0.58),
          child: Center(
            child: AnimatedPanel(
              visible: visible,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Paused', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 18),
                    GameButton(label: 'Resume', icon: Icons.play_arrow_rounded, onPressed: onResume),
                    const SizedBox(height: 12),
                    GameButton(
                      label: 'Restart',
                      icon: Icons.restart_alt_rounded,
                      backgroundColor: kAccent2,
                      foregroundColor: Colors.black,
                      onPressed: onRestart,
                    ),
                    const SizedBox(height: 12),
                    GameButton(
                      label: 'Level Select',
                      icon: Icons.grid_view_rounded,
                      backgroundColor: kSurfaceLight,
                      foregroundColor: kTextPrimary,
                      onPressed: onLevels,
                    ),
                    const SizedBox(height: 12),
                    GameButton(
                      label: 'Main Menu',
                      icon: Icons.home_rounded,
                      backgroundColor: const Color(0xFF394A63),
                      foregroundColor: kTextPrimary,
                      onPressed: onMenu,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

