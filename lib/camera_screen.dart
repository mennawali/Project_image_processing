import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture; // Ensure the camera is initialized
      final XFile image = await _controller.takePicture(); // Take a picture

      Navigator.pop(context, image.path); // Return the image path to TryNowWidget
    } catch (e) {
      print("Error while taking picture: $e"); // Handle errors
      Navigator.pop(context); // Close camera on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller), // Show camera preview
                Positioned(
                  bottom: 30,
                  left: MediaQuery.of(context).size.width / 2 - 35, // Center the button
                  child: FloatingActionButton(
                    onPressed: _takePicture, // Capture photo
                    backgroundColor: Colors.white, // Button color
                    child: Icon(Icons.camera_alt, color: Colors.black), // Camera icon color
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator()); // Loading indicator
          }
        },
      ),
    );
  }
}
