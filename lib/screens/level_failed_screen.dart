import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../widgets/animated_panel.dart';
import '../widgets/game_button.dart';

class LevelFailedScreen extends StatelessWidget {
  const LevelFailedScreen({
    super.key,
    required this.visible,
    required this.levelId,
    required this.targetMoves,
    required this.onRetry,
    required this.onMenu,
  });

  final bool visible;
  final int levelId;
  final int targetMoves;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: visible ? 1 : 0,
        child: Container(
          color: Colors.black.withValues(alpha: 0.68),
          child: Center(
            child: AnimatedPanel(
              visible: visible,
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.close_rounded, color: kLock, size: 42),
                    const SizedBox(height: 12),
                    Text(
                      'Level Failed',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Level $levelId',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You went over the shortest solution target of $targetMoves moves.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kTextSecondary, height: 1.35),
                    ),
                    const SizedBox(height: 18),
                    GameButton(
                      label: 'Try Again',
                      icon: Icons.restart_alt_rounded,
                      backgroundColor: kAccent2,
                      foregroundColor: Colors.black,
                      onPressed: onRetry,
                    ),
                    const SizedBox(height: 12),
                    GameButton(
                      label: 'Main Menu',
                      icon: Icons.home_rounded,
                      backgroundColor: kSurfaceLight,
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
