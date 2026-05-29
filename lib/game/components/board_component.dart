import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../game/logic/movement_validator.dart';
import '../block_escape_game.dart';
import '../models/block_model.dart';
import '../services/game_state_service.dart';
import 'block_component.dart';
import 'exit_component.dart';

class BoardComponent extends PositionComponent with HasGameReference<BlockEscapeGame> {
  BoardComponent({required this.state});

  final GameStateService state;

  late final ExitComponent _exitComponent;
  final Map<String, BlockComponent> _blocksById = <String, BlockComponent>{};
  Rect _boardRect = Rect.zero;
  double _cellSize = 1;
  bool _syncPending = false;

  Rect get boardRect => _boardRect;
  double get cellSize => _cellSize;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
    _exitComponent = ExitComponent(state: state);
    add(_exitComponent);
    _syncBlocks();
    state.addListener(_onStateChanged);
  }

  @override
  void onRemove() {
    state.removeListener(_onStateChanged);
    super.onRemove();
  }

  void _onStateChanged() {
    _syncPending = true;
  }

  @override
  void update(double dt) {
    if (_syncPending) {
      _syncPending = false;
      _syncBlocks();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layoutBoard(size.toSize());
  }

  void _layoutBoard(Size canvasSize) {
    final level = state.level;
    if (level == null) {
      return;
    }
    final double availableWidth = canvasSize.width - 32;
    final double availableHeight = canvasSize.height - 32;
    _cellSize = min(availableWidth / level.cols, availableHeight / level.rows);
    final double boardWidth = _cellSize * level.cols;
    final double boardHeight = _cellSize * level.rows;
    _boardRect = Rect.fromLTWH(
      (canvasSize.width - boardWidth) / 2,
      (canvasSize.height - boardHeight) / 2,
      boardWidth,
      boardHeight,
    );
    size = Vector2(canvasSize.width, canvasSize.height);
    position = Vector2.zero();
  }

  void _syncBlocks() {
    final level = state.level;
    if (level == null) {
      return;
    }
    _layoutBoard(game.size.toSize());
    final Set<String> activeIds = state.blocks.map((BlockModel block) => block.id).toSet();
    final List<String> staleIds = _blocksById.keys.where((String id) => !activeIds.contains(id)).toList(growable: false);
    for (final String staleId in staleIds) {
      _blocksById.remove(staleId)?.removeFromParent();
    }
    for (final BlockModel block in state.blocks) {
      if (_blocksById.containsKey(block.id)) {
        continue;
      }
      final BlockComponent component = BlockComponent(board: this, blockId: block.id);
      _blocksById[block.id] = component;
      add(component);
    }
    if (!children.contains(_exitComponent)) {
      add(_exitComponent);
    }
  }

  Rect blockRectFor(int row, int col, int width, int height) {
    return Rect.fromLTWH(
      _boardRect.left + col * _cellSize,
      _boardRect.top + row * _cellSize,
      width * _cellSize,
      height * _cellSize,
    );
  }

  int clampDelta(BlockModel block, int requestedDelta) {
    if (requestedDelta == 0) {
      return 0;
    }
    final int sign = requestedDelta.isNegative ? -1 : 1;
    final int steps = requestedDelta.abs();
    int best = 0;
    for (int step = 1; step <= steps; step++) {
      final int delta = step * sign;
      if (MovementValidator.canMove(
        block: block,
        deltaCells: delta,
        blocks: state.blocks,
        rows: state.level!.rows,
        cols: state.level!.cols,
      )) {
        best = delta;
      } else {
        break;
      }
    }
    return best;
  }

  int maxDelta(BlockModel block, int direction) {
    if (direction == 0) {
      return 0;
    }
    final int sign = direction.isNegative ? -1 : 1;
    int best = 0;
    for (int step = 1; ; step++) {
      final int delta = step * sign;
      if (MovementValidator.canMove(
        block: block,
        deltaCells: delta,
        blocks: state.blocks,
        rows: state.level!.rows,
        cols: state.level!.cols,
      )) {
        best = delta;
      } else {
        break;
      }
    }
    return best;
  }

  bool canMove(BlockModel block, int deltaCells) {
    return MovementValidator.canMove(
      block: block,
      deltaCells: deltaCells,
      blocks: state.blocks,
      rows: state.level!.rows,
      cols: state.level!.cols,
    );
  }

  @override
  void render(Canvas canvas) {
    final Paint boardPaint = Paint()..color = const Color(0xFF0B1120).withValues(alpha: 0.56);
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.09);

    canvas.drawRRect(
      RRect.fromRectAndRadius(_boardRect.inflate(6), const Radius.circular(24)),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(_boardRect, const Radius.circular(20)),
      boardPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(_boardRect, const Radius.circular(20)),
      borderPaint,
    );

    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    final level = state.level;
    if (level != null) {
      for (int row = 1; row < level.rows; row++) {
        final double y = _boardRect.top + row * _cellSize;
        canvas.drawLine(Offset(_boardRect.left, y), Offset(_boardRect.right, y), gridPaint);
      }
      for (int col = 1; col < level.cols; col++) {
        final double x = _boardRect.left + col * _cellSize;
        canvas.drawLine(Offset(x, _boardRect.top), Offset(x, _boardRect.bottom), gridPaint);
      }
    }
  }
}
