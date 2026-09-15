import 'package:flutter/material.dart';

extension ScreenSizeExtension on num {
  /// Full screen height multiplier. Example: `0.5.sh` is 50% of screen height
  double get sh =>
      MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first,
      ).size.height *
      this;

  /// Full screen width multiplier. Example: `0.25.sw` is 25% of screen width
  double get sw =>
      MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first,
      ).size.width *
      this;
}
