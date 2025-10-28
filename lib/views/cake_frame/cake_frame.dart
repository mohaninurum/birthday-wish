import 'package:birthday_photo_maker/constant/color/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/Home_provider/Home_provider.dart';
import '../../routes/app_routes_name.dart';
import '../../widgets/BirthdayLoadingRing.dart';
import '../../model/frame_list_model/frame_list_model.dart';



class CakeFrame extends StatefulWidget {
  const CakeFrame({super.key});

  @override
  State<CakeFrame> createState() => _CakeFrameState();
}

class _CakeFrameState extends State<CakeFrame> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().getCakeFrame();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor1,
        title: Consumer<HomeProvider>(
          builder: (context, value, _) =>
              Text("Frame List "),//
        ),
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          if (provider.statusCode == "404" ||  provider.cakeFramesResponse?.data.length==0) {
            return const Center(child: Text("No Data found"));
          }
          return Column(
            children: [
           provider.isLoadingCakeframe? BirthdayLoadingRing(): SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10,),
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
                        itemCount: provider.cakeFramesResponse?.data.length,
                        itemBuilder: (context, index) {
                          final frame = FrameData(frameImage:  provider.cakeFramesResponse?.data[index].cakeFramesImage);
                          return GestureDetector(
                            onTap: () {
                              print('onTab');
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
                                    imageUrl:  provider.cakeFramesResponse?.data[index].cakeFramesImage??'',
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
                  ),
                ),
              )


            ],
          );
        },
      ),
    );
  }
}
