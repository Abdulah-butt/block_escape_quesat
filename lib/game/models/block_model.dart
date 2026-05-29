enum BlockDirection { horizontal, vertical }

class BlockModel {
  BlockModel({
    required this.id,
    required this.row,
    required this.col,
    required this.width,
    required this.height,
    required this.direction,
    required this.isHero,
  });

  final String id;
  int row;
  int col;
  final int width;
  final int height;
  final BlockDirection direction;
  final bool isHero;

  int get rightEdge => col + width - 1;
  int get bottomEdge => row + height - 1;

  BlockModel clone() => BlockModel(
        id: id,
        row: row,
        col: col,
        width: width,
        height: height,
        direction: direction,
        isHero: isHero,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'row': row,
        'col': col,
        'width': width,
        'height': height,
        'direction': direction.name,
        'isHero': isHero,
      };

  factory BlockModel.fromJson(Map<String, dynamic> json) {
    return BlockModel(
      id: json['id'] as String,
      row: (json['row'] as num).toInt(),
      col: (json['col'] as num).toInt(),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      direction: (json['direction'] as String) == 'vertical'
          ? BlockDirection.vertical
          : BlockDirection.horizontal,
      isHero: json['isHero'] as bool? ?? false,
    );
  }

}
