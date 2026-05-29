import 'package:flutter/material.dart';

class StarDisplay extends StatelessWidget {
  const StarDisplay({super.key, required this.stars, this.size = 20});

  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(3, (int index) {
        final bool filled = index < stars;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: filled ? const Color(0xFFFFD54A) : Colors.white.withValues(alpha: 0.28),
            size: size,
          ),
        );
      }),
    );
  }
}

