import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/onboarding_slide.dart';
import '../../../shared/widgets/buttons/primary_pill_button.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/theme/spacing.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/services/secure_storage_service.dart';

/// Welcome carousel for first-time users.
/// Design: specs/design-phase.md §4
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    OnboardingSlideData(
      emoji: '☕',
      title: 'Browse & Order',
      body: 'Explore our full menu of handcrafted beverages and fresh food.',
      color: Color(0xFFC87A5A),
    ),
    OnboardingSlideData(
      emoji: '⭐',
      title: 'Earn Rewards',
      body: 'Collect points with every order and unlock exclusive benefits.',
      color: Color(0xFF5A8C74),
    ),
    OnboardingSlideData(
      emoji: '📍',
      title: 'Fast & Easy Pickup',
      body: 'Order ahead and skip the line. Your order will be ready when you arrive.',
      color: Color(0xFF7A6B5A),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted() async {
    final storage = SecureStorageService();
    await storage.markOnboardingSeen();
    if (mounted) context.go(RoutePaths.login);
  }

  void _onSkip() => _onGetStarted();

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: _slides.map((s) {
              return OnboardingSlide(
                imageAsset: s.emoji,
                title: s.title,
                body: s.body,
                backgroundColor: s.color,
              );
            }).toList(),
          ),
          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + CFPVSpacing.space5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: CFPVSpacing.space4),
              child: Column(
                children: [
                  // Page indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? CFPVColors.white
                              : CFPVColors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: CFPVSpacing.space4),
                  // Next / Get Started button
                  SizedBox(
                    width: double.infinity,
                    child: isLastPage
                        ? PrimaryPillButton(
                            label: '✓  Get Started',
                            onPressed: _onGetStarted,
                          )
                        : PrimaryPillButton(
                            label: 'Next →',
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: CFPVSpacing.space3),
                  // Skip button
                  if (!isLastPage)
                    TextButton(
                      onPressed: _onSkip,
                      child: Text(
                        'Skip',
                        style: CFPVTypography.buttonLabel.copyWith(
                          color: CFPVColors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSlideData {
  final String emoji;
  final String title;
  final String body;
  final Color color;

  const OnboardingSlideData({
    required this.emoji,
    required this.title,
    required this.body,
    required this.color,
  });
}
