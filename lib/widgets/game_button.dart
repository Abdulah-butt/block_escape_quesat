import 'package:flutter/material.dart';

import '../utils/constants.dart';

class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.minHeight = 56,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double minHeight;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    final Color background = widget.backgroundColor ?? kAccent;
    final Color foreground = widget.foregroundColor ??
        (ThemeData.estimateBrightnessForColor(background) == Brightness.dark
            ? Colors.white
            : Colors.black);
    final Color effectiveBackground =
        enabled ? background : background.withValues(alpha: 0.42);
    final Color effectiveForeground =
        enabled ? foreground : foreground.withValues(alpha: 0.72);
    return AnimatedScale(
      duration: const Duration(milliseconds: 80),
      scale: _pressed ? 0.98 : 1.0,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: Container(
          constraints: BoxConstraints(minHeight: widget.minHeight),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                effectiveBackground,
                effectiveBackground.withValues(alpha: 0.88),
              ],
            ),
            borderRadius: BorderRadius.circular(kButtonRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: enabled ? 0.08 : 0.18),
              width: 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: effectiveBackground.withValues(alpha: enabled ? 0.32 : 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              if (widget.icon != null) ...<Widget>[
                Icon(widget.icon, color: effectiveForeground),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: effectiveForeground,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    shadows: <Shadow>[
                      Shadow(
                        color: Colors.black.withValues(alpha: enabled ? 0.12 : 0.06),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
