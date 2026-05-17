import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

// =====================================================
// APP BACKGROUND
// =====================================================

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF020817),
              Color(0xFF061B2E),
              Color(0xFF020817),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -120,
              left: -90,
              child: _GlowCircle(
                size: 260,
                color: AppTheme.primaryCyan.withValues(alpha: 0.16),
              ),
            ),

            Positioned(
              bottom: -150,
              right: -110,
              child: _GlowCircle(
                size: 320,
                color: AppTheme.primaryBlue.withValues(alpha: 0.18),
              ),
            ),

            const Positioned(
              top: 60,
              left: -30,
              child: _AccentLines(),
            ),

            const Positioned(
              bottom: 80,
              right: -20,
              child: _AccentLines(),
            ),

            Positioned.fill(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// GLOW CIRCLE
// =====================================================

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 120,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

// =====================================================
// SIMPLE ACCENT LINES
// =====================================================

class _AccentLines extends StatelessWidget {
  const _AccentLines();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.35,
      child: SizedBox(
        width: 180,
        height: 120,
        child: CustomPaint(
          painter: _AccentLinePainter(),
        ),
      ),
    );
  }
}

// =====================================================
// ACCENT LINE PAINTER
// =====================================================

class _AccentLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryCyan.withValues(alpha: 0.55)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final path = Path()
        ..moveTo(0, 20.0 + (i * 22))
        ..quadraticBezierTo(
          size.width * 0.45,
          -10 + (i * 25),
          size.width,
          18 + (i * 20),
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}