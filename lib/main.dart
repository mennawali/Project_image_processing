import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Import camera package
import 'package:permission_handler/permission_handler.dart';
import 'package:project_image_processing/Img%20processing%20screen/PhotoEditorProvider.dart';
import 'package:project_image_processing/Img%20processing%20screen/UI3.dart';
import 'package:project_image_processing/Screen%202/try_now_widget.dart';
import 'package:project_image_processing/home_screen.dart';
import 'package:provider/provider.dart';

 // Import permission handler

Future<void> main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Request necessary permissions (camera and microphone)
  bool permissionsGranted = await _requestPermissions();

  if (!permissionsGranted) {
    // If permissions are not granted, handle the app accordingly
    runApp(const PermissionDeniedApp());
    return;
  }

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Initialize the available cameras
  final cameras = await availableCameras(); // Get the list of available cameras

  // Run the app with EasyLocalization and passed cameras
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      saveLocale: true,
      startLocale: const Locale("en"),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppImageProvider()), // Add AppImageProvider
        ],
        child: MyApp(cameras: cameras), // Pass cameras to MyApp
      ),
    ),
  );
}

// Function to request camera and microphone permissions at runtime
Future<bool> _requestPermissions() async {
  final cameraStatus = await Permission.camera.request();
  final microphoneStatus = await Permission.microphone.request();

  if (!cameraStatus.isGranted || !microphoneStatus.isGranted) {
    // Handle the permission denial (you can show a message or exit)
    print("Permissions denied. Cannot access camera.");
    return false; // Return false if permissions are denied
  }
  return true; // Return true if permissions are granted
}

// Fallback widget for when permissions are denied
class PermissionDeniedApp extends StatelessWidget {
  const PermissionDeniedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Permission Denied').tr()),
        body: Center(
          child: const Text('camera_microphone_permission_denied').tr(),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        TryNowWidget.routeName: (context) => TryNowWidget(cameras: cameras), // Pass cameras to TryNowWidget
        PhotoEditorScreen.routeName: (context) => PhotoEditorScreen(imagePath: ''), // Add PhotoEditorScreen route
      },
    );
  }
}
