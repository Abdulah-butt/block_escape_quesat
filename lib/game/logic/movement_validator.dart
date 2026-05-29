import '../models/block_model.dart';

class MovementValidator {
  const MovementValidator._();

  static bool canMove({
    required BlockModel block,
    required int deltaCells,
    required List<BlockModel> blocks,
    required int rows,
    required int cols,
  }) {
    if (deltaCells == 0) {
      return true;
    }

    if (block.direction == BlockDirection.horizontal && block.height != 1) {
      return false;
    }
    if (block.direction == BlockDirection.vertical && block.width != 1) {
      return false;
    }

    final int step = deltaCells.isNegative ? -1 : 1;
    final int steps = deltaCells.abs();

    for (int offset = 1; offset <= steps; offset++) {
      final int nextRow = block.row + (block.direction == BlockDirection.vertical ? offset * step : 0);
      final int nextCol = block.col + (block.direction == BlockDirection.horizontal ? offset * step : 0);

      if (!_withinBounds(block, nextRow, nextCol, rows, cols)) {
        return false;
      }
      if (!_pathIsClear(block, blocks, nextRow, nextCol)) {
        return false;
      }
    }

    return true;
  }

  static bool _withinBounds(
    BlockModel block,
    int nextRow,
    int nextCol,
    int rows,
    int cols,
  ) {
    return nextRow >= 0 &&
        nextCol >= 0 &&
        nextRow + block.height <= rows &&
        nextCol + block.width <= cols;
  }

  static bool _pathIsClear(
    BlockModel movingBlock,
    List<BlockModel> blocks,
    int nextRow,
    int nextCol,
  ) {
    for (final BlockModel other in blocks) {
      if (other.id == movingBlock.id) {
        continue;
      }
      if (_overlaps(
        nextRow,
        nextCol,
        movingBlock.width,
        movingBlock.height,
        other.row,
        other.col,
        other.width,
        other.height,
      )) {
        return false;
      }
    }
    return true;
  }

  static bool _overlaps(
    int rowA,
    int colA,
    int widthA,
    int heightA,
    int rowB,
    int colB,
    int widthB,
    int heightB,
  ) {
    final bool horizontal = colA < colB + widthB && colA + widthA > colB;
    final bool vertical = rowA < rowB + heightB && rowA + heightA > rowB;
    return horizontal && vertical;
  }
}

