import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constant/color/app_colors.dart';

class BirthdayAppBar extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final String? subtitle;
  final VoidCallback? onGiftTap;
  final VoidCallback? onSettingsTap;

  const BirthdayAppBar({
    super.key,
    this.title = 'Happy Birthday',
    this.subtitle,
    this.onGiftTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return   AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: AppColors.appPrimaryPink,
        child:    ClipPath(
          clipper: _WaveClipper(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.appSecondaryColor,AppColors.secondPrimary2 ], // your palette
              ),
            ),
            child: Stack(
              children: [
                // soft glow/bokeh
                Positioned(top: -20, left: -30, child: _bokeh(120)),
                Positioned(top: 40, right: -20, child: _bokeh(80)),
                Positioned(bottom: 10, left: 30, child: _bokeh(50)),

                // subtle confetti/balloons
                Positioned(top: 18, left: 10, child: _emoji('🎈', 28, -0.2)),
                Positioned(top: 65, right: 24, child: _emoji('✨', 22, 0.0)),
                Positioned(bottom: 40, right: 10, child: _emoji('🎉', 26, 0.12)),
                Positioned(bottom: 50, left: 12, child: _emoji('🎊', 20, -0.08)),

                // highlight bloom
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.9, -1.2),
                        radius: 1.2,
                        colors: [
                          Colors.white.withOpacity(0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // top row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _glassIconButton(Icons.menu, onTap: onGiftTap),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.25)),
                              ),
                              child: const Text(
                                '🎂  Birthday Wish  🎉',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 20,)
                            // _glassIconButton(Icons.settings, onTap: onSettingsTap),
                          ],
                        ),


                        // title + subtitle
                        Center(
                          child: Column(
                            children: [
                              _gradientText('$title 🎉'),
                              if (subtitle != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  subtitle!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.92),
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )


      ),
    );


  }

  Widget _glassIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }

  Widget _bokeh(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.07),
      ),
    );
  }

  Widget _emoji(String e, double size, double tilt) {
    return Transform.rotate(
      angle: tilt,
      child: Text(e, style: TextStyle(fontSize: size)),
    );
  }

  Widget _gradientText(String text) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [Color(0xFFFFE08A), Colors.white, Color(0xFFFFD1DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: const Text(
        'Happy Birthday 🎉',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          fontFamily: 'Cursive', // or replace with a Google Font
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(
        size.width * 0.25, size.height,
        size.width * 0.5, size.height - 30,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height - 60,
        size.width, size.height - 20,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}