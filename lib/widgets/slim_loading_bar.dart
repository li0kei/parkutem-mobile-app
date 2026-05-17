import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

// =====================================================
// SLIM LOADING BAR
// =====================================================

class SlimLoadingBar extends StatelessWidget {
  const SlimLoadingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.15, end: 1.0),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 150,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primaryCyan,
                      AppTheme.primaryBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryCyan.withValues(alpha: 0.45),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}