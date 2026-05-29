import 'block_model.dart';

class LevelExit {
  const LevelExit({required this.row, required this.col});

  final int row;
  final int col;

  Map<String, dynamic> toJson() => <String, dynamic>{'row': row, 'col': col};

  factory LevelExit.fromJson(Map<String, dynamic> json) => LevelExit(
        row: (json['row'] as num).toInt(),
        col: (json['col'] as num).toInt(),
      );
}

class LevelModel {
  const LevelModel({
    required this.id,
    required this.rows,
    required this.cols,
    required this.targetMoves,
    required this.exit,
    required this.blocks,
  });

  final int id;
  final int rows;
  final int cols;
  final int targetMoves;
  final LevelExit exit;
  final List<BlockModel> blocks;

  BlockModel get heroBlock => blocks.firstWhere((BlockModel block) => block.isHero);

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: (json['id'] as num).toInt(),
      rows: (json['rows'] as num).toInt(),
      cols: (json['cols'] as num).toInt(),
      targetMoves: (json['targetMoves'] as num).toInt(),
      exit: LevelExit.fromJson(json['exit'] as Map<String, dynamic>),
      blocks: (json['blocks'] as List<dynamic>)
          .map((dynamic item) => BlockModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

