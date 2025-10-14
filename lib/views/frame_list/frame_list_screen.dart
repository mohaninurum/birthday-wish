

import 'package:birthday_photo_maker/constant/color/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/Home_provider/Home_provider.dart';
import '../../routes/app_routes_name.dart';
import '../../widgets/BirthdayLoadingRing.dart';
import '../../widgets/app_bar_widgets/app_bar_widget.dart';
import '../frame_editor/frame_editor_screen.dart';

class FrameListScreen extends StatefulWidget {
  const FrameListScreen({super.key});

  @override
  State<FrameListScreen> createState() => _FrameListScreenState();
}

class _FrameListScreenState extends State<FrameListScreen> {

  @override
  void initState() {
    context.read<HomeProvider>().getFrameList();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appWhiteColor,

      // Birthday app bar
      appBar: AppBar(title: Text("Frame List "),backgroundColor: AppColors.appSecondaryColor.withValues(alpha: 0.6),),

      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tip: You can remove this header to avoid duplicate titles.
                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                //   child: Text(
                //     'Popular frames',
                //     style: TextStyle(
                //       color: AppColors.appBlackColor,
                //       fontSize: 18,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              SizedBox(height: 15,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                  provider.isLoading?const Center(child: BirthdayLoadingRing(),):
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: provider.frameResponse?.data?.length,
                    itemBuilder: (context, index) {
                      final frame = provider.frameResponse?.data?[index];
                      return GestureDetector(
                        onTap: () {
                          print("Single frame list Popular frame tapped");
                          Navigator.pushNamed(context, arguments: frame,AppRoutesName.frameEditorScreen);
                        },
                        child:  provider.frameResponse?.data?.isNotEmpty == true ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Image that fills the tile without distortion
                              CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: frame?.frameImage??'',
                                progressIndicatorBuilder: (context, url, downloadProgress) =>
                                    Center(child:  BirthdayLoadingRing()),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                              // Image.network(
                              //   frame?.frameImage??'',
                              //   fit: BoxFit.cover, // keeps aspect ratio (no stretching)
                              //   loadingBuilder: (context, child, progress) {
                              //     if (progress == null) return child;
                              //     return Container(
                              //       color: Colors.black12.withOpacity(0.05),
                              //       child: const Center(child: BirthdayLoadingRing()),
                              //     );
                              //   },
                              //   errorBuilder: (_, __, ___) => const Center(
                              //     child: Icon(Icons.broken_image_outlined, color: Colors.grey),
                              //   ),
                              // ),

                              // Border drawn ABOVE the image so it’s always visible
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.borderColor, width: 1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),

                              // Lock pill
                              // if (frame.isLocked)
                                // Positioned(
                                //   top: 12,
                                //   right: 12,
                                //   child: Container(
                                //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                //     decoration: BoxDecoration(
                                //       color: Colors.purple,
                                //       borderRadius: BorderRadius.circular(20),
                                //     ),
                                //     child: const Row(
                                //       mainAxisSize: MainAxisSize.min,
                                //       children: [
                                //         Icon(Icons.lock, color: Colors.white, size: 16),
                                //         SizedBox(width: 4),
                                //         Text(
                                //           'Unlock',
                                //           style: TextStyle(
                                //             color: Colors.white,
                                //             fontSize: 12,
                                //             fontWeight: FontWeight.w600,
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                            ],
                          ),
                        ): Container(child: Text("No data found"),),
                        // Container(
                        //   margin: const EdgeInsets.only(right: 12),
                        //   decoration: BoxDecoration(
                        //     border: Border.all(color: AppColors.borderColor),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child: Stack(
                        //     children: [
                        //       ClipRRect(
                        //         borderRadius: BorderRadius.circular(12),
                        //         child: Image.network(
                        //           frame.imageUrl,
                        //           fit: BoxFit.fill,
                        //         ),
                        //       ),
                        //       if (frame.isLocked)
                        //         Positioned(
                        //           top: 12,
                        //           right: 12,
                        //           child: Container(
                        //             padding: const EdgeInsets.symmetric(
                        //               horizontal: 12,
                        //               vertical: 6,
                        //             ),
                        //             decoration: BoxDecoration(
                        //               color: Colors.purple,
                        //               borderRadius: BorderRadius.circular(20),
                        //             ),
                        //             child: const Row(
                        //               mainAxisSize: MainAxisSize.min,
                        //               children: [
                        //                 Icon(
                        //                   Icons.lock,
                        //                   color: Colors.white,
                        //                   size: 16,
                        //                 ),
                        //                 SizedBox(width: 4),
                        //                 Text(
                        //                   'Unlock',
                        //                   style: TextStyle(
                        //                     color: Colors.white,
                        //                     fontSize: 12,
                        //                     fontWeight: FontWeight.w600,
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        //     ],
                        //   ),
                        // ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 120,
                  child:   provider.isLoading?const Center(child: BirthdayLoadingRing(),
                  ): ListView.builder(
                    scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final frame = provider.frameResponse?.data?[index];
                      return GestureDetector(
                        onTap: () {
                          provider.selectFrame(frame?.frameIdPk.toString()??"");
                          print("Single frame list Popular frame tapped");
                          Navigator.pushNamed(context, arguments: frame,AppRoutesName.frameEditorScreen);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _getGradientColors(index + 5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  frame?.frameImage??'',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // if (frame.discount != null)
                              //   Positioned(
                              //     top: 8,
                              //     left: 8,
                              //     child: Container(
                              //       padding: const EdgeInsets.symmetric(
                              //         horizontal: 8,
                              //         vertical: 4,
                              //       ),
                              //       decoration: BoxDecoration(
                              //         color: Colors.white,
                              //         borderRadius: BorderRadius.circular(8),
                              //         border: Border.all(
                              //           color: Colors.pink.shade200,
                              //           width: 2,
                              //         ),
                              //       ),
                              //       child: Text(
                              //         frame.discount!,
                              //         style: TextStyle(
                              //           color: Colors.pink.shade700,
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Color> _getGradientColors(int index) {
    final gradients = [
      [const Color(0xFFFFE5B4), const Color(0xFFFFB6C1)],
      [const Color(0xFFFFDAB9), const Color(0xFFFFB347)],
      [const Color(0xFFFF69B4), const Color(0xFFFF1493)],
      [const Color(0xFFFFD700), const Color(0xFFFFA500)],
      [const Color(0xFFFFB6C1), const Color(0xFFFF69B4)],
      [const Color(0xFFADD8E6), const Color(0xFF87CEEB)],
      [const Color(0xFFFFB6C1), const Color(0xFFFF69B4)],
      [const Color(0xFFFFDAB9), const Color(0xFFFFA07A)],
      [const Color(0xFFDDA0DD), const Color(0xFFBA55D3)],
    ];
    return gradients[index % gradients.length];
  }
}






