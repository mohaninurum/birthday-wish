import 'dart:math' as math;
import 'package:flutter/material.dart';

class BirthdayLoadingRing extends StatefulWidget {
  const BirthdayLoadingRing({
    super.key,
    this.size = 45,
    this.strokeWidth = 4,
    this.colors = const [
      Color(0xFFFF8EC7),
      Color(0xFF8E2DE2),
      Color(0xFF4A00E0),
    ],
    this.trackColor = Colors.white12,
    this.duration = const Duration(seconds: 2),
    this.showGlow = true,
    this.glowSigma = 6,        // blur strength (4–8 recommended)
    this.glowWidthExtra = 2,   // extra width for glow vs arc
    this.glowOpacity = 0.5,    // 0..1 (lower = lighter glow)
    this.child,
  })  : assert(glowSigma >= 0),
        assert(glowWidthExtra >= 0),
        assert(glowOpacity >= 0 && glowOpacity <= 1);

  final double size;
  final double strokeWidth;
  final List<Color> colors;
  final Color trackColor;
  final Duration duration;
  final bool showGlow;

  final double glowSigma;
  final double glowWidthExtra;
  final double glowOpacity;

  final Widget? child;

  @override
  State<BirthdayLoadingRing> createState() => _BirthdayLoadingRingState();
}

class _BirthdayLoadingRingState extends State<BirthdayLoadingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
  AnimationController(vsync: this, duration: widget.duration)..repeat();

  @override
  void didUpdateWidget(covariant BirthdayLoadingRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _controller
        ..reset()
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _SpinnerPainter(
                animation: _controller,
                strokeWidth: widget.strokeWidth,
                colors: widget.colors,
                trackColor: widget.trackColor,
                showGlow: widget.showGlow,
                glowSigma: widget.glowSigma,
                glowWidthExtra: widget.glowWidthExtra,
                glowOpacity: widget.glowOpacity,
              ),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({
    required this.animation,
    required this.strokeWidth,
    required this.colors,
    required this.trackColor,
    required this.showGlow,
    required this.glowSigma,
    required this.glowWidthExtra,
    required this.glowOpacity,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final double strokeWidth;
  final List<Color> colors;
  final Color trackColor;
  final bool showGlow;

  final double glowSigma;
  final double glowWidthExtra;
  final double glowOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value; // 0..1
    final rotation = t * 2 * math.pi;
    final startAngle = rotation - math.pi / 2; // start at top
    final wave = (math.sin(t * 2 * math.pi) + 1) / 2; // 0..1
    const double minSweep = 0.45 * math.pi; // ~81°
    const double maxSweep = 1.25 * math.pi; // ~225°
    final sweepAngle = minSweep + (maxSweep - minSweep) * wave;

    final stroke = strokeWidth;
    final arcRect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, 0, 2 * math.pi, false, trackPaint);

    // Ensure gradient has at least 2 stops
    final baseColors = (colors.isEmpty)
        ? const [Colors.white, Colors.white]
        : (colors.length == 1 ? [colors.first, colors.first] : colors);

    // Gradient shader around the ring (for the main arc)
    final arcShader = SweepGradient(
      colors: baseColors,
      startAngle: 0,
      endAngle: 2 * math.pi,
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(arcRect);

    // Soft glow (lighter and cheaper than before)
    if (showGlow && glowOpacity > 0 && glowSigma > 0) {
      final glowShader = SweepGradient(
        colors: baseColors.map((c) => c.withOpacity(glowOpacity)).toList(),
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(arcRect);

      final glowPaint = Paint()
        ..shader = glowShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + glowWidthExtra
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSigma)
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(arcRect, startAngle, sweepAngle, false, glowPaint);
    }

    // Foreground arc
    final arcPaint = Paint()
      ..shader = arcShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter old) {
    return old.strokeWidth != strokeWidth ||
        old.colors != colors ||
        old.trackColor != trackColor ||
        old.showGlow != showGlow ||
        old.glowSigma != glowSigma ||
        old.glowWidthExtra != glowWidthExtra ||
        old.glowOpacity != glowOpacity;
  }
}