import 'package:birthday_photo_maker/constant/color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/Home_provider/Home_provider.dart';
import '../../routes/app_routes_name.dart';
import '../../widgets/BirthdayLoadingRing.dart';

class BirthdayWishesSubCategoryListScreen extends StatefulWidget {
  const BirthdayWishesSubCategoryListScreen({Key? key}) : super(key: key);

  @override
  State<BirthdayWishesSubCategoryListScreen> createState() =>
      _BirthdayWishesSubCategoryListScreenState();
}

class _BirthdayWishesSubCategoryListScreenState
    extends State<BirthdayWishesSubCategoryListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().getWishesSubCategoryList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.appWhiteColor,
      appBar: AppBar(
        title: const Text("Wishes List"),
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

          if (provider.statusCode == "404" || categoryList.isEmpty) {
            return const Center(child: Text("No Data found"));
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: categoryList.length,
            onReorder: (oldIndex, newIndex) {
              context
                  .read<HomeProvider>()
                  .reorderWishesSubCategoryList(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final item = categoryList[index];
              return InkWell(
                key: ValueKey(item.subCategoryIdPk), // unique key is required
                onTap: () {
                  context
                      .read<HomeProvider>()
                      .setWishesSubCategoryListByID(item.subCategoryIdPk.toString());
                  Navigator.pushNamed(
                    context,
                    AppRoutesName.wishesDetailsScreen,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor1,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.subCategoryName ?? "Unnamed",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.appWhiteColor,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.drag_handle,
                        color: Colors.white70,
                      ),
                    ],
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
