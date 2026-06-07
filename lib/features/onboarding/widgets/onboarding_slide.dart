import 'package:flutter/material.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/spacing.dart';

/// A single slide in the onboarding carousel.
class OnboardingSlide extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String body;
  final Color? backgroundColor;

  const OnboardingSlide({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.body,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? const Color(0xFFE8D5C4),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: CFPVSpacing.space4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    imageAsset,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: CFPVTypography.h1.copyWith(color: CFPVColors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CFPVSpacing.space3),
              Text(
                body,
                style: CFPVTypography.bodyLarge.copyWith(
                  color: CFPVColors.textWhiteSoft,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
