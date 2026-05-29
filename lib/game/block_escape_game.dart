import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'components/background_component.dart';
import 'components/board_component.dart';
import 'services/game_state_service.dart';

class BlockEscapeGame extends FlameGame {
  BlockEscapeGame({required this.state});

  final GameStateService state;
  late final BackgroundComponent _background;
  late final BoardComponent _board;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    _background = BackgroundComponent();
    _board = BoardComponent(state: state);
    addAll(<Component>[_background, _board]);
  }
}
