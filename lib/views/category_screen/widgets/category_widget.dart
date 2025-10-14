import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../routes/app_routes_name.dart';
import 'feature_card_widget.dart';


class CategoryWidget extends StatelessWidget {
  const CategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return   Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GridView.count(
          //   crossAxisCount: 2,
          //   mainAxisSpacing:1,
          //   crossAxisSpacing: 1,
          // shrinkWrap: true, // <--- important
          // physics: const NeverScrollableScrollPhysics(),
          //   children: [
          //     FeatureCard(
          //       title: "Birthday poster",
          //       color1: const Color(0xFFFFA85E),
          //       color2: const Color(0xFFFF9350),
          //       icon: Icons.insert_photo_outlined,
          //       onTab: () {
          //         Navigator.pushNamed(context,AppRoutesName.frameListScreen);
          //
          //       },
          //     ),
          //      FeatureCard(
          //       title: "Birthday wishes",
          //       color1: Color(0xFFFF90AF),
          //       color2: Color(0xFFFF7BA4),
          //       icon: Icons.chat_bubble_outline,
          //        onTab: () {
          //
          //        },
          //     ),
          //      FeatureCard(
          //       title: "Name on cake",
          //       color1: Color(0xFFD1A6FF),
          //       color2: Color(0xFFB890FF),
          //       icon: Icons.cake_outlined,
          //        onTab: () {
          //
          //        },
          //     ),
          //      FeatureCard(
          //       title: "Photo On Cake",
          //       color1: Color(0xFFFFE267),
          //       color2: Color(0xFFFFCF56),
          //       icon: Icons.photo_camera_back_outlined,
          //        onTab: () {
          //
          //        },
          //     ),
          //   ],
          // ),
          const SizedBox(height: 10),
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [
                  Color(0xffff6a6a),
                  Color(0xffff5f5f),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.image_outlined, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Creation",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Your all work here",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

