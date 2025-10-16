import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constant/color/app_colors.dart';
import '../../provider/theme_provider/theme_provider.dart';
import '../category_screen/category_screen.dart';
import '../frame_list/frame_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Consumer<ThemeProvider>(
          //   builder: (context, themeProvider, child) {
          //     return SwitchListTile(
          //       title: Text(themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode'),
          //       value: themeProvider.isDarkMode,
          //       onChanged: (value) {
          //         themeProvider.toggleTheme(value);
          //       },
          //     );
          //   },
          // ),
          Expanded(child: CategoryScreen())
            ],
      ),
    );
  }
}


