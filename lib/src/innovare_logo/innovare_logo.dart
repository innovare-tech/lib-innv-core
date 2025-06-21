import 'package:flutter/material.dart';
import 'package:innovare_core/src/innovare_logo/innovare_inn_painter.dart';
import 'package:innovare_core/src/innovare_logo/innovare_name_painter.dart';

enum InnovareLogoType {
  inn,
  completeName;
}

class InnovareLogo extends StatelessWidget {
  final double size;
  final InnovareLogoType type;

  const InnovareLogo({
    super.key,
    this.type = InnovareLogoType.inn,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _getAspectRatio(type);

    return AnimatedContainer(
      width: size * aspectRatio,
      height: size,
      duration: const Duration(milliseconds: 300),
      child: CustomPaint(
        painter: _buildCustomPainter(context),
      ),
    );
  }

  CustomPainter _buildCustomPainter(BuildContext context) {
    switch (type) {
      case InnovareLogoType.inn:
        return InnovareInnPainter(context: context);
      case InnovareLogoType.completeName:
        return InnovareNamePainter(context: context);
    }
  }

  double _getAspectRatio(InnovareLogoType type) {
    switch (type) {
      case InnovareLogoType.inn:
        return 1;
      case InnovareLogoType.completeName:
        return 3.74;
    }
  }
}
