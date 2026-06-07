import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double fontSize;

  const AppLogo({
    super.key,
    this.size = 100,
    this.fontSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: CFPVColors.starbucksGreen,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.local_cafe_rounded,
              color: CFPVColors.white,
              size: size * 0.45,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Coffee Phong Vũ',
          style: CFPVTypography.h1.copyWith(
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
