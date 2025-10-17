import 'package:birthday_photo_maker/constant/color/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/Home_provider/Home_provider.dart';
import '../../routes/app_routes_name.dart';
import '../../widgets/BirthdayLoadingRing.dart';
import '../../model/frame_list_model/frame_list_model.dart';

// Local provider for Single/Multiple tab
enum FrameTab { single, multiple }

class FrameTabProvider extends ChangeNotifier {
  FrameTab _tab = FrameTab.single;
  FrameTab get tab => _tab;
  void setTab(FrameTab t) {
    if (_tab == t) return;
    _tab = t;
    notifyListeners();
  }
}

class FrameListScreen extends StatefulWidget {
  const FrameListScreen({super.key});

  @override
  State<FrameListScreen> createState() => _FrameListScreenState();
}

class _FrameListScreenState extends State<FrameListScreen> {

  @override
  void initState() {
    // Agar yahi se fetch karna ho:
    // context.read<HomeProvider>().getFrameList(); // ya getCategoryFrameList()
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FrameTabProvider(),
      child: Scaffold(
        backgroundColor: AppColors.appWhiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.cardColor1,
          title: Consumer<HomeProvider>(
            builder: (context, value, _) =>
                Text("${value.categoryTitle} List "),
          ),
        ),
        body: Consumer<HomeProvider>(
          builder: (context, provider, _) {
            final tab = context.watch<FrameTabProvider>().tab;
            final all = provider.categoryFrameResponse?.data ?? <FrameData>[];

            // Filter using slots
            final filtered = all.where((f) {
              return tab == FrameTab.single ? int.parse("${f.frameSlot}") == 1 : int.parse("${f.frameSlot}") >= 2;
            }).toList();

            return Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
                          if (provider.isLoadingframe) ...[
                            const SizedBox(height: 180),
                            const Center(child: BirthdayLoadingRing()),
                          ] else if (filtered.isEmpty) ...[
                            const SizedBox(height: 180),
                            Center(
                              child: Text(
                                tab == FrameTab.single
                                    ? "No data found"
                                    : "No data found",
                                style: const TextStyle(
                                  color: AppColors.appBlackColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ] else ...[
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final frame = filtered[index];
                                return GestureDetector(
                                  onTap: () {
                                    print('onTab');
                                    // Route call fix
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutesName.frameEditorScreen,
                                      arguments: frame,
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: frame.frameImage ?? '',
                                          progressIndicatorBuilder: (context, url, _) =>
                                          const Center(child: BirthdayLoadingRing()),
                                          errorWidget: (context, url, error) =>
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: const Icon(Icons.error),
                                          ),
                                        ),
                                        // Border overlay
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
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 120), // bottom pill space
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom segmented pill (screenshot jaisa)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12,
                  child: SafeArea(
                    top: false,
                    child: Center(
                      child: _SingleMultiplePill(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Segmented control widget (Single / Multiple)
class _SingleMultiplePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tab = context.watch<FrameTabProvider>().tab;

    const double height = 44;
    const double width = 230;
    final Color pillBg = const Color(0xFF1B1B1E);
    final Color selected = const Color(0xFF8B5CF6); // purple
    final Color textOn = Colors.white;
    final Color textOff = Colors.white70;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(height),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: tab == FrameTab.single
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Container(
              width: (width - 8) / 2,
              height: height - 8,
              decoration: BoxDecoration(
                color: selected,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(height),
                  onTap: () => context.read<FrameTabProvider>().setTab(FrameTab.single),
                  child: Center(
                    child: Text(
                      'Single',
                      style: TextStyle(
                        color: tab == FrameTab.single ? textOn : textOff,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(height),
                  onTap: () => context.read<FrameTabProvider>().setTab(FrameTab.multiple),
                  child: Center(
                    child: Text(
                      'Multiple',
                      style: TextStyle(
                        color: tab == FrameTab.multiple ? textOn : textOff,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}