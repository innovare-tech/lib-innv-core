import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color contrastColor() => computeLuminance() > 0.5
    ? Colors.black
    : Colors.white;

  Color strongerShade({double factor = 1.8}) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withSaturation((hsl.saturation * factor).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 0.5).clamp(0.0, 1.0))
        .toColor();
  }

  Color softBackground({double factor = 1.6}) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness * factor).clamp(0.0, 1.0))
        .toColor();
  }
}