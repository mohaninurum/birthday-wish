import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CandyRibbonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? tag; // e.g., 'Birthday Mode', 'Level 25'
  final IconData leftIcon;
  final VoidCallback? onLeftTap;
  final IconData? rightIcon;
  final VoidCallback? onRightTap;
  final double height;
  final List<Color> colors;

  const CandyRibbonAppBar({
    super.key,
    this.title = 'Happy Birthday 🎉',
    this.subtitle,
    this.tag,
    this.leftIcon = Icons.arrow_back_rounded,
    this.onLeftTap,
    this.rightIcon,
    this.onRightTap,
    this.height = 105,
    this.colors = const [Color(0xFFFF7EB3), Color(0xFF8E77FF)], // pink → purple
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return
      AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: Colors.transparent,
        child: ClipPath(
          clipper: _RibbonClipper(),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // soft bokeh glows
                Positioned(top: -30, left: -24, child: _bokeh(140, 0.10)),
                Positioned(top: 20, right: -16, child: _bokeh(100, 0.08)),
                Positioned(bottom: 10, left: 40, child: _bokeh(60, 0.07)),

                // subtle confetti/balloons
                Positioned(top: 30, left: 130, child: _emoji('🎈', 26, -0.18)),
                Positioned(bottom: 27, right: 40, child: _emoji('🎉', 24, 0.12)),
                Positioned(top: 30, right: 16, child: _emoji('✨', 20, 0)),


                SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // actions row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                            child: _glassButton(
                              icon: leftIcon,
                              onTap: onLeftTap ?? () => Navigator.of(context).maybePop(),
                            ),
                          ),
                          _gradientTitle(title),
                          SizedBox(width: 60,)
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fixed: uses the icon you pass (no more hardcoded arrow)
  Widget _glassButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _bokeh(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  Widget _emoji(String e, double size, double tilt) {
    return Transform.rotate(
      angle: tilt,
      child: Text(e, style: TextStyle(fontSize: size)),
    );
  }

  Widget _gradientTitle(String text) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [Color(0xFFFFE08A), Colors.white, Color(0xFFFFD1DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          fontFamily: 'Cursive',
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _RibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double cut = 28.0; // depth of the ribbon notch
    final double flat = size.height - cut; // y where ribbon stays flat

    return Path()
      ..lineTo(0, flat)
      ..lineTo(size.width * 0.5 - 22, flat)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.5 + 22, flat)
      ..lineTo(size.width, flat)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}