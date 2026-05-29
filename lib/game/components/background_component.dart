import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../block_escape_game.dart';

class BackgroundComponent extends Component with HasGameReference<BlockEscapeGame> {
  double _time = 0;
  final List<Offset> _floaters = <Offset>[
    const Offset(0.15, 0.2),
    const Offset(0.8, 0.15),
    const Offset(0.2, 0.8),
    const Offset(0.78, 0.72),
  ];

  @override
  void update(double dt) {
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final Rect rect = Offset.zero & game.size.toSize();
    final Paint base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: kBackgroundGradient,
      ).createShader(rect);
    canvas.drawRect(rect, base);

    final Paint orbPaint = Paint()..color = const Color(0xFF6AA4FF).withValues(alpha: 0.08);
    final double pulse = 0.5 + 0.5 * sin(_time * 0.7);
    for (int index = 0; index < _floaters.length; index++) {
      final Offset anchor = _floaters[index];
      final double offset = sin(_time * 0.4 + index) * 14;
      final Rect orb = Rect.fromCenter(
        center: Offset(
          rect.width * anchor.dx + offset,
          rect.height * anchor.dy + cos(_time * 0.6 + index) * 10,
        ),
        width: 130 + index * 12 * pulse,
        height: 130 + index * 10 * pulse,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(orb, const Radius.circular(40)),
        orbPaint..color = orbPaint.color.withValues(alpha: 0.05 + index * 0.01),
      );
    }
  }
}
