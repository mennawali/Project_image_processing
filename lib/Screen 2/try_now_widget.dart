import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_image_processing/Img%20processing%20screen/UI3.dart';
import 'camera_screen.dart';
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
  bool _isLoading = false; // Track loading state
  String? _errorMessage; // Track error message
  String _editedImage = '';
  // Different placeholder lists for each section
  final List<String> generalImages = [
    'assets/images/home1.jpg',
    'assets/images/home2.png',
    'assets/images/c.png',
    'assets/images/home4.png',
  ];

  final List<String> natureImages = [
    'assets/images/image1.jpg',
    'assets/images/image2.jpg',
    'assets/images/image3.jpg',
    'assets/images/image4.jpg',
  ];

  final List<String> sportsImages = [
    'assets/images/a1.png',
    'assets/images/a3.png',
    'assets/images/S1.png',
    'assets/images/cr7.png',
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
              setState(() {
                _isLoading = true; // Show loading indicator
                _errorMessage = null; // Reset any previous error message
              });
              try {
                final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedImage != null) {
                  _navigateToPhotoEditor(pickedImage.path); // Navigate to photo editor with the image
                } else {
                  setState(() {
                    _isLoading = false; // Hide loading indicator
                    _errorMessage = 'No image selected'; // Set error message
                  });
                }
              } catch (e) {
                setState(() {
                  _isLoading = false; // Hide loading indicator
                  _errorMessage = 'An error occurred while selecting image'; // Set error message
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
      setState(() {
        _isLoading = true; // Show loading indicator
        _errorMessage = null; // Reset any previous error message
      });
      try {
        final capturedImage = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CameraScreen(camera: widget.cameras[0]),
          ),
        );
        if (capturedImage != null) {
          _navigateToPhotoEditor(capturedImage); // Navigate to photo editor with the captured image
        } else {
          setState(() {
            _isLoading = false; // Hide loading indicator
            _errorMessage = 'No image captured'; // Set error message
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false; // Hide loading indicator
          _errorMessage = 'An error occurred while opening the camera'; // Set error message
        });
      }
    } else {
      setState(() {
        _isLoading = false; // Hide loading indicator
        _errorMessage = 'No cameras available'; // Set error message
      });
    }
  }

  // Function to navigate to the photo editor screen (UI3) and pass the image path


  void _navigateToPhotoEditor(String imagePath) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Wait for a moment before navigating (simulate a delay if necessary)
    await Future.delayed(const Duration(seconds: 1));

    // After delay, close the dialog and navigate to the photo editor
    Navigator.pop(context); // Close the loading dialog

    // Navigate to the PhotoEditorScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoEditorScreen(imagePath: imagePath),
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
                // General section with different images
                _buildImageSection('general'.tr(), generalImages),
                // Nature section with different images
                _buildImageSection('nature'.tr(), natureImages),
                // Sports section with different images
                _buildImageSection('sports'.tr(), sportsImages),
              ],
            ),
          ),
        ],
      ),
      // Show loading dialog if isLoading is true
      floatingActionButton: _isLoading
          ? const CircularProgressIndicator()
          : const SizedBox.shrink(),
      // Show error screen if there is an error message
      bottomSheet: _errorMessage != null
          ? Container(
        color: Colors.red,
        padding: const EdgeInsets.all(10),
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      )
          : const SizedBox.shrink(),
    );
  }

  // Helper method to build image sections
  Widget _buildImageSection(String title, List<String> imagePaths) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Display images in a scrollable horizontal list
          SizedBox(
            height: 200, // Set height of image carousel
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imagePaths[index],
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
