import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../widgets/animated_panel.dart';
import '../widgets/game_button.dart';
import '../widgets/star_display.dart';

class LevelCompleteScreen extends StatefulWidget {
  const LevelCompleteScreen({
    super.key,
    required this.visible,
    required this.levelId,
    required this.moves,
    required this.targetMoves,
    required this.stars,
    required this.coinsEarned,
    required this.onNext,
    required this.onRetry,
    required this.onMenu,
  });

  final bool visible;
  final int levelId;
  final int moves;
  final int targetMoves;
  final int stars;
  final int coinsEarned;
  final VoidCallback onNext;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with TickerProviderStateMixin {
  late final ConfettiController _confettiController;
  late final AnimationController _titleController;
  int _visibleStars = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _kickoff();
  }

  @override
  void didUpdateWidget(covariant LevelCompleteScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _kickoff();
    }
  }

  void _kickoff() {
    if (!widget.visible) {
      return;
    }
    _titleController.forward(from: 0);
    if (widget.stars == 3) {
      _confettiController.play();
    }
    _visibleStars = 0;
    for (int index = 0; index < widget.stars; index++) {
      Future<void>.delayed(Duration(milliseconds: 150 * index), () {
        if (mounted) {
          setState(() => _visibleStars = index + 1);
        }
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.visible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: widget.visible ? 1 : 0,
        child: Container(
          color: Colors.black.withValues(alpha: 0.68),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  emissionFrequency: 0.08,
                  numberOfParticles: 16,
                  gravity: 0.18,
                  colors: const <Color>[kAccent, kAccent2, Colors.white],
                ),
              ),
              Center(
                child: AnimatedPanel(
                  visible: widget.visible,
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
                        ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _titleController,
                            curve: Curves.elasticOut,
                          ),
                          child: Text(
                            'Level Complete!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Level ${widget.levelId}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(3, (int index) {
                            final bool visible = index < _visibleStars;
                            return AnimatedScale(
                              duration: const Duration(milliseconds: 180),
                              scale: visible ? 1 : 0.2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Icon(
                                  visible ? Icons.star_rounded : Icons.star_border_rounded,
                                  color: visible ? const Color(0xFFFFD54A) : Colors.white.withValues(alpha: 0.22),
                                  size: 34,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        StarDisplay(stars: widget.stars),
                        const SizedBox(height: 10),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: widget.coinsEarned),
                          duration: const Duration(milliseconds: 500),
                          builder: (BuildContext context, int value, Widget? child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Icon(Icons.monetization_on_rounded, color: kAccent, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  '+$value coins',
                                  style: const TextStyle(
                                    color: kTextPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        GameButton(
                          label: 'Next Level',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: widget.onNext,
                        ),
                        const SizedBox(height: 12),
                        GameButton(
                          label: 'Retry',
                          icon: Icons.restart_alt_rounded,
                          backgroundColor: kAccent2,
                          foregroundColor: Colors.black,
                          onPressed: widget.onRetry,
                        ),
                        const SizedBox(height: 12),
                        GameButton(
                          label: 'Main Menu',
                          icon: Icons.home_rounded,
                          backgroundColor: kSurfaceLight,
                          foregroundColor: kTextPrimary,
                          onPressed: widget.onMenu,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

