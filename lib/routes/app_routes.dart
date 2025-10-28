
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';


import '../model/frame_list_model/frame_list_model.dart';
import '../views/birthday_wishes/birthday_wishes_category_screen.dart';
import '../views/birthday_wishes_Sub_category_List_screen/birthday_wishes_Sub_category_List_screen.dart';
import '../views/cake_frame/cake_frame.dart';
import '../views/category_screen/category_screen.dart';
import '../views/frame_category/frame_category.dart';
import '../views/frame_editor/editor_screen.dart';
import '../views/frame_editor/frame_editor_screen.dart';
import '../views/frame_list/frame_list_screen.dart';
import '../views/home_screen/home_screen.dart';
import '../views/splash_screen/splash_screen.dart';
import '../views/wishes_details/wishes_details_screen.dart';
import 'app_routes_name.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutesName.splashScreen:
        return PageTransition(child: SplashScreen(
    title: 'Birthday Wish',
    subtitle: 'Create, edit and share your ideas',
    gradientColors: const [Color(0xFFFF6CAB), Color(0xFF7367F0)],
    nextScreen: const HomeScreen(),
    onInit: () async {
    // Do your startup work here
    await Future.delayed(const Duration(milliseconds: 600));
    },
    ),
    type: PageTransitionType.leftToRight, duration: const Duration(milliseconds: 500), settings: settings);
      case AppRoutesName.homeScreen:
        return PageTransition(child: HomeScreen(), type: PageTransitionType.fade, alignment: Alignment.center, duration: const Duration(milliseconds: 500), settings: settings);
         case AppRoutesName.frameListScreen:
        return PageTransition(child: FrameListScreen(), type: PageTransitionType.rightToLeft, alignment: Alignment.center, duration: const Duration(milliseconds: 500), settings: settings);
         case AppRoutesName.frameCategory:
        return PageTransition(child: FrameCategory(), type: PageTransitionType.rightToLeft, alignment: Alignment.center, duration: const Duration(milliseconds: 500), settings: settings);
         case AppRoutesName.birthdayWishesScreen:
        return PageTransition(child: BirthdayWishesCategoryScreen(), type: PageTransitionType.rightToLeft, alignment: Alignment.center, duration: const Duration(milliseconds: 500), settings: settings);
         case AppRoutesName.frameEditorScreen:
           final frame = settings.arguments as FrameData;
        return PageTransition(child: EditorScreen(frame: frame,), type: PageTransitionType.leftToRight, alignment: Alignment.center, duration: const Duration(milliseconds: 500), settings: settings);
         case AppRoutesName.birthdayWishesSubCategoryListScreen:
        return PageTransition(child: BirthdayWishesSubCategoryListScreen(), type: PageTransitionType.leftToRight, alignment: Alignment.center, duration: const Duration(milliseconds: 500), settings: settings);
          case AppRoutesName.wishesDetailsScreen:
        return PageTransition(child: wishesDetailsScreen(), type: PageTransitionType.leftToRight, alignment: Alignment.center, duration: const Duration(milliseconds: 500), settings: settings);
         case AppRoutesName.cakeFrame:
        return PageTransition(child: CakeFrame(), type: PageTransitionType.leftToRight, alignment: Alignment.center, duration: const Duration(milliseconds: 500), settings: settings);

      // case AppRoutesName.frameEditorScreen:
      //      final frame = settings.arguments as FrameModel;
      //   return PageTransition(child: FrameEditorScreen(frame: frame), type: PageTransitionType.leftToRight, alignment: Alignment.center, duration: const Duration(milliseconds: 500), settings: settings);

      default:
        return PageTransition(child: Scaffold(), type: PageTransitionType.rightToLeft, duration: const Duration(milliseconds: 300), settings: settings);
    }
  }
}
