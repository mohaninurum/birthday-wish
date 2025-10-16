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
import '../drawer_screen/drawer_screen.dart';
class FrameCategory extends StatefulWidget {
  FrameCategory({Key? key}) : super(key: key);

  @override
  State<FrameCategory> createState() => _FrameCategoryState();
}

class _FrameCategoryState extends State<FrameCategory> {
  // GlobalKey for Scaffold - drawer open karne ke liye
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final birthdayGradient = const LinearGradient(
    colors: [
      Color(0xFFFF6CAB),
      Color(0xFFFF8E53),
      Color(0xFF7367F0),
    ],
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
    return Scaffold(
      key: _scaffoldKey, // GlobalKey add kiya
      backgroundColor: AppColors.appWhiteColor,
      appBar: AppBar(title: Text("Frame Category"),backgroundColor:  AppColors.cardColor1,),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
                    mainAxisExtent: 180,
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
                        context.read<HomeProvider>().getFrameListByCategoryId(
                          categoryItem.categoryIdPk,
                          categoryItem.categoryName,
                        );
                        Navigator.pushNamed(
                          context,
                          AppRoutesName.frameListScreen,
                          arguments: categoryItem,
                        );
                      },
                      child: FeatureCard(
                        title: categoryItem.categoryName,
                        color1: AppColors.cardColor1,
                        color2: AppColors.cardColor1,
                        icon: null,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


