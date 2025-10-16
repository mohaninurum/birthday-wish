import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiCenterOverlay {
  static Future<void> show(
      BuildContext context, {
        Duration duration = const Duration(seconds: 2),
        int particles = 80,            // zyada particles
        double emission = 0.16,        // dense flow
        double gravity = 0.28,         // fall speed
        bool topShower = false,        // optional top shower
        List<Color>? colors,
      }) async {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final centerCtrl = ConfettiController(duration: duration);
    final topCtrl = ConfettiController(duration: const Duration(milliseconds: 1200));

    final entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          ignoring: true,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center explosive (full screen)
              ConfettiWidget(
                confettiController: centerCtrl,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: emission,
                numberOfParticles: particles,
                gravity: gravity,
                maxBlastForce: 36,
                minBlastForce: 10,
                shouldLoop: true,
                colors: colors ??
                    const [
                      Color(0xFF8B5CF6), // purple
                      Color(0xFFEC4899), // pink
                      Color(0xFFFFC107), // amber
                      Color(0xFF22D3EE), // cyan
                      Colors.white,
                    ],
                minimumSize: const Size(10, 8),
                maximumSize: const Size(22, 18),
                createParticlePath: _starPath,
                // particleDrag: 0.02, // enable if your version supports
              ),

              if (topShower)
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: topCtrl,
                    blastDirection: pi / 2,
                    blastDirectionality: BlastDirectionality.directional,
                    emissionFrequency: 0.02,
                    numberOfParticles: 24,
                    gravity: 0.35,
                    maxBlastForce: 30,
                    minBlastForce: 12,
                    shouldLoop: false,
                    colors: colors ??
                        const [
                          Color(0xFF8B5CF6),
                          Color(0xFFEC4899),
                          Color(0xFFFFC107),
                          Color(0xFF22D3EE),
                          Colors.white,
                        ],
                    minimumSize: const Size(6, 4),
                    maximumSize: const Size(12, 10),
                    createParticlePath: _starPath,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // Play
    if (topShower) topCtrl.play();
    centerCtrl.play();

    // Stop and cleanup
    await Future.delayed(duration);
    centerCtrl.stop();
    await Future.delayed(const Duration(milliseconds: 300));

    entry.remove();
    centerCtrl.dispose();
    topCtrl.dispose();
  }

  // 5-point star particle
  static Path _starPath(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const int points = 5;
    final double outerRadius = size.shortestSide / 2.0;
    final double innerRadius = outerRadius / 2.5;
    final Path path = Path();
    final double step = degToRad(360 / points);
    final double halfStep = step / 2;
    final double start = -pi / 2;

    final Offset c = Offset(size.width / 2, size.height / 2);
    path.moveTo(c.dx + cos(start) * outerRadius, c.dy + sin(start) * outerRadius);

    for (int i = 1; i <= points; i++) {
      path.lineTo(
        c.dx + cos(start + step * i - halfStep) * innerRadius,
        c.dy + sin(start + step * i - halfStep) * innerRadius,
      );
      path.lineTo(
        c.dx + cos(start + step * i) * outerRadius,
        c.dy + sin(start + step * i) * outerRadius,
      );
    }
    path.close();
    return path;
  }
}