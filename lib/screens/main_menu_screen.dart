import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:upgrader/upgrader.dart';

import '../game/services/progress_service.dart';
import '../monetization/update_service.dart';
import '../utils/constants.dart';
import '../widgets/coin_display.dart';
import '../widgets/game_button.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProgressService progress = context.watch<ProgressService>();
    final int resumeLevel = progress.lastPlayedLevelId.clamp(1, 9999).toInt();
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: kBackgroundGradient,
          ),
        ),
        child: Stack(
          children: <Widget>[
            const _MenuUpdatePrompt(),
            const _FloatingBackdrop(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(kPagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        CoinDisplay(coins: progress.coins),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: <Widget>[
                        Text(
                          kGameTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: kTextPrimary,
                                fontSize: 40,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Move. Slide. Escape.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _HowToPlayCard(
                      onPressed: () => _showHowToPlay(context),
                    ),
                    const SizedBox(height: 24),
                    GameButton(
                      label: progress.highestUnlockedLevel > 1 ? 'Resume' : 'Play',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => context.go('/game?level=$resumeLevel'),
                    ),
                    const SizedBox(height: 14),
                    GameButton(
                      label: 'Level Select',
                      icon: Icons.grid_view_rounded,
                      backgroundColor: kAccent2,
                      foregroundColor: Colors.black,
                      onPressed: () => context.go('/levels'),
                    ),
                    const SizedBox(height: 14),
                    GameButton(
                      label: 'Settings',
                      icon: Icons.settings_rounded,
                      backgroundColor: kSurfaceLight,
                      foregroundColor: kTextPrimary,
                      onPressed: () => context.go('/settings'),
                    ),
                    const SizedBox(height: 14),
                    GameButton(
                      label: 'Share App',
                      icon: Icons.share_rounded,
                      backgroundColor: const Color(0xFF394A63),
                      foregroundColor: kTextPrimary,
                      onPressed: () => _shareApp(context),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        kVersionLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: kTextSecondary.withValues(alpha: 0.75),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _shareApp(BuildContext context) async {
  final ShareResult result = await SharePlus.instance.share(
    ShareParams(
      text: 'I am playing Block Escape Quest. '
          'It is a fun block puzzle game for all ages. '
          'Search "Block Escape Quest" on the App Store or Google Play and try to beat my levels!',
      subject: 'Block Escape Quest',
      title: 'Share Block Escape Quest',
    ),
  );
  if (!context.mounted || result.status == ShareResultStatus.dismissed) {
    return;
  }
}

void _showHowToPlay(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kPagePadding),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.school_rounded, color: kAccent),
                    const SizedBox(width: 10),
                    Text(
                      'How to Play Like a Pro',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _GuideStep(
                  number: '1',
                  title: 'Find the hero block',
                  body: 'The red/orange block is the one you need to escape.',
                ),
                const SizedBox(height: 10),
                const _GuideStep(
                  number: '2',
                  title: 'Drag with purpose',
                  body: 'Only move blocks along their own axis. Use short, precise drags to open a path.',
                ),
                const SizedBox(height: 10),
                const _GuideStep(
                  number: '3',
                  title: 'Clear the exit lane',
                  body: 'Move blockers out of the hero row, then slide the hero to the right edge.',
                ),
                const SizedBox(height: 10),
                const _GuideStep(
                  number: '4',
                  title: 'Use smart tools',
                  body: 'Undo fixes mistakes, Reset restarts the board, and Watch Ad gives a hint when you are stuck.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pro tip: solve from the exit backwards. Identify which block is stopping the hero, then free that block first.',
                  style: TextStyle(color: kTextSecondary, height: 1.4),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: GameButton(
                    label: 'Got it',
                    icon: Icons.check_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _HowToPlayCard extends StatelessWidget {
  const _HowToPlayCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(kCardRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Icon(Icons.tips_and_updates_rounded, color: kAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'New here?',
                  style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Learn the goal, drag rules, and a pro strategy before you start.',
            style: TextStyle(color: kTextSecondary, height: 1.35),
          ),
          const SizedBox(height: 12),
          GameButton(
            label: 'How to Play',
            icon: Icons.menu_book_rounded,
            backgroundColor: kAccent2,
            foregroundColor: Colors.black,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurfaceLight.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 14,
            backgroundColor: kAccent,
            child: Text(
              number,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: kTextSecondary, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuUpdatePrompt extends StatefulWidget {
  const _MenuUpdatePrompt();

  @override
  State<_MenuUpdatePrompt> createState() => _MenuUpdatePromptState();
}

class _MenuUpdatePromptState extends State<_MenuUpdatePrompt> {
  static bool _shownThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _showIfNeeded();
    });
  }

  Future<void> _showIfNeeded() async {
    if (!mounted || _shownThisSession) {
      return;
    }

    final Upgrader upgrader = UpdateService.instance.upgrader;
    if (!upgrader.shouldDisplayUpgrade()) {
      return;
    }

    _shownThisSession = true;
    await upgrader.saveLastAlerted();

    if (!mounted) {
      return;
    }

    final UpgraderMessages messages = upgrader.determineMessages(context);
    final String title = messages.message(UpgraderMessage.title) ?? 'Update available';
    final String body = upgrader.body(messages);
    final String? releaseNotes = upgrader.releaseNotes;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(body),
                  if (releaseNotes != null && releaseNotes.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      messages.message(UpgraderMessage.releaseNotes) ?? 'Release notes',
                      style: Theme.of(dialogContext).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(releaseNotes),
                  ],
                ],
              ),
            ),
            actions: <Widget>[
              FilledButton(
                onPressed: () async {
                  await upgrader.sendUserToAppStore();
                },
                child: Text(
                  messages.message(UpgraderMessage.buttonTitleUpdate) ?? 'Update now',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _FloatingBackdrop extends StatefulWidget {
  const _FloatingBackdrop();

  @override
  State<_FloatingBackdrop> createState() => _FloatingBackdropState();
}

class _FloatingBackdropState extends State<_FloatingBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          children: <Widget>[
            Positioned(
              left: 36 + 10 * _controller.value,
              top: 90,
              child: _orb(72, const Color(0xFF4DD6C2).withValues(alpha: 0.10)),
            ),
            Positioned(
              right: 18,
              top: 160 + 18 * (1 - _controller.value),
              child: _orb(110, const Color(0xFFFFA24A).withValues(alpha: 0.08)),
            ),
            Positioned(
              left: 32,
              bottom: 120 + 14 * _controller.value,
              child: _orb(88, const Color(0xFF6AA4FF).withValues(alpha: 0.10)),
            ),
          ],
        );
      },
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}
