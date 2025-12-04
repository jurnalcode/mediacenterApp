import 'package:flutter/material.dart';

class RibbonAccent extends StatelessWidget {
  final Widget child;
  final Color ribbonColor;
  final Color shadowColor;
  final double ribbonHeight;
  final double ribbonWidth;

  const RibbonAccent({
    super.key,
    required this.child,
    this.ribbonColor = const Color(0xFF4A148C),
    this.shadowColor = const Color(0xFF2E0854),
    this.ribbonHeight = 40,
    this.ribbonWidth = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        // Aksen pita
        Positioned(
          top: -5,
          right: -20,
          child: CustomPaint(
            size: Size(ribbonWidth, ribbonHeight),
            painter: RibbonPainter(
              ribbonColor: ribbonColor,
              shadowColor: shadowColor,
            ),
          ),
        ),
      ],
    );
  }
}

class RibbonPainter extends CustomPainter {
  final Color ribbonColor;
  final Color shadowColor;

  RibbonPainter({
    required this.ribbonColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ribbonColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;

    // Buat jalur pita
    final path = Path();
    final shadowPath = Path();

    // Bentuk pita utama
    path.moveTo(0, 0);
    path.lineTo(size.width - 20, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 20, size.height);
    path.lineTo(0, size.height);
    path.lineTo(15, size.height / 2);
    path.close();

    // Jalur bayangan (sedikit bergeser)
    shadowPath.moveTo(2, 2);
    shadowPath.lineTo(size.width - 18, 2);
    shadowPath.lineTo(size.width + 2, size.height / 2 + 2);
    shadowPath.lineTo(size.width - 18, size.height + 2);
    shadowPath.lineTo(2, size.height + 2);
    shadowPath.lineTo(17, size.height / 2 + 2);
    shadowPath.close();

    // Gambar bayangan terlebih dahulu
    canvas.drawPath(shadowPath, shadowPaint);
    // Gambar pita utama
    canvas.drawPath(path, paint);

    // Tambahkan sorotan
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(0, 0);
    highlightPath.lineTo(size.width - 20, 0);
    highlightPath.lineTo(size.width - 15, 8);
    highlightPath.lineTo(5, 8);
    highlightPath.lineTo(15, size.height / 2);
    highlightPath.lineTo(0, size.height / 3);
    highlightPath.close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CornerRibbon extends StatelessWidget {
  final String text;
  final Color ribbonColor;
  final Color textColor;
  final double size;

  const CornerRibbon({
    super.key,
    required this.text,
    this.ribbonColor = const Color(0xFF4A148C),
    this.textColor = Colors.white,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: CornerRibbonPainter(
            ribbonColor: ribbonColor,
            text: text,
            textColor: textColor,
          ),
        ),
      ),
    );
  }
}

class CornerRibbonPainter extends CustomPainter {
  final Color ribbonColor;
  final String text;
  final Color textColor;

  CornerRibbonPainter({
    required this.ribbonColor,
    required this.text,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ribbonColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = ribbonColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Buat pita segitiga
    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Bayangan
    final shadowPath = Path();
    shadowPath.moveTo(size.width + 2, 2);
    shadowPath.lineTo(size.width + 2, size.height + 2);
    shadowPath.lineTo(2, size.height + 2);
    shadowPath.close();

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, paint);

    // Tambahkan efek lipatan
    final foldPaint = Paint()
      ..color = ribbonColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final foldPath = Path();
    foldPath.moveTo(size.width - 15, size.height);
    foldPath.lineTo(size.width, size.height - 15);
    foldPath.lineTo(size.width, size.height);
    foldPath.close();

    canvas.drawPath(foldPath, foldPaint);

    // Tambahkan teks
    if (text.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Putar dan posisikan teks
      canvas.save();
      canvas.translate(size.width - 25, size.height - 25);
      canvas.rotate(-0.785398); // -45 derajat
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
