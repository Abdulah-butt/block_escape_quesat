class StarCalculator {
  const StarCalculator._();

  static int starsForMoves(int moves, int targetMoves) {
    if (moves <= targetMoves) {
      return 3;
    }
    if (moves <= (targetMoves * 1.5).ceil()) {
      return 2;
    }
    return 1;
  }

  static int coinsForStars(int stars) => switch (stars) {
        3 => 30,
        2 => 20,
        _ => 10,
      };
}

