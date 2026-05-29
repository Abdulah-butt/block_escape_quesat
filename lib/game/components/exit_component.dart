import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../block_escape_game.dart';
import '../services/game_state_service.dart';
import 'board_component.dart';

class ExitComponent extends PositionComponent with HasGameReference<BlockEscapeGame> {
  ExitComponent({required this.state});

  final GameStateService state;

  @override
  void render(Canvas canvas) {
    final level = state.level;
    if (level == null) {
      return;
    }
    final Rect rect = (parent as BoardComponent).blockRectFor(level.exit.row, level.exit.col, 1, 1);
    final Paint glow = Paint()..color = kExit.withValues(alpha: 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(4), const Radius.circular(12)),
      glow,
    );
    final Paint fill = Paint()..color = kExit.withValues(alpha: 0.88);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(10)),
      fill,
    );
    final Paint stripe = Paint()..color = Colors.black.withValues(alpha: 0.10);
    canvas.drawRect(Rect.fromLTWH(rect.left + 6, rect.top + 6, rect.width - 12, rect.height - 12), stripe);
  }
}
