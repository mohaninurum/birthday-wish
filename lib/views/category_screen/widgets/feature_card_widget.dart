import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../widgets/BirthdayLoadingRing.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final Color color1;
  final Color color2;
  final String? icon;
  // Optional goodies
  final String? subtitle;          // small line under title
  final String? badgeEmoji;        // top-right badge, e.g. '✨'
  final double borderRadius;       // corner radius
  final double iconSize;           // icon size
  final double minHeight;          // min height of the card
  final EdgeInsetsGeometry padding;
  final bool showSparkles;         // decorative sparkles
  final bool showGloss;


  const FeatureCard({
    super.key,
    required this.title,
    required this.color1,
    required this.color2,
    required this.icon,
    this.subtitle,
    this.badgeEmoji = '✨',
    this.borderRadius = 24,
    this.iconSize = 50,
    this.minHeight = 140,
    this.padding = const EdgeInsets.all(16),
    this.showSparkles = true,
    this.showGloss = true,

  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    print("Image Url");
   print(icon);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: color2.withOpacity(0.20),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        ),
        child: Stack(
          children: [
            // Top glossy highlight
            if (showGloss)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        topRight: Radius.circular(borderRadius),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.08),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.35, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

            // Decorative sparkles
            if (showSparkles) ...[
              Positioned(
                top: 10,
                left: 12,
                child: Icon(Icons.auto_awesome_rounded,
                    color: Colors.white.withOpacity(0.35), size: 18),
              ),
              Positioned(
                bottom: 14,
                left: 26,
                child: Icon(Icons.auto_awesome_rounded,
                    color: Colors.white.withOpacity(0.20), size: 16),
              ),
              Positioned(
                top: 16,
                right: 40,
                child: Icon(Icons.auto_awesome_rounded,
                    color: Colors.white.withOpacity(0.20), size: 14),
              ),
            ],

            // Content
            Padding(
              padding: padding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glassy icon pill
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.28),
                              width: 1,
                            ),
                          ),
                          child:     icon !=null?  CachedNetworkImage(
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            imageUrl: icon??'',
                            progressIndicatorBuilder: (context, url, downloadProgress) =>
                                Center(child:  BirthdayLoadingRing()),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ):Icon(Icons.insert_photo_outlined),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        height: 1.1,
                      ),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Small badge (top-right)
            if ((badgeEmoji ?? '').isNotEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    badgeEmoji!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}