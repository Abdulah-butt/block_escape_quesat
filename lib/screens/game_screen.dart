import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../game/block_escape_game.dart';
import '../game/services/game_state_service.dart';
import '../utils/constants.dart';
import '../widgets/coin_display.dart';
import 'level_complete_screen.dart';
import 'level_failed_screen.dart';
import 'pause_menu.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.levelId});

  final int levelId;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameStateService _state;
  late final BlockEscapeGame _game;
  bool _flash = false;
  bool _completionHandled = false;
  int? _loadedLevelId;

  @override
  void initState() {
    super.initState();
    _state = context.read<GameStateService>();
    _game = BlockEscapeGame(state: _state);
    _state.addListener(_onStateChanged);
    _loadLevel(widget.levelId);
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelId != widget.levelId) {
      _completionHandled = false;
      _flash = false;
      _loadLevel(widget.levelId);
    }
  }

  void _loadLevel(int levelId) {
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if (!mounted) {
        return;
      }
      if (_loadedLevelId == levelId) {
        return;
      }
      _loadedLevelId = levelId;
      _state.startLevel(levelId);
    });
  }

  void _onStateChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
    if (_state.completed && !_completionHandled) {
      _completionHandled = true;
      setState(() => _flash = true);
      Future<void>.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() => _flash = false);
        }
      });
    }
  }

  Future<void> _showHint() async {
    final bool shown = await _state.showHint();
    if (!shown && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hint available right now')),
      );
    }
  }

  void _gotoMenu() => context.go('/menu');
  void _gotoLevels() => context.go('/levels');
  void _showInfo() {
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
                      const Icon(Icons.info_rounded, color: kAccent),
                      const SizedBox(width: 10),
                      Text(
                        'Quick Tips',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _InfoTip(
                    title: 'Goal',
                    body: 'Move the red/orange hero block to the exit on the right.',
                  ),
                  const SizedBox(height: 10),
                  const _InfoTip(
                    title: 'Drag',
                    body: 'Blocks slide only in their own direction. Use short, smooth drags.',
                  ),
                  const SizedBox(height: 10),
                  const _InfoTip(
                    title: 'Strategy',
                    body: 'Free the blocks blocking the hero row first, then clear the lane.',
                  ),
                  const SizedBox(height: 10),
                  const _InfoTip(
                    title: 'Rewards',
                    body: 'You earn rewards only the first time you clear a level or improve your best stars.',
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: kTextPrimary,
                      style: IconButton.styleFrom(
                        backgroundColor: kSurfaceLight,
                      ),
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

  void _restart() {
    _completionHandled = false;
    _state.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (_state.error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            _state.error!,
            style: const TextStyle(color: kTextPrimary),
          ),
        ),
      );
    }

    final level = _state.level;
    if (level == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(kPagePadding),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Level ${level.id}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Moves: ${_state.moveCount}  |  Target (shortest): ${level.targetMoves}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  CoinDisplay(coins: _state.progressService.coins, compact: true),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      _state.setPaused(true);
                    },
                    icon: const Icon(Icons.pause_rounded),
                    color: kTextPrimary,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  GameWidget(
                    game: _game,
                    backgroundBuilder: (BuildContext context) => const SizedBox.expand(),
                  ),
                  if (_flash)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 100),
                          opacity: _flash ? 0.72 : 0,
                          child: Container(color: Colors.white),
                        ),
                      ),
                    ),
                  PauseMenu(
                    visible: _state.paused,
                    onResume: () => _state.setPaused(false),
                    onRestart: _restart,
                    onLevels: _gotoLevels,
                    onMenu: _gotoMenu,
                  ),
                  LevelCompleteScreen(
                    visible: _state.completed,
                    levelId: level.id,
                    moves: _state.moveCount,
                    targetMoves: level.targetMoves,
                    stars: _state.earnedStars,
                    coinsEarned: _state.earnedCoins,
                    onNext: () {
                      final int nextLevel = level.id + 1;
                      _completionHandled = false;
                      if (_state.levelLoader.byId(nextLevel) == null) {
                        context.go('/menu');
                      } else {
                        context.go('/game?level=$nextLevel');
                      }
                    },
                    onRetry: () {
                      _completionHandled = false;
                      _state.reset();
                    },
                    onMenu: _gotoMenu,
                  ),
                  LevelFailedScreen(
                    visible: _state.failed,
                    levelId: level.id,
                    targetMoves: level.targetMoves,
                    onRetry: _restart,
                    onMenu: _gotoMenu,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kPagePadding),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _GameIconActionButton(
                      tooltip: 'Reset',
                      icon: Icons.restart_alt_rounded,
                      backgroundColor: kSurfaceLight,
                      iconColor: Colors.white,
                      onPressed: _restart,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GameIconActionButton(
                      tooltip: 'Undo',
                      icon: Icons.undo_rounded,
                      backgroundColor: _state.canUndo ? kAccent2 : Colors.white24,
                      iconColor: Colors.white,
                      onPressed: _state.canUndo
                          ? () {
                              _state.undo();
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GameIconActionButton(
                      tooltip: 'Hint',
                      icon: Icons.lightbulb_rounded,
                      backgroundColor: kAccent,
                      iconColor: Colors.white,
                      onPressed: _showHint,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GameIconActionButton(
                      tooltip: 'Info',
                      icon: Icons.info_rounded,
                      backgroundColor: kSurfaceLight,
                      iconColor: Colors.white,
                      onPressed: _showInfo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameIconActionButton extends StatefulWidget {
  const _GameIconActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;

  @override
  State<_GameIconActionButton> createState() => _GameIconActionButtonState();
}

class _GameIconActionButtonState extends State<_GameIconActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    final Color background = enabled ? widget.backgroundColor : Colors.white24;
    final Color iconColor = enabled ? widget.iconColor : Colors.white.withValues(alpha: 0.42);
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        enabled: enabled,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 80),
          scale: _pressed ? 0.96 : 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
              onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
              onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
              onTap: widget.onPressed,
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: enabled ? 0.08 : 0.12),
                  ),
                ),
                child: Center(
                  child: Icon(widget.icon, color: iconColor, size: 28),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTip extends StatelessWidget {
  const _InfoTip({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurfaceLight.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: kTextPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              color: kTextSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
