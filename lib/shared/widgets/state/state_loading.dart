import 'package:flutter/material.dart';
import '../../theme/colors.dart';

/// Centered green circular progress indicator.
/// Used across multiple pages (cart, orders, rewards) as the loading state.
class StateLoading extends StatelessWidget {
  const StateLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: CFPVColors.greenAccent),
    );
  }
}
