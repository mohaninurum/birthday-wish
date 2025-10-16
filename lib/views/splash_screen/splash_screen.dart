import 'dart:ui';
import 'package:birthday_photo_maker/constant/color/app_colors.dart';
import 'package:birthday_photo_maker/views/confetti_splash_screen/confetti_splash_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  final List<Color> gradientColors;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Duration minDisplayTime;
  final Future<void> Function()? onInit;

  const SplashScreen({
    super.key,
    required this.nextScreen,
    this.gradientColors = const [AppColors.appPrimaryPink, AppColors.appSecondaryColor],
    this.icon = Icons.brush_rounded,
    this.title = 'Birthday Wish!',
    this.subtitle = 'Create, edit and share your ideas',
    this.minDisplayTime = const Duration(seconds: 4),
    this.onInit,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    // Ensure first frame is drawn before any navigation work
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final tasks = <Future>[];
    tasks.add(Future.delayed(widget.minDisplayTime));
    if (widget.onInit != null) tasks.add(widget.onInit!());

    await Future.wait(tasks);

    if (!mounted) return;
    setState(() => _exiting = true); // fade out splash
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 50),
        pageBuilder: (_, __, ___) => widget.nextScreen,
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors.length >= 2
        ? widget.gradientColors
        : [widget.gradientColors.first, widget.gradientColors.first.withOpacity(0.7)];

    return Scaffold(
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: _exiting ? 0 : 1,
        child: Stack(
          children: [
            // Gradient background (paints immediately)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.appPrimaryPink, AppColors.appSecondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Subtle top gloss
            Positioned(
              top: 0, left: 0, right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.26),
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.35, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Sparkles
            const _Sparkle(top: 60, left: 24, size: 18, opacity: 0.35),
            const _Sparkle(bottom: 80, left: 60, size: 16, opacity: 0.22),
            const _Sparkle(top: 120, right: 80, size: 14, opacity: 0.20),

            // Center logo + title
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glassy capsule
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        // width: 200, height: 200,
                        padding: const EdgeInsets.all(18),
                        // decoration: BoxDecoration(
                        //   color: Colors.white.withOpacity(0.18),
                        //   borderRadius: BorderRadius.circular(28),
                        //   border: Border.all(color: Colors.white.withOpacity(0.28), width: 1),
                        //   boxShadow: [
                        //     BoxShadow(
                        //       color: Colors.black.withOpacity(0.12),
                        //       blurRadius: 16,
                        //       offset: const Offset(0, 8),
                        //     ),
                        //   ],
                        // ),
                        child:  Image.asset("assets/images/Birthday Wish.png",fit: BoxFit.fitWidth,width: 300,height: 300,),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      height: 1.1,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w500,
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  // Progress chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Loading...',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ConfettiExamplePage()
          ],
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  final double? top, right, bottom, left;
  final double size, opacity;
  const _Sparkle({this.top, this.right, this.bottom, this.left, this.size = 16, this.opacity = 0.25});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, right: right, bottom: bottom, left: left,
      child: Icon(Icons.auto_awesome_rounded, color: Colors.white.withOpacity(opacity), size: size),
    );
  }
}