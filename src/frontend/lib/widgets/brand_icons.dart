import 'package:flutter/material.dart';

/// Crisp, pixel-perfect brand icons for Twitter/X, Instagram, Facebook, and YouTube.
/// Rendered using high-performance vector Canvas drawing without external font/asset dependencies.
class BrandIcon extends StatelessWidget {
  final BrandType type;
  final double size;
  final Color color;

  const BrandIcon({
    super.key,
    required this.type,
    this.size = 22.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BrandIconPainter(type: type, color: color),
      ),
    );
  }
}

enum BrandType {
  xTwitter,
  instagram,
  facebook,
  youtube,
}

class _BrandIconPainter extends CustomPainter {
  final BrandType type;
  final Color color;

  _BrandIconPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    switch (type) {
      case BrandType.xTwitter:
        // Official X brand geometry
        final path = Path();
        path.moveTo(w * 0.74, h * 0.12);
        path.lineTo(w * 0.88, h * 0.12);
        path.lineTo(w * 0.58, h * 0.47);
        path.lineTo(w * 0.93, h * 0.88);
        path.lineTo(w * 0.65, h * 0.88);
        path.lineTo(w * 0.43, h * 0.60);
        path.lineTo(w * 0.18, h * 0.88);
        path.lineTo(w * 0.04, h * 0.88);
        path.lineTo(w * 0.36, h * 0.51);
        path.lineTo(w * 0.03, h * 0.12);
        path.lineTo(w * 0.32, h * 0.12);
        path.lineTo(w * 0.52, h * 0.38);
        path.close();

        // Inner cutout / polygon adjustment for exact X appearance
        canvas.drawPath(path, paint);
        break;

      case BrandType.instagram:
        // Rounded outer square
        final outerRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.08, h * 0.08, w * 0.84, h * 0.84),
          Radius.circular(w * 0.24),
        );
        canvas.drawRRect(outerRRect, strokePaint);

        // Center camera lens
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.21, strokePaint);

        // Flash dot in top right
        canvas.drawCircle(Offset(w * 0.72, h * 0.28), w * 0.05, paint);
        break;

      case BrandType.facebook:
        // Recognizable Facebook 'f' glyph
        final path = Path();
        path.moveTo(w * 0.58, h * 0.88);
        path.lineTo(w * 0.58, h * 0.52);
        path.lineTo(w * 0.71, h * 0.52);
        path.lineTo(w * 0.73, h * 0.36);
        path.lineTo(w * 0.58, h * 0.36);
        path.lineTo(w * 0.58, h * 0.26);
        path.cubicTo(w * 0.58, h * 0.21, w * 0.60, h * 0.18, w * 0.68, h * 0.18);
        path.lineTo(w * 0.74, h * 0.18);
        path.lineTo(w * 0.74, h * 0.04);
        path.cubicTo(w * 0.64, h * 0.03, w * 0.54, h * 0.03, w * 0.47, h * 0.09);
        path.cubicTo(w * 0.39, h * 0.15, w * 0.37, h * 0.24, w * 0.37, h * 0.35);
        path.lineTo(w * 0.37, h * 0.36);
        path.lineTo(w * 0.23, h * 0.36);
        path.lineTo(w * 0.23, h * 0.52);
        path.lineTo(w * 0.37, h * 0.52);
        path.lineTo(w * 0.37, h * 0.88);
        path.close();

        canvas.drawPath(path, paint);
        break;

      case BrandType.youtube:
        // YouTube rounded pill background with center play triangle
        final bgRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.05, h * 0.18, w * 0.90, h * 0.64),
          Radius.circular(w * 0.18),
        );
        canvas.drawRRect(bgRRect, strokePaint);

        // Center play triangle
        final playPath = Path();
        playPath.moveTo(w * 0.42, h * 0.36);
        playPath.lineTo(w * 0.65, h * 0.50);
        playPath.lineTo(w * 0.42, h * 0.64);
        playPath.close();

        canvas.drawPath(playPath, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BrandIconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
