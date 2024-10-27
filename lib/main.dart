import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Import camera package
import 'package:project_image_processing/home_screen.dart';
import 'package:project_image_processing/try_now_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize the available cameras
  final cameras = await availableCameras(); // Get the list of available cameras

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      saveLocale: true,
      startLocale: Locale("en"),
      child: MyApp(cameras: cameras), // Pass cameras to MyApp
    ),
  );
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras; // Store cameras in MyApp

  const MyApp({super.key, required this.cameras}); // Required cameras parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
        TryNowWidget.routeName: (context) => TryNowWidget(cameras: cameras), // Pass cameras to TryNowWidget
      },
    );
  }
}
