import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/theme/typography.dart';

class BannerItem {
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onTap;
  final Color backgroundColor;

  const BannerItem({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onTap,
    this.backgroundColor = CFPVColors.houseGreen,
  });
}

class HeroBanner extends StatefulWidget {
  final List<BannerItem> items;

  const HeroBanner({super.key, required this.items});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: widget.items.map((item) => _BannerSlide(item: item)).toList(),
          ),
          if (widget.items.length > 1)
            Positioned(
              bottom: CFPVSpacing.space2,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.items.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? CFPVColors.white
                          : CFPVColors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BannerSlide extends StatelessWidget {
  final BannerItem item;

  const _BannerSlide({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.backgroundColor,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            CFPVSpacing.space4,
            CFPVSpacing.space5,
            CFPVSpacing.space4,
            CFPVSpacing.space5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: CFPVTypography.h1White,
              ),
              const SizedBox(height: CFPVSpacing.space1),
              Text(
                item.subtitle,
                style: CFPVTypography.bodyWhiteSoft,
              ),
              const Spacer(),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: CFPVSpacing.space3),
                decoration: BoxDecoration(
                  color: CFPVColors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    item.ctaLabel,
                    style: CFPVTypography.buttonSmall.copyWith(
                      color: CFPVColors.greenAccent,
                    ),
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
