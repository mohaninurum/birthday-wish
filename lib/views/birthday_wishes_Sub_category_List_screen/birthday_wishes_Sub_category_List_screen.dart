import 'package:birthday_photo_maker/constant/color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/Home_provider/Home_provider.dart';
import '../../routes/app_routes_name.dart';
import '../../widgets/BirthdayLoadingRing.dart';

class BirthdayWishesSubCategoryListScreen extends StatefulWidget {
  BirthdayWishesSubCategoryListScreen({Key? key}) : super(key: key);

  @override
  State<BirthdayWishesSubCategoryListScreen> createState() => _BirthdayWishesSubCategoryListScreenState();
}

class _BirthdayWishesSubCategoryListScreenState extends State<BirthdayWishesSubCategoryListScreen> {
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
      context.read<HomeProvider>().getWishesSubCategoryList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.appWhiteColor,
      appBar: AppBar(
        title: const Text(" Wishes List"),
        backgroundColor: AppColors.cardColor1,
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: BirthdayLoadingRing(),
              ),
            );
          }

          final categoryList = provider.wishesSubCategoryListModel?.data ?? [];

          if (provider.statusCode=="404") {
            return const Center(child: Text("No Data found"));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            physics: const BouncingScrollPhysics(),
            itemCount: categoryList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final categoryItem = categoryList[index];

              return InkWell(
                onTap: () {
                  debugPrint("category tapped: ${categoryItem.categoryName}");
                  context.read<HomeProvider>().setWishesSubCategoryListByID(categoryItem.id.toString());
                  Navigator.pushNamed(
                    context,
                    AppRoutesName.wishesDetailsScreen,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    categoryItem.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.appWhiteColor, // ensure contrast with cardColor1
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


