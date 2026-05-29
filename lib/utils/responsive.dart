import 'package:flutter/widgets.dart';

class Responsive {
  const Responsive._();

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 380;

  static double boardPadding(BuildContext context) =>
      isCompact(context) ? 12.0 : 16.0;
}

