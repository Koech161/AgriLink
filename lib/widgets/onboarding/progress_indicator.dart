
import 'package:flutter/material.dart';


class OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress = totalSteps > 0 ? (currentStep / totalSteps).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps, (index) {
            final bool filled = index < currentStep;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: filled ? 12 : 8,
              height: filled ? 12 : 8,
              decoration: BoxDecoration(
                color: filled ? Theme.of(context).primaryColor : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}
