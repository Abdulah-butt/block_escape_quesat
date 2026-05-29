import 'package:equatable/equatable.dart';

class MoveModel extends Equatable {
  const MoveModel({
    required this.blockId,
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
  });

  final String blockId;
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;

  @override
  List<Object?> get props => <Object?>[blockId, fromRow, fromCol, toRow, toCol];
}

