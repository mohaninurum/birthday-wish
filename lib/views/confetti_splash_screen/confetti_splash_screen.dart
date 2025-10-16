import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import 'dart:math';

class ConfettiExamplePage extends StatefulWidget {
  const ConfettiExamplePage({Key? key}) : super(key: key);

  @override
  _ConfettiExamplePageState createState() => _ConfettiExamplePageState();
}

class _ConfettiExamplePageState extends State<ConfettiExamplePage> {
  late ConfettiController _confettiControllerCenter;
  late ConfettiController _confettiControllerTop;

  @override
  void initState() {
    super.initState();
    // Short burst for center
    _confettiControllerCenter =
        ConfettiController(duration: const Duration(milliseconds: 800));
    // Longer spray from top
    _confettiControllerTop =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiControllerCenter.dispose();
    _confettiControllerTop.dispose();
    super.dispose();
  }

  void _playConfetti() {
    // play both controllers (overlapping effects)
    _confettiControllerTop.play();
    _confettiControllerCenter.play();
  }

  @override
  Widget build(BuildContext context) {
    return   Column(
      children: [
        // Confetti from the center (explosion)
        ConfettiWidget(
          confettiController: _confettiControllerCenter,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          emissionFrequency: 0.6,
          numberOfParticles: 30,
          maxBlastForce: 20, // set a range for blast force
          minBlastForce: 8,
          // colors - leave default if you want the package default
          colors: const [
            Colors.red,
            Colors.blue,
            Colors.yellow,
            Colors.green,
            Colors.purple,
            Colors.orange
          ],
          createParticlePath: _drawStar, // optional custom shape
        ),

        // Confetti from top center (raining down)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiControllerTop,
              blastDirection: pi / 2, // downward
              blastDirectionality: BlastDirectionality.directional,
              emissionFrequency: 0.05,
              numberOfParticles: 10,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Colors.pink,
                Colors.lightBlue,
                Colors.lightGreen,
                Colors.amber
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Example custom particle shape: a star path.
  /// You can remove `createParticlePath` in ConfettiWidget if you don't want custom shapes.
  Path _drawStar(Size size) {
    // draws a 5-point star scaled to size
    const int points = 5;
    final double halfWidth = size.width / 2;
    final double externalRadius = halfWidth;
    final double internalRadius = halfWidth / 2.5;
    final Path path = Path();
    final double step = pi / points;
    final double shift = -pi / 2; // rotate so star points up

    for (int i = 0; i < points * 2; i++) {
      final double radius = i.isEven ? externalRadius : internalRadius;
      final double x = halfWidth + radius * cos(i * step + shift);
      final double y = halfWidth + radius * sin(i * step + shift);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }
}
