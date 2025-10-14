import 'package:birthday_photo_maker/constant/color/app_colors.dart';
import 'package:birthday_photo_maker/views/category_screen/widgets/category_widget.dart';
import 'package:birthday_photo_maker/views/category_screen/widgets/feature_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../model/frame_list_model/frame_list_model.dart';

import '../../provider/Home_provider/Home_provider.dart';
import '../../routes/app_routes_name.dart';
import '../../widgets/BirthdayLoadingRing.dart';
import '../../widgets/home_app_bar/birthday_appBar_widget.dart';

class CategoryScreen extends StatefulWidget {
  CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final birthdayGradient = const LinearGradient(
    colors: [
      Color(0xFFFF6CAB),
      Color(0xFFFF8E53),
      Color(0xFF7367F0),
    ], // pink → orange → purple
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final myCreationGradient = LinearGradient(
    colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<HomeProvider>().getCategoryList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.appWhiteColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(183),
          child: const BirthdayAppBar(
            title: 'Happy Birthday, Sam',
            subtitle: 'Wishing you a day full of joy and surprises! 🎁',
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // CategoryWidget(),
              Consumer<HomeProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: BirthdayLoadingRing(),
                      ),
                    );
                  }

                  final categoryList =
                      provider.categoryResponseModel?.data ?? [];

                  return GridView.builder(
                    itemCount: categoryList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                          mainAxisExtent: 180

                        ),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final categoryItem = categoryList[index];

                      return GestureDetector(
                        onTap: () {
                          print(
                            "category tapped: ${categoryItem.categoryName}",
                          );
                          Navigator.pushNamed(
                            context,
                            AppRoutesName.frameListScreen,
                            arguments: categoryItem,
                          );
                        },
                        child: FeatureCard(
                          title: categoryItem.categoryName,
                          color1: AppColors.appSecondaryColor.withValues(
                            alpha: 0.3,
                          ),
                          color2: AppColors.appSecondaryColor.withValues(
                            alpha: 0.8,
                          ),
                          icon: Icons.insert_photo_outlined,
                        ),
                      );
                    },
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: buildMyCreationCard(
                  context,
                  imageUrl:
                      'https://images.unsplash.com/photo-1496317899792-9d7dbcd928a1?auto=format&fit=crop&w=900&q=80',
                  totalCount: 12,
                  draftsCount: 3,
                  onTap: () {
                    // Navigate to My Creation page
                  },
                ),
              ),

              // SizedBox(height: 24),
              //        _buildPopularFramesSection(context),
              //        const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBirthdayCard(
    BuildContext context, {
    required String name,
    required String imageUrl, // cake/balloons image
    VoidCallback? onTap,
    int? turningAge, // optional
    DateTime? date, // optional birthday date
  }) {
    final subtitle = () {
      if (turningAge == null && date == null)
        return 'Wishing you a wonderful day!';
      final pieces = <String>[];
      if (turningAge != null) pieces.add('Turns $turningAge');
      if (date != null) pieces.add(_formatDate(date));
      return pieces.join(' • ');
    }();

    final days = date != null ? _daysUntil(date) : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6CAB), Color(0xFFFF8E53), Color(0xFF7367F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative sparkles (subtle)
            Positioned(
              top: 10,
              left: 12,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withOpacity(0.35),
                size: 18,
              ),
            ),
            Positioned(
              bottom: 14,
              left: 60,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withOpacity(0.20),
                size: 16,
              ),
            ),
            Positioned(
              top: 16,
              right: 92,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withOpacity(0.20),
                size: 14,
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Left: Texts + chip
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Happy Birthday, $name! 🎉',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.28),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.cake_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                days != null
                                    ? (days == 0
                                          ? 'Today! 🥳'
                                          : 'In $days days')
                                    : 'Celebrate',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 90,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: Colors.black12.withOpacity(0.05),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Small badge top-right
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🎈', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  int _daysUntil(DateTime birthday) {
    final now = DateTime.now();
    var next = DateTime(now.year, birthday.month, birthday.day);
    if (next.isBefore(DateTime(now.year, now.month, now.day))) {
      next = DateTime(now.year + 1, birthday.month, birthday.day);
    }
    return next.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  Widget buildMyCreationCard(
    BuildContext context, {
    required String imageUrl, // artwork/creation image
    VoidCallback? onTap,
    String title = 'My Creation!',
    int? totalCount, // optional: total projects
    int? draftsCount, // optional: drafts count
    Gradient? gradient, // optional: override gradient
  }) {
    final subtitle = () {
      final pieces = <String>[];
      if (totalCount != null) pieces.add('$totalCount projects');
      // if (draftsCount != null) pieces.add('$draftsCount drafts');
      return pieces.isEmpty
          ? 'Create, edit and share your ideas'
          : pieces.join(' • ');
    }();

    final chipLabel = (draftsCount ?? 0) > 0 ? 'Continue' : 'Create new';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          gradient:
              gradient ??
              LinearGradient(
                colors: [
                  AppColors.appSecondaryColor.withValues(alpha: 0.7),
                  AppColors.appSecondaryColor.withValues(alpha: 0.3),
                ], // teal → blue
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative sparkles (same vibe)
            Positioned(
              top: 10,
              left: 12,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withOpacity(0.35),
                size: 18,
              ),
            ),
            Positioned(
              bottom: 14,
              left: 60,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withOpacity(0.20),
                size: 16,
              ),
            ),
            Positioned(
              top: 16,
              right: 92,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withOpacity(0.20),
                size: 14,
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Left: Texts + chip
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$title 🎨',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.28),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.brush_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                chipLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 90,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: Colors.black12.withOpacity(0.05),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Small badge top-right
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('✨', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularFramesSection(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
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
              final frame =
                  provider.frameResponse?.data?[index]; //BirthdayLoadingRing()
              return provider.isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : GestureDetector(
                      onTap: () {
                        print("Home Popular frame tapped");
                        Navigator.pushNamed(
                          context,
                          arguments: frame,
                          AppRoutesName.frameEditorScreen,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image that fills the tile without distortion
                            Image.network(
                              frame?.frameImage ?? '',
                              fit: BoxFit
                                  .cover, // keeps aspect ratio (no stretching)
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.black12.withOpacity(0.05),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),

                            // Border drawn ABOVE the image so it’s always visible
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            // Lock pill
                            // if (frame.isLocked)
                            //   Positioned(
                            //     top: 12,
                            //     right: 12,
                            //     child: Container(
                            //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            //       decoration: BoxDecoration(
                            //         color: Colors.purple,
                            //         borderRadius: BorderRadius.circular(20),
                            //       ),
                            //       child: const Row(
                            //         mainAxisSize: MainAxisSize.min,
                            //         children: [
                            //           Icon(Icons.lock, color: Colors.white, size: 16),
                            //           SizedBox(width: 4),
                            //           Text(
                            //             'Unlock',
                            //             style: TextStyle(
                            //               color: Colors.white,
                            //               fontSize: 12,
                            //               fontWeight: FontWeight.w600,
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                          ],
                        ),
                      ),
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
        );

        //   ListView.builder(
        //   physics: NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   scrollDirection: Axis.vertical,
        //   padding: const EdgeInsets.symmetric(horizontal: 16),
        //   itemCount: provider.frames.length - 3,
        //   itemBuilder: (context, index) {
        //     final frame = provider.frames[index + 3];
        //     return      Padding(
        //       padding: const EdgeInsets.only(left: 16),
        //       child: GestureDetector(
        //         onTap: () {
        //           provider.selectFrame(provider.frames[2].id);
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (_) => FrameEditorScreen(
        //                 frame: provider.frames[2],
        //               ),
        //             ),
        //           );
        //         },
        //         child: _buildFrameItem(
        //           provider.frames[2],
        //           220,
        //         ),
        //       ),
        //     );
        //   },
        // );

        //   Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     const Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 16),
        //       child: Text(
        //         'Popular frames',
        //         style: TextStyle(
        //           fontSize: 28,
        //           fontWeight: FontWeight.bold,
        //           color: Colors.black,
        //         ),
        //       ),
        //     ),
        //     const SizedBox(height: 16),
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 16),
        //       child: Row(
        //         children: [
        //           Expanded(
        //             child: GestureDetector(
        //               onTap: () {
        //                 provider.selectFrame(provider.frames[0].id);
        //                 Navigator.push(
        //                   context,
        //                   MaterialPageRoute(
        //                     builder: (_) => FrameEditorScreen(
        //                       frame: provider.frames[0],
        //                     ),
        //                   ),
        //                 );
        //               },
        //               child: _buildFrameItem(
        //                 provider.frames[0],
        //                 350,
        //               ),
        //             ),
        //           ),
        //           const SizedBox(width: 12),
        //           Expanded(
        //             child: GestureDetector(
        //               onTap: () {
        //                 provider.selectFrame(provider.frames[1].id);
        //                 Navigator.push(
        //                   context,
        //                   MaterialPageRoute(
        //                     builder: (_) => FrameEditorScreen(
        //                       frame: provider.frames[1],
        //                     ),
        //                   ),
        //                 );
        //               },
        //               child: _buildFrameItem(
        //                 provider.frames[1],
        //                 450,
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //     const SizedBox(height: 12),
        //     Padding(
        //       padding: const EdgeInsets.only(left: 16),
        //       child: GestureDetector(
        //         onTap: () {
        //           provider.selectFrame(provider.frames[2].id);
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (_) => FrameEditorScreen(
        //                 frame: provider.frames[2],
        //               ),
        //             ),
        //           );
        //         },
        //         child: _buildFrameItem(
        //           provider.frames[2],
        //           220,
        //         ),
        //       ),
        //     ),
        //   ],
        // );
      },
    );
  }

  Widget _buildFrameItem(FrameModel frame, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            Image.network(
              frame.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            if (frame.isLocked)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Unlock',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey.shade600,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.download,
                        color: Colors.black54,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Google_Play_Store_badge_EN.svg/512px-Google_Play_Store_badge_EN.svg.png',
                        height: 16,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade700,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.shade700.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
