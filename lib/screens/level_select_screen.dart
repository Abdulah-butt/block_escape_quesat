import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../game/services/level_loader.dart';
import '../game/services/progress_service.dart';
import '../utils/constants.dart';
import '../widgets/star_display.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProgressService progress = context.watch<ProgressService>();
    final List<LevelModelWrapper> levels = LevelLoader.instance.levels
        .map((level) => LevelModelWrapper(level.id))
        .toList(growable: false);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          context.go('/menu');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose Level'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/menu'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(kPagePadding),
          child: GridView.builder(
            itemCount: levels.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.92,
            ),
            itemBuilder: (BuildContext context, int index) {
              final int levelId = levels[index].id;
              final bool unlocked = progress.isLevelUnlocked(levelId);
              final int stars = progress.starsForLevel(levelId);
              return _LevelCard(
                levelId: levelId,
                stars: stars,
                unlocked: unlocked,
                onTap: () {
                  if (!unlocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Complete previous level')),
                    );
                    return;
                  }
                  context.go('/game?level=$levelId');
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class LevelModelWrapper {
  const LevelModelWrapper(this.id);

  final int id;
}

class _LevelCard extends StatefulWidget {
  const _LevelCard({
    required this.levelId,
    required this.stars,
    required this.unlocked,
    required this.onTap,
  });

  final int levelId;
  final int stars;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.unlocked
          ? widget.onTap
          : () {
              _controller.forward(from: 0);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Complete previous level')),
              );
            },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double shake = widget.unlocked ? 0 : sin(_controller.value * pi * 6) * (1 - _controller.value) * 6;
          return Transform.translate(
            offset: Offset(shake, 0),
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: widget.unlocked ? kSurface : kSurface.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(kCardRadius),
            border: Border.all(
              color: widget.unlocked ? Colors.white.withValues(alpha: 0.08) : kLock.withValues(alpha: 0.45),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Level ${widget.levelId}',
                style: const TextStyle(
                  color: kTextPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              StarDisplay(stars: widget.stars, size: 16),
              const SizedBox(height: 12),
              Icon(
                widget.unlocked ? Icons.play_circle_rounded : Icons.lock_rounded,
                color: widget.unlocked ? kAccent : kLock,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
