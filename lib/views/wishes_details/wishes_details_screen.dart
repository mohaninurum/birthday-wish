import 'package:birthday_photo_maker/constant/color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../provider/Home_provider/Home_provider.dart';
import '../../routes/app_routes_name.dart';
import '../../widgets/BirthdayLoadingRing.dart';

class wishesDetailsScreen extends StatefulWidget {
  wishesDetailsScreen({Key? key}) : super(key: key);

  @override
  State<wishesDetailsScreen> createState() => _wishesDetailsScreenState();
}

class _wishesDetailsScreenState extends State<wishesDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<HomeProvider>().wishesDetailsSubCategoryListByID();
    });
    super.initState();
  }

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    // HapticFeedback.lightImpact();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  Future<void> _shareText(String text) async {
    // HapticFeedback.selectionClick();
    await Share.share(text, subject: 'Birthday Wish');
  }

  // Helper to safely extract wish text from different model shapes.
  // Replace with your exact field (e.g., item.message) if you know it.
  String _getWishText(dynamic item) {
    try {
      return item?.wish ?? item?.message ?? item?.title ?? item?.name ?? item?.categoryName ?? item.toString();
    } catch (_) {
      return item.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Wishes List"),
        backgroundColor: AppColors.cardColor1,
        elevation: 0,
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

          // Use the list you populate in getWishesSubCategoryList()
          final list = provider.wishesDetailsListModel?.data ?? []; // Or provider.wishesSubCategoryList

          if (list.isEmpty) {
            return const Center(child: Text("No wishes found", style: TextStyle(color: Colors.white70)));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final dynamic item = list[index].wishes;
              final wishText = _getWishText(item);

              return _WishCard(
                text: wishText,
                onShare: () => _shareText(wishText),
                onCopy: () => _copyText(wishText),
                onTap: () {
                  // If you still want navigation on tap:
                  // context.read<HomeProvider>().getFrameListByCategoryId(item.categoryIdPk, wishText);
                  // Navigator.pushNamed(context, AppRoutesName.frameListScreen, arguments: item);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _WishCard extends StatelessWidget {
  final String text;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback? onTap;

  const _WishCard({
    Key? key,
    required this.text,
    required this.onShare,
    required this.onCopy,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color cardBg = AppColors.cardColor1; // dark card
    final Color border = Colors.white.withOpacity(0.06);
    final Color iconColor = const Color(0xFF8A2BE2); // purple like screenshot

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Centered text with extra bottom padding so it doesn't clash with buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 60),
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.92),
                      height: 1.45,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // Action buttons (bottom-right)
              Positioned(
                right: 12,
                bottom: 12,
                child: Row(
                  children: [
                    _ActionBtn(
                      icon: Icons.share_outlined,
                      iconColor: iconColor,
                      onTap: onShare,
                    ),
                    const SizedBox(width: 8),
                    _ActionBtn(
                      icon: Icons.copy_outlined,
                      iconColor: iconColor,
                      onTap: onCopy,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionBtn({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg =  AppColors.appWhiteColor;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}