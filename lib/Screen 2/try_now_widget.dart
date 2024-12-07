import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_image_processing/Img%20processing%20screen/UI3.dart';
import 'camera_screen.dart';
import 'image_section_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:camera/camera.dart';


class TryNowWidget extends StatefulWidget {
  static const String routeName = 'tryNow';
  final List<CameraDescription> cameras;

  const TryNowWidget({super.key, required this.cameras});

  @override
  _TryNowWidgetState createState() => _TryNowWidgetState();
}

class _TryNowWidgetState extends State<TryNowWidget> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  final List<String> imagePaths = [
    'assets/images/image1.jpg',
    'assets/images/image2.jpg',
    'assets/images/image3.jpg',
    'assets/images/image4.jpg',
  ];

  void _showPicker() {
    showModalBottomSheet(
      backgroundColor: Colors.black,
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.white),
            title: const Text('take_a_photo', style: TextStyle(color: Colors.white)).tr(),
            onTap: () {
              Navigator.pop(context); // Close the modal
              _openCamera(); // Open the camera after closing the modal
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.white),
            title: const Text('upload_from_gallery', style: TextStyle(color: Colors.white)).tr(),
            onTap: () async {
              Navigator.pop(context); // Close the modal
              final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
              if (pickedImage != null) {
                _navigateToPhotoEditor(pickedImage.path); // Navigate to photo editor with the image
              }
            },
          ),
        ],
      ),
    );
  }

  void _openCamera() async {
    if (widget.cameras.isNotEmpty) {
      final capturedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CameraScreen(camera: widget.cameras[0]),
        ),
      );
      if (capturedImage != null) {
        _navigateToPhotoEditor(capturedImage); // Navigate to photo editor with the captured image
      }
    } else {
      print("No cameras available.");
    }
  }

  // Function to navigate to the photo editor screen (UI3) and pass the image path
  void _navigateToPhotoEditor(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoEditorScreen(imagePath: imagePath), // Pass imagePath to the editor
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010520),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 45, vertical: 25),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff090915)),
            onPressed: _showPicker,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff6573ED), Color(0xff14D2E6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 5),
                child: const Text('camera_or_gallery', style: TextStyle(color: Colors.black, fontSize: 25)).tr(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                ImageSectionWidget(title: 'general'.tr(), imagePaths: imagePaths, onImageSelected: _navigateToPhotoEditor),
                ImageSectionWidget(title: 'nature'.tr(), imagePaths: imagePaths, onImageSelected: _navigateToPhotoEditor),
                ImageSectionWidget(title: 'sports'.tr(), imagePaths: imagePaths, onImageSelected: _navigateToPhotoEditor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
