import 'package:birthday_photo_maker/provider/Home_provider/Home_provider.dart';
import 'package:birthday_photo_maker/provider/editor_provider/edit_provider.dart';
import 'package:birthday_photo_maker/provider/theme_provider/theme_provider.dart';
import 'package:birthday_photo_maker/routes/app_routes.dart';
import 'package:birthday_photo_maker/routes/app_routes_name.dart';
import 'package:birthday_photo_maker/views/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => EditProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      initialRoute: AppRoutesName.splashScreen,
      onGenerateRoute: AppRoutes.generateRoute,
      title: 'birthday photo maker',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}



