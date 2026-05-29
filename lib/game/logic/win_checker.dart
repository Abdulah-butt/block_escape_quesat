import '../models/block_model.dart';
import '../models/level_model.dart';

class WinChecker {
  const WinChecker._();

  static bool isWin(BlockModel heroBlock, LevelExit exit) =>
      heroBlock.row == exit.row && heroBlock.rightEdge == exit.col;
}

