import 'package:flutter/material.dart';

class EcgChart extends StatefulWidget {
  final int bpm;
  final double height;

  const EcgChart({super.key, required this.bpm, this.height = 150});

  @override
  State<EcgChart> createState() => _EcgChartState();
}

class _EcgChartState extends State<EcgChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Store points relative to the canvas width (0.0 to 1.0)
  final List<Offset> _points = [];

  // Simulation parameters

  @override
  void initState() {
    super.initState();
    // Use a fast ticker for smooth animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(_tick);
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    super.dispose();
  }

  void _tick() {
    setState(() {
      _updatePoints();
    });
  }

  void _updatePoints() {
    // Constant speed for the strip chart (scrolling effect)
    // 0.005 width units per tick.
    const double speed = 0.005;

    // Move existing points left
    for (int i = 0; i < _points.length; i++) {
      _points[i] = Offset(_points[i].dx - speed, _points[i].dy);
    }

    // Remove off-screen points
    _points.removeWhere((p) => p.dx < 0);

    // Add new point at the right edge
    // Map BPM to Y coordinate (0.0 to 1.0) inside the container.
    // 0.0 is top, 1.0 is bottom.
    // Let's assume range 40 BPM (bottom) to 160 BPM (top).
    // Note: In Flutter CustomPainter, 0 is top. So we invert logic if we want high BPM at top.

    double minBpm = 40.0;
    double maxBpm = 160.0;

    double normalizedBpm = (widget.bpm - minBpm) / (maxBpm - minBpm);
    // Clamp to valid range
    normalizedBpm = normalizedBpm.clamp(0.0, 1.0);

    // Invert because 0 is top
    double y = 1.0 - normalizedBpm;

    // We add points slightly off screen to avoid popping
    _points.add(Offset(1.0, y));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      color: Colors.transparent, // Background handled by parent or painter
      child: ClipRect(
        child: CustomPaint(
          painter: EcgPainter(_points, const Color(0xFF6466F1)),
        ),
      ),
    );
  }
}

class EcgPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  EcgPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Create a path
    final path = Path();

    // First point
    path.moveTo(points[0].dx * size.width, points[0].dy * size.height);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }

    // Optional: Add a "fading" trail or gradient
    // For now, solid line
    canvas.drawPath(path, paint);

    // Draw "lead" point (glowing dot at the end)
    if (points.isNotEmpty) {
      final lastHtml = points.last;
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(lastHtml.dx * size.width, lastHtml.dy * size.height),
        3.0,
        dotPaint,
      );

      // Glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(
        Offset(lastHtml.dx * size.width, lastHtml.dy * size.height),
        8.0,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for animation
  }
}
