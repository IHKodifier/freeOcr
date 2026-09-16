import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders high-fidelity, semantic PDF operation outline vector illustrations.
///
/// Each icon explicitly depicts the visual metaphor of the action:
/// - Merge: Two documents merging into one.
/// - Split: One document splitting into two.
/// - Rotate: Document with a 90° rotation arc.
/// - Redact: Document with censorship blackout bars.
/// - And other respective operations.
class SemanticPdfIcon extends StatelessWidget {
  final String toolId;
  final Color color;
  final double size;

  const SemanticPdfIcon({
    super.key,
    required this.toolId,
    required this.color,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SemanticPdfPainter(toolId: toolId, color: color),
    );
  }
}

class _SemanticPdfPainter extends CustomPainter {
  final String toolId;
  final Color color;

  _SemanticPdfPainter({required this.toolId, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final solidPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (toolId) {
      case 'merge':
        _paintMerge(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'split':
        _paintSplit(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'rotate':
        _paintRotate(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'delete-pages':
        _paintDeletePages(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'extract-pages':
        _paintExtractPages(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'number-pages':
        _paintNumberPages(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'compress':
        _paintCompress(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'watermark':
        _paintWatermark(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'crop':
        _paintCrop(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'redact':
        _paintRedact(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'sign':
        _paintSign(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'ocr':
        _paintOcr(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'annotate':
        _paintAnnotate(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'edit-text':
        _paintEditText(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'pdf-to-word':
        _paintPdfToWord(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      case 'summarize':
        _paintSummarize(canvas, size, strokePaint, fillPaint, solidPaint);
        break;
      default:
        _drawDoc(canvas, Rect.fromLTWH(size.width * 0.2, size.height * 0.15, size.width * 0.6, size.height * 0.7), strokePaint);
        break;
    }
  }

  void _drawDoc(Canvas canvas, Rect rect, Paint paint, {double fold = 0.25}) {
    final w = rect.width;
    final h = rect.height;
    final r = w * 0.12;
    final path = Path()
      ..moveTo(rect.left + r, rect.top)
      ..lineTo(rect.right - w * fold, rect.top)
      ..lineTo(rect.right, rect.top + h * fold)
      ..lineTo(rect.right, rect.bottom - r)
      ..arcToPoint(Offset(rect.right - r, rect.bottom), radius: Radius.circular(r))
      ..lineTo(rect.left + r, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom - r), radius: Radius.circular(r))
      ..lineTo(rect.left, rect.top + r)
      ..arcToPoint(Offset(rect.left + r, rect.top), radius: Radius.circular(r))
      ..close();
    canvas.drawPath(path, paint);

    // Fold flap
    final foldPath = Path()
      ..moveTo(rect.right - w * fold, rect.top)
      ..lineTo(rect.right - w * fold, rect.top + h * fold)
      ..lineTo(rect.right, rect.top + h * fold);
    canvas.drawPath(foldPath, paint);
  }

  void _drawSimpleDoc(Canvas canvas, Rect rect, Paint paint) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.12)), paint);
  }

  // 1. Merge PDF: Two incoming document outlines joining into one document outline
  void _paintMerge(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    // Incoming Top-Left Doc
    _drawSimpleDoc(canvas, Rect.fromLTWH(w * 0.06, h * 0.08, w * 0.36, h * 0.40), stroke);
    // Incoming Bottom-Left Doc
    _drawSimpleDoc(canvas, Rect.fromLTWH(w * 0.06, h * 0.52, w * 0.36, h * 0.40), stroke);

    // Merged Unified Target Doc (Right)
    final targetRect = Rect.fromLTWH(w * 0.54, h * 0.18, w * 0.40, h * 0.64);
    canvas.drawRRect(RRect.fromRectAndRadius(targetRect, Radius.circular(w * 0.08)), fill);
    _drawDoc(canvas, targetRect, stroke);

    // Inward Merge Arrows joining into target
    final arrowPath = Path()
      ..moveTo(w * 0.44, h * 0.28)
      ..lineTo(w * 0.50, h * 0.38)
      ..moveTo(w * 0.44, h * 0.72)
      ..lineTo(w * 0.50, h * 0.62)
      ..moveTo(w * 0.46, h * 0.50)
      ..lineTo(w * 0.52, h * 0.50);
    canvas.drawPath(arrowPath, stroke);
  }

  // 2. Split PDF: One document outline on left splitting into two documents on right
  void _paintSplit(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    // Source Document (Left)
    _drawDoc(canvas, Rect.fromLTWH(w * 0.06, h * 0.18, w * 0.40, h * 0.64), stroke);

    // Vertical cut indicator
    final cutPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.26, h * 0.35), Offset(w * 0.26, h * 0.65), cutPaint);

    // Two Output Result Documents (Right)
    _drawSimpleDoc(canvas, Rect.fromLTWH(w * 0.58, h * 0.08, w * 0.36, h * 0.40), stroke);
    _drawSimpleDoc(canvas, Rect.fromLTWH(w * 0.58, h * 0.52, w * 0.36, h * 0.40), stroke);

    // Diverging arrow
    final arrowPath = Path()
      ..moveTo(w * 0.48, h * 0.45)
      ..lineTo(w * 0.54, h * 0.35)
      ..moveTo(w * 0.48, h * 0.55)
      ..lineTo(w * 0.54, h * 0.65);
    canvas.drawPath(arrowPath, stroke);
  }

  // 3. Rotate PDF: Document sheet with a circular curved 90° clockwise rotation arrow
  void _paintRotate(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    // Center Doc
    _drawDoc(canvas, Rect.fromLTWH(w * 0.25, h * 0.22, w * 0.50, h * 0.64), stroke);

    // Curved rotation arc wrapping top right
    final arcRect = Rect.fromCircle(center: Offset(w * 0.50, h * 0.50), radius: w * 0.40);
    canvas.drawArc(arcRect, -math.pi * 0.75, math.pi * 0.85, false, stroke);

    // Arrowhead at end of arc
    final head = Path()
      ..moveTo(w * 0.82, h * 0.28)
      ..lineTo(w * 0.88, h * 0.18)
      ..lineTo(w * 0.76, h * 0.16);
    canvas.drawPath(head, stroke);
  }

  // 4. Delete Pages: Document outline with a page removal cross/minus
  void _paintDeletePages(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    // Back stacked sheet
    _drawSimpleDoc(canvas, Rect.fromLTWH(w * 0.28, h * 0.10, w * 0.50, h * 0.64), stroke);

    // Front target sheet
    final frontRect = Rect.fromLTWH(w * 0.16, h * 0.24, w * 0.52, h * 0.64);
    canvas.drawRRect(RRect.fromRectAndRadius(frontRect, Radius.circular(w * 0.08)), fill);
    _drawDoc(canvas, frontRect, stroke);

    // Red/Accent Removal Badge (Bottom Right Circle with Minus/X)
    final badgeCenter = Offset(w * 0.76, h * 0.76);
    final badgeRadius = w * 0.20;
    canvas.drawCircle(badgeCenter, badgeRadius, solid);

    final whiteStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(badgeCenter.dx - badgeRadius * 0.5, badgeCenter.dy),
      Offset(badgeCenter.dx + badgeRadius * 0.5, badgeCenter.dy),
      whiteStroke,
    );
  }

  // 5. Extract Pages: Document with a single page popping out with an arrow
  void _paintExtractPages(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    // Stack base
    _drawSimpleDoc(canvas, Rect.fromLTWH(w * 0.12, h * 0.26, w * 0.52, h * 0.64), stroke);

    // Extracted page lifted up and right
    final popRect = Rect.fromLTWH(w * 0.38, h * 0.10, w * 0.50, h * 0.62);
    canvas.drawRRect(RRect.fromRectAndRadius(popRect, Radius.circular(w * 0.08)), fill);
    _drawDoc(canvas, popRect, stroke);

    // Extraction movement arrow
    final arrow = Path()
      ..moveTo(w * 0.22, h * 0.44)
      ..lineTo(w * 0.38, h * 0.28)
      ..moveTo(w * 0.28, h * 0.28)
      ..lineTo(w * 0.38, h * 0.28)
      ..lineTo(w * 0.38, h * 0.38);
    canvas.drawPath(arrow, stroke);
  }

  // 6. Number Pages: Document with 1, 2, 3 stamped at bottom margin
  void _paintNumberPages(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    // Center Doc
    _drawDoc(canvas, Rect.fromLTWH(w * 0.18, h * 0.10, w * 0.64, h * 0.80), stroke);

    // Text lines
    canvas.drawLine(Offset(w * 0.30, h * 0.32), Offset(w * 0.70, h * 0.32), stroke);
    canvas.drawLine(Offset(w * 0.30, h * 0.46), Offset(w * 0.70, h * 0.46), stroke);

    // Bottom page numbering "1 2 3" dots/badges
    final dotRadius = w * 0.04;
    canvas.drawCircle(Offset(w * 0.36, h * 0.74), dotRadius, solid);
    canvas.drawCircle(Offset(w * 0.50, h * 0.74), dotRadius, solid);
    canvas.drawCircle(Offset(w * 0.64, h * 0.74), dotRadius, solid);
  }

  // 7. Compress PDF: Document being squeezed inward by opposing arrows
  void _paintCompress(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    // Compressed narrower doc in center
    _drawDoc(canvas, Rect.fromLTWH(w * 0.30, h * 0.14, w * 0.40, h * 0.72), stroke);

    // Left squeeze arrow pointing right
    final leftArrow = Path()
      ..moveTo(w * 0.06, h * 0.50)
      ..lineTo(w * 0.24, h * 0.50)
      ..moveTo(w * 0.18, h * 0.40)
      ..lineTo(w * 0.24, h * 0.50)
      ..lineTo(w * 0.18, h * 0.60);
    canvas.drawPath(leftArrow, stroke);

    // Right squeeze arrow pointing left
    final rightArrow = Path()
      ..moveTo(w * 0.94, h * 0.50)
      ..lineTo(w * 0.76, h * 0.50)
      ..moveTo(w * 0.82, h * 0.40)
      ..lineTo(w * 0.76, h * 0.50)
      ..lineTo(w * 0.82, h * 0.60);
    canvas.drawPath(rightArrow, stroke);
  }

  // 8. Watermark PDF: Document with diagonal watermark stamp outline
  void _paintWatermark(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    _drawDoc(canvas, Rect.fromLTWH(w * 0.18, h * 0.10, w * 0.64, h * 0.80), stroke);

    // Diagonal banner stamp across doc
    canvas.save();
    canvas.translate(w * 0.50, h * 0.50);
    canvas.rotate(-math.pi / 4);

    final stampRect = Rect.fromCenter(center: Offset.zero, width: w * 0.60, height: h * 0.22);
    canvas.drawRRect(RRect.fromRectAndRadius(stampRect, Radius.circular(w * 0.04)), stroke);
    canvas.drawRRect(RRect.fromRectAndRadius(stampRect, Radius.circular(w * 0.04)), fill);

    // Internal text line inside watermark
    canvas.drawLine(Offset(-w * 0.20, 0), Offset(w * 0.20, 0), stroke);
    canvas.restore();
  }

  // 9. Crop PDF: Document framed by corner crop brackets
  void _paintCrop(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    // Inner cropped doc area
    final inner = Rect.fromLTWH(w * 0.25, h * 0.25, w * 0.50, h * 0.50);
    canvas.drawRRect(RRect.fromRectAndRadius(inner, Radius.circular(w * 0.06)), fill);
    canvas.drawRRect(RRect.fromRectAndRadius(inner, Radius.circular(w * 0.06)), stroke);

    // 4 Crop corner brackets
    final arm = w * 0.22;
    // Top-left
    canvas.drawLine(Offset(w * 0.10, h * 0.25), Offset(w * 0.10 + arm, h * 0.25), stroke);
    canvas.drawLine(Offset(w * 0.25, h * 0.10), Offset(w * 0.25, h * 0.10 + arm), stroke);
    // Top-right
    canvas.drawLine(Offset(w * 0.90, h * 0.25), Offset(w * 0.90 - arm, h * 0.25), stroke);
    canvas.drawLine(Offset(w * 0.75, h * 0.10), Offset(w * 0.75, h * 0.10 + arm), stroke);
    // Bottom-left
    canvas.drawLine(Offset(w * 0.10, h * 0.75), Offset(w * 0.10 + arm, h * 0.75), stroke);
    canvas.drawLine(Offset(w * 0.25, h * 0.90), Offset(w * 0.25, h * 0.90 - arm), stroke);
    // Bottom-right
    canvas.drawLine(Offset(w * 0.90, h * 0.75), Offset(w * 0.90 - arm, h * 0.75), stroke);
    canvas.drawLine(Offset(w * 0.75, h * 0.90), Offset(w * 0.75, h * 0.90 - arm), stroke);
  }

  // 10. Redact PDF: Document with censorship blackout marker bars
  void _paintRedact(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    _drawDoc(canvas, Rect.fromLTWH(w * 0.18, h * 0.10, w * 0.64, h * 0.80), stroke);

    // Normal text line
    canvas.drawLine(Offset(w * 0.30, h * 0.32), Offset(w * 0.70, h * 0.32), stroke);

    // Blackout censor bars
    final bar1 = Rect.fromLTWH(w * 0.28, h * 0.44, w * 0.44, h * 0.11);
    canvas.drawRRect(RRect.fromRectAndRadius(bar1, Radius.circular(w * 0.03)), solid);

    final bar2 = Rect.fromLTWH(w * 0.28, h * 0.62, w * 0.34, h * 0.11);
    canvas.drawRRect(RRect.fromRectAndRadius(bar2, Radius.circular(w * 0.03)), solid);
  }

  // 11. Sign PDF: Document with signature line and quill/seal
  void _paintSign(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    _drawDoc(canvas, Rect.fromLTWH(w * 0.18, h * 0.10, w * 0.64, h * 0.80), stroke);

    // Text lines
    canvas.drawLine(Offset(w * 0.30, h * 0.30), Offset(w * 0.70, h * 0.30), stroke);
    canvas.drawLine(Offset(w * 0.30, h * 0.42), Offset(w * 0.70, h * 0.42), stroke);

    // Signature scribble line
    final sig = Path()
      ..moveTo(w * 0.30, h * 0.68)
      ..quadraticBezierTo(w * 0.38, h * 0.58, w * 0.46, h * 0.68)
      ..quadraticBezierTo(w * 0.54, h * 0.78, w * 0.62, h * 0.62)
      ..lineTo(w * 0.70, h * 0.68);
    canvas.drawPath(sig, stroke);

    // Ribbon / seal stamp
    canvas.drawCircle(Offset(w * 0.66, h * 0.74), w * 0.09, solid);
  }

  // 12. OCR PDF: Document with scanning beam line
  void _paintOcr(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    _drawDoc(canvas, Rect.fromLTWH(w * 0.18, h * 0.10, w * 0.64, h * 0.80), stroke);

    // Text lines
    canvas.drawLine(Offset(w * 0.30, h * 0.32), Offset(w * 0.70, h * 0.32), stroke);
    canvas.drawLine(Offset(w * 0.30, h * 0.48), Offset(w * 0.70, h * 0.48), stroke);
    canvas.drawLine(Offset(w * 0.30, h * 0.64), Offset(w * 0.70, h * 0.64), stroke);

    // Horizontal optical scanner beam with glow
    final beamY = h * 0.48;
    final beamPaint = Paint()
      ..color = color
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.10, beamY), Offset(w * 0.90, beamY), beamPaint);
  }

  // 13. Annotate PDF: Document with highlighter mark and callout
  void _paintAnnotate(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    _drawDoc(canvas, Rect.fromLTWH(w * 0.18, h * 0.10, w * 0.64, h * 0.80), stroke);

    // Highlighted text strip
    final highlightRect = Rect.fromLTWH(w * 0.28, h * 0.32, w * 0.44, h * 0.10);
    canvas.drawRRect(RRect.fromRectAndRadius(highlightRect, Radius.circular(w * 0.03)), fill);
    canvas.drawLine(Offset(w * 0.30, h * 0.37), Offset(w * 0.70, h * 0.37), stroke);

    // Sticky note / comment callout box
    final note = Rect.fromLTWH(w * 0.50, h * 0.54, w * 0.36, h * 0.30);
    canvas.drawRRect(RRect.fromRectAndRadius(note, Radius.circular(w * 0.05)), fill);
    canvas.drawRRect(RRect.fromRectAndRadius(note, Radius.circular(w * 0.05)), stroke);
  }

  // 14. Edit Text: Document with insertion cursor and active text
  void _paintEditText(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    _drawDoc(canvas, Rect.fromLTWH(w * 0.18, h * 0.10, w * 0.64, h * 0.80), stroke);

    // Text lines
    canvas.drawLine(Offset(w * 0.30, h * 0.32), Offset(w * 0.70, h * 0.32), stroke);
    canvas.drawLine(Offset(w * 0.30, h * 0.62), Offset(w * 0.70, h * 0.62), stroke);

    // Typing insertion cursor "|"
    final cursorPaint = Paint()
      ..color = color
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.44, h * 0.42), Offset(w * 0.44, h * 0.52), cursorPaint);

    // Small edited character indicator
    canvas.drawLine(Offset(w * 0.48, h * 0.47), Offset(w * 0.68, h * 0.47), stroke);
  }

  // 15. PDF to Word: PDF outline pointing with arrow to Word outline
  void _paintPdfToWord(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    // PDF Source Doc (Left)
    _drawDoc(canvas, Rect.fromLTWH(w * 0.06, h * 0.20, w * 0.38, h * 0.60), stroke);

    // Conversion arrow in center
    final arrow = Path()
      ..moveTo(w * 0.46, h * 0.50)
      ..lineTo(w * 0.54, h * 0.50)
      ..lineTo(w * 0.50, h * 0.44)
      ..moveTo(w * 0.54, h * 0.50)
      ..lineTo(w * 0.50, h * 0.56);
    canvas.drawPath(arrow, stroke);

    // Word Target Doc (Right) with "W" stroke
    final wordRect = Rect.fromLTWH(w * 0.56, h * 0.20, w * 0.38, h * 0.60);
    canvas.drawRRect(RRect.fromRectAndRadius(wordRect, Radius.circular(w * 0.08)), fill);
    _drawDoc(canvas, wordRect, stroke);

    // "W" shape
    final wPath = Path()
      ..moveTo(w * 0.63, h * 0.44)
      ..lineTo(w * 0.67, h * 0.60)
      ..lineTo(w * 0.72, h * 0.48)
      ..lineTo(w * 0.77, h * 0.60)
      ..lineTo(w * 0.81, h * 0.44);
    canvas.drawPath(wPath, stroke);
  }

  // 16. Summarize PDF: Document with AI sparkle star
  void _paintSummarize(Canvas canvas, Size size, Paint stroke, Paint fill, Paint solid) {
    final w = size.width;
    final h = size.height;

    _drawDoc(canvas, Rect.fromLTWH(w * 0.14, h * 0.15, w * 0.48, h * 0.70), stroke);

    // Summary bullets
    canvas.drawLine(Offset(w * 0.24, h * 0.36), Offset(w * 0.50, h * 0.36), stroke);
    canvas.drawLine(Offset(w * 0.24, h * 0.50), Offset(w * 0.50, h * 0.50), stroke);
    canvas.drawLine(Offset(w * 0.24, h * 0.64), Offset(w * 0.50, h * 0.64), stroke);

    // 4-point AI sparkle star (Top Right)
    final sparkCenter = Offset(w * 0.75, h * 0.40);
    final sparkRadius = w * 0.20;
    final spark = Path()
      ..moveTo(sparkCenter.dx, sparkCenter.dy - sparkRadius)
      ..quadraticBezierTo(sparkCenter.dx, sparkCenter.dy, sparkCenter.dx + sparkRadius, sparkCenter.dy)
      ..quadraticBezierTo(sparkCenter.dx, sparkCenter.dy, sparkCenter.dx, sparkCenter.dy + sparkRadius)
      ..quadraticBezierTo(sparkCenter.dx, sparkCenter.dy, sparkCenter.dx - sparkRadius, sparkCenter.dy)
      ..quadraticBezierTo(sparkCenter.dx, sparkCenter.dy, sparkCenter.dx, sparkCenter.dy - sparkRadius)
      ..close();
    canvas.drawPath(spark, solid);
  }

  @override
  bool shouldRepaint(covariant _SemanticPdfPainter oldDelegate) {
    return oldDelegate.toolId != toolId || oldDelegate.color != color;
  }
}
