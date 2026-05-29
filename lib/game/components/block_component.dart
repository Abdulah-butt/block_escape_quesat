import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/constants.dart';
import '../block_escape_game.dart';
import '../models/block_model.dart';
import '../services/audio_service.dart';
import '../services/game_state_service.dart';
import 'board_component.dart';

class BlockComponent extends PositionComponent
    with HasGameReference<BlockEscapeGame>, DragCallbacks {
  BlockComponent({required this.board, required this.blockId});

  final BoardComponent board;
  final String blockId;

  bool _dragging = false;
  double _pressScale = 1.0;
  double _flashTimer = 0.0;
  double _shakeTimer = 0.0;
  double _scaleTarget = 1.0;
  int _dragOriginRow = 0;
  int _dragOriginCol = 0;
  double _dragDistanceX = 0.0;
  double _dragDistanceY = 0.0;
  double _displayOffsetX = 0.0;
  double _displayOffsetY = 0.0;
  double _targetOffsetX = 0.0;
  double _targetOffsetY = 0.0;

  GameStateService get state => game.state;
  BlockModel get block => state.blockById(blockId)!;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
    final Rect rect = board.blockRectFor(
      block.row,
      block.col,
      block.width,
      block.height,
    );
    position = Vector2(rect.left, rect.top);
    size = Vector2(rect.width, rect.height);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final Rect hitRect = Rect.fromLTWH(-10, -10, size.x + 20, size.y + 20);
    return hitRect.contains(point.toOffset());
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (state.completed || state.failed || state.paused) {
      return;
    }
    _dragging = true;
    _dragOriginRow = block.row;
    _dragOriginCol = block.col;
    _dragDistanceX = 0.0;
    _dragDistanceY = 0.0;
    _scaleTarget = 1.05;
    _targetOffsetX = 0.0;
    _targetOffsetY = 0.0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!_dragging || state.completed || state.failed || state.paused) {
      return;
    }
    final double deltaX = event.canvasDelta.x;
    final double deltaY = event.canvasDelta.y;
    final bool horizontal = block.direction == BlockDirection.horizontal;
    final int minDelta = board.maxDelta(block, -1);
    final int maxDelta = board.maxDelta(block, 1);
    final double minPixels = minDelta * board.cellSize;
    final double maxPixels = maxDelta * board.cellSize;
    if (horizontal) {
      _dragDistanceX += deltaX;
      _dragDistanceX = _dragDistanceX.clamp(minPixels, maxPixels).toDouble();
      _targetOffsetX = _dragDistanceX;
      _targetOffsetY = 0.0;
    } else {
      _dragDistanceY += deltaY;
      _dragDistanceY = _dragDistanceY.clamp(minPixels, maxPixels).toDouble();
      _targetOffsetX = 0.0;
      _targetOffsetY = _dragDistanceY;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!_dragging) {
      return;
    }
    _dragging = false;
    _scaleTarget = 1.0;
    final bool horizontal = block.direction == BlockDirection.horizontal;
    final int snappedDelta = block.direction == BlockDirection.horizontal
        ? (_targetOffsetX / board.cellSize).round()
        : (_targetOffsetY / board.cellSize).round();
    final bool moved = snappedDelta != 0;
    if (moved) {
      final int targetRow = _dragOriginRow +
          (block.direction == BlockDirection.vertical ? snappedDelta : 0);
      final int targetCol = _dragOriginCol +
          (block.direction == BlockDirection.horizontal ? snappedDelta : 0);
      state.commitMove(block: block, toRow: targetRow, toCol: targetCol);
      _targetOffsetX = 0.0;
      _targetOffsetY = 0.0;
      _dragDistanceX = 0.0;
      _dragDistanceY = 0.0;
      if (state.progressService.vibrationEnabled) {
        HapticFeedback.lightImpact();
      }
    } else {
      final double travelled = horizontal ? _dragDistanceX.abs() : _dragDistanceY.abs();
      if (travelled > board.cellSize * 0.35) {
        AudioService.instance.playInvalidMove();
        if (state.progressService.vibrationEnabled) {
          HapticFeedback.vibrate();
        }
      }
      _targetOffsetX = 0.0;
      _targetOffsetY = 0.0;
      _dragDistanceX = 0.0;
      _dragDistanceY = 0.0;
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _dragging = false;
    _scaleTarget = 1.0;
    _dragDistanceX = 0.0;
    _dragDistanceY = 0.0;
    _targetOffsetX = 0.0;
    _targetOffsetY = 0.0;
  }

  @override
  void update(double dt) {
    final double targetScale = _scaleTarget;
    _pressScale += (targetScale - _pressScale) * min(1.0, dt * 18);
    if (_flashTimer > 0) {
      _flashTimer -= dt;
    }
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
    }
    _displayOffsetX += (_targetOffsetX - _displayOffsetX) * min(1.0, dt * 20);
    _displayOffsetY += (_targetOffsetY - _displayOffsetY) * min(1.0, dt * 20);

    final Rect rect = board.blockRectFor(block.row, block.col, block.width, block.height)
        .translate(_displayOffsetX, _displayOffsetY);
    position = Vector2(rect.left, rect.top);
    size = Vector2(rect.width, rect.height);
  }

  @override
  void render(Canvas canvas) {
    final Rect rect = Offset.zero & size.toSize();
    final double scale = _pressScale;
    final bool isHinted = state.hintBlockId == blockId;
    final Paint shadow = Paint()..color = Colors.black.withValues(alpha: 0.22);
    final Paint fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: block.isHero
            ? <Color>[kHero, const Color(0xFFFF8A65)]
            : <Color>[const Color(0xFF4F7DF7), const Color(0xFF7FB0FF)],
      ).createShader(rect);
    final Paint border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.12);
    final Paint hintGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = kAccent.withValues(alpha: isHinted ? 0.95 : 0.0);
    final Paint hintFill = Paint()
      ..color = kAccent.withValues(alpha: isHinted ? 0.14 : 0.0);

    final double shakeOffset = _shakeTimer > 0 ? sin((_shakeTimer * 40) * pi) * 4 : 0;
    canvas.save();
    canvas.translate(shakeOffset, 0);
    final Offset center = rect.center;
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(0, 3)), const Radius.circular(16)),
      shadow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(14)),
      fill,
    );
    if (isHinted) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(-2), const Radius.circular(18)),
        hintGlow,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(14)),
        hintFill,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(14)),
      border,
    );
    if (_flashTimer > 0) {
      final Paint flash = Paint()..color = Colors.red.withValues(alpha: (_flashTimer / 0.2).clamp(0.0, 1.0) * 0.25);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(14)),
        flash,
      );
    }
    if (block.isHero) {
      final TextPainter painter = TextPainter(
        text: const TextSpan(
          text: 'HERO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(rect.center.dx - painter.width / 2, rect.center.dy - painter.height / 2),
      );
    }
    if (isHinted) {
      final TextPainter hintPainter = TextPainter(
        text: const TextSpan(
          text: '!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      hintPainter.paint(
        canvas,
        Offset(rect.right - hintPainter.width - 8, rect.top + 4),
      );
    }
    canvas.restore();
  }
}
