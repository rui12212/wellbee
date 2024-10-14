import 'package:flutter/material.dart';

class DottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final List<double> dashArray;

  DottedBorder({
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.dashArray = const [5, 3],
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        dashArray: dashArray,
      ),
      child: child,
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashArray;

  _DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashArray,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0) // Y軸
      ..lineTo(size.width, 0); // X軸

    _drawDashedLine(canvas, path, paint);
  }

  void _drawDashedLine(Canvas canvas, Path path, Paint paint) {
    final dashPath = Path();
    final totalLength = path.computeMetrics().first.length;

    double distance = 0.0;
    bool draw = true;

    while (distance < totalLength) {
      for (final dash in dashArray) {
        final length = (draw ? dash : dash);
        distance += length;
        if (distance > totalLength) {
          distance = totalLength;
        }
        final metric = path.computeMetrics().first;
        final extractPath = metric.extractPath(distance - length, distance);
        dashPath.addPath(extractPath, Offset.zero);
        draw = !draw;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
