import 'package:block_escape_quest/game/logic/movement_validator.dart';
import 'package:block_escape_quest/game/logic/star_calculator.dart';
import 'package:block_escape_quest/game/models/block_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stars scale with moves', () {
    expect(StarCalculator.starsForMoves(4, 4), 3);
    expect(StarCalculator.starsForMoves(6, 4), 2);
    expect(StarCalculator.starsForMoves(10, 4), 1);
  });

  test('coins map from stars', () {
    expect(StarCalculator.coinsForStars(3), 30);
    expect(StarCalculator.coinsForStars(2), 20);
    expect(StarCalculator.coinsForStars(1), 10);
  });

  test('movement validator blocks overlap and allows clear paths', () {
    final BlockModel hero = BlockModel(
      id: 'hero',
      row: 2,
      col: 0,
      width: 2,
      height: 1,
      direction: BlockDirection.horizontal,
      isHero: true,
    );
    final BlockModel blocker = BlockModel(
      id: 'b1',
      row: 2,
      col: 3,
      width: 1,
      height: 2,
      direction: BlockDirection.vertical,
      isHero: false,
    );

    expect(
      MovementValidator.canMove(
        block: hero,
        deltaCells: 1,
        blocks: <BlockModel>[hero, blocker],
        rows: 6,
        cols: 6,
      ),
      isTrue,
    );

    expect(
      MovementValidator.canMove(
        block: hero,
        deltaCells: 2,
        blocks: <BlockModel>[hero, blocker],
        rows: 6,
        cols: 6,
      ),
      isFalse,
    );
  });
}
