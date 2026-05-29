import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../analytics/analytics_service.dart';
import '../logic/star_calculator.dart';
import '../models/block_model.dart';
import '../models/level_model.dart';
import '../models/move_model.dart';
import 'audio_service.dart';
import 'level_loader.dart';
import 'progress_service.dart';

class GameStateService extends ChangeNotifier {
  GameStateService({
    required this.levelLoader,
    required this.progressService,
    required this.analyticsService,
  });

  final LevelLoader levelLoader;
  final ProgressService progressService;
  final AnalyticsService analyticsService;

  LevelModel? _level;
  final List<BlockModel> _blocks = <BlockModel>[];
  final List<MoveModel> _undoStack = <MoveModel>[];
  bool _completed = false;
  bool _failed = false;
  bool _paused = false;
  int _moveCount = 0;
  int _earnedStars = 0;
  int _earnedCoins = 0;
  String? _error;
  String? _hintBlockId;

  LevelModel? get level => _level;
  List<BlockModel> get blocks => List<BlockModel>.unmodifiable(_blocks);
  List<MoveModel> get undoStack => List<MoveModel>.unmodifiable(_undoStack);
  bool get completed => _completed;
  bool get failed => _failed;
  bool get paused => _paused;
  int get moveCount => _moveCount;
  int get earnedStars => _earnedStars;
  int get earnedCoins => _earnedCoins;
  String? get error => _error;
  String? get hintBlockId => _hintBlockId;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get isReady => _level != null && _error == null;

  BlockModel? get heroBlock {
    for (final BlockModel block in _blocks) {
      if (block.isHero) {
        return block;
      }
    }
    return null;
  }

  Future<void> startLevel(int levelId) async {
    final LevelModel? level = levelLoader.byId(levelId);
    if (level == null) {
      _level = null;
      _error = 'Level unavailable, try again';
      notifyListeners();
      return;
    }

    _level = level;
    _blocks
      ..clear()
      ..addAll(level.blocks.map((BlockModel block) => block.clone()));
    _undoStack.clear();
    _completed = false;
    _failed = false;
    _paused = false;
    _moveCount = 0;
    _earnedStars = 0;
    _earnedCoins = 0;
    _error = null;
    _hintBlockId = null;
    await progressService.setLastPlayedLevel(levelId);
    analyticsService.logLevelStart(levelId);
    notifyListeners();
  }

  void setPaused(bool value) {
    if (_paused == value) {
      return;
    }
    _paused = value;
    notifyListeners();
  }

  void setHintBlock(String? blockId) {
    _hintBlockId = blockId;
    notifyListeners();
    if (blockId == null) {
      return;
    }
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (_hintBlockId == blockId) {
        _hintBlockId = null;
        notifyListeners();
      }
    });
  }

  BlockModel? blockById(String blockId) {
    for (final BlockModel block in _blocks) {
      if (block.id == blockId) {
        return block;
      }
    }
    return null;
  }

  Future<void> commitMove({
    required BlockModel block,
    required int toRow,
    required int toCol,
  }) async {
    if (_level == null || _completed || _failed) {
      return;
    }
    final int fromRow = block.row;
    final int fromCol = block.col;
    if (fromRow == toRow && fromCol == toCol) {
      return;
    }
    _undoStack.add(
      MoveModel(
        blockId: block.id,
        fromRow: fromRow,
        fromCol: fromCol,
        toRow: toRow,
        toCol: toCol,
      ),
    );
    if (_undoStack.length > 20) {
      _undoStack.removeAt(0);
    }
    block.row = toRow;
    block.col = toCol;
    _moveCount++;
    _hintBlockId = null;
    if (_moveCount > _level!.targetMoves) {
      _failed = true;
      notifyListeners();
      AudioService.instance.playInvalidMove();
      return;
    }
    notifyListeners();
    AudioService.instance.playMove();
    _checkWin();
  }

  void applyPreview(BlockModel block, int row, int col) {
    block.row = row;
    block.col = col;
    notifyListeners();
  }

  Future<void> undo() async {
    if (_undoStack.isEmpty || _failed || _completed) {
      return;
    }
    final MoveModel move = _undoStack.removeLast();
    final BlockModel? block = blockById(move.blockId);
    if (block == null) {
      return;
    }
    block.row = move.fromRow;
    block.col = move.fromCol;
    _moveCount = (_moveCount - 1).clamp(0, 999999).toInt();
    _hintBlockId = null;
    notifyListeners();
  }

  Future<void> reset() async {
    if (_level == null) {
      return;
    }
    await startLevel(_level!.id);
  }

  Future<void> completeLevel() async {
    if (_completed || _failed || _level == null) {
      return;
    }
    _completed = true;
    _earnedStars = StarCalculator.starsForMoves(_moveCount, _level!.targetMoves);
    _earnedCoins = StarCalculator.coinsForStars(_earnedStars);
    _earnedCoins = await progressService.completeLevel(_level!.id, _earnedStars);
    AudioService.instance.playWin();
    analyticsService.logLevelComplete(_level!.id, _moveCount, _earnedStars);
    notifyListeners();
  }

  Future<bool> showHint() async {
    final String? hint = _computeHintBlockId();
    if (hint == null) {
      return false;
    }
    setHintBlock(hint);
    AudioService.instance.playHint();
    return true;
  }

  String? _computeHintBlockId() {
    final LevelModel? level = _level;
    final BlockModel? hero = heroBlock;
    if (level == null || hero == null) {
      return null;
    }

    final List<BlockModel> rowBlocks = _blocks
        .where((BlockModel block) => block.row == hero.row && !block.isHero)
        .toList(growable: false)
      ..sort((BlockModel a, BlockModel b) => a.col.compareTo(b.col));

    for (final BlockModel block in rowBlocks) {
      if (block.col > hero.rightEdge) {
        return block.id;
      }
    }
    return hero.id;
  }

  void _checkWin() {
    final LevelModel? level = _level;
    final BlockModel? hero = heroBlock;
    if (level == null || hero == null || _failed) {
      return;
    }
    if (hero.row == level.exit.row && hero.rightEdge == level.exit.col) {
      if (_moveCount != level.targetMoves) {
        _failed = true;
        AudioService.instance.playInvalidMove();
        notifyListeners();
        return;
      }
      completeLevel();
    }
  }
}
