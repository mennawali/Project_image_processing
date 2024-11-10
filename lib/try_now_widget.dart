import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'camera_screen.dart';
import 'image_section_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:camera/camera.dart';

class TryNowWidget extends StatefulWidget {
  static const String routeName = 'tryNow';
  final List<CameraDescription> cameras;

  const TryNowWidget({Key? key, required this.cameras}) : super(key: key);

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
            leading: Icon(Icons.camera_alt, color: Colors.white),
            title: Text('take_a_photo', style: TextStyle(color: Colors.white)).tr(),
            onTap: () {
              Navigator.pop(context); // Close the modal
              _openCamera(); // Open the camera after closing the modal
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library, color: Colors.white),
            title: Text('upload_from_gallery', style: TextStyle(color: Colors.white)).tr(),
            onTap: () async {
              Navigator.pop(context); // Close the modal
              final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
              if (pickedImage != null) {
                setState(() {
                  _imagePath = pickedImage.path;
                });
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
        setState(() {
          _imagePath = capturedImage; // Store the captured image path
        });
      }
    } else {
      print("No cameras available.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff010520),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical:25),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xff090915)),
            onPressed: _showPicker,
            child: Container(
                child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff6573ED), Color(0xff14D2E6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child:
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 5),
                      child: Text('camera_or_gallery', style: TextStyle(color: Colors.black,fontSize:25)).tr(),
                    )),

          ),),
          SizedBox(height: 20),
          // Display the selected or captured image
          if (_imagePath != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _imagePath!.startsWith('assets')
                  ? Image.asset(_imagePath!, width: 150, height: 150)
                  : Image.file(File(_imagePath!), width: 150, height: 150),
            ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                ImageSectionWidget(title: 'general'.tr(), imagePaths: imagePaths, onImageSelected: _setImage),
                ImageSectionWidget(title: 'nature'.tr(), imagePaths: imagePaths, onImageSelected: _setImage),
                ImageSectionWidget(title: 'sports'.tr(), imagePaths: imagePaths, onImageSelected: _setImage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setImage(String path) {
    setState(() {
      _imagePath = path; // Set the selected image path
    });
  }
}
