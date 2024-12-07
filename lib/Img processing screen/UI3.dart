import 'dart:io';
import 'dart:typed_data'; // Import to use Uint8List
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class PhotoEditorScreen extends StatefulWidget {
  final String imagePath;
  const PhotoEditorScreen({super.key, required this.imagePath});
  static const routeName = '/photo-editor';

  @override
  _PhotoEditorScreenState createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends State<PhotoEditorScreen> {
  double brightnessValue = 0;
  double contrastValue = 0;
  double saturationValue = 0;
  double hueValue = 0;
  int selectedSettingIndex = -1;

  late File imageFile;
  late img.Image originalImage; // Cache the original image
  late img.Image editedImage; // Store the edited image

  Uint8List? editedImageBytes; // Nullable, initially null

  @override
  void initState() {
    super.initState();
    imageFile = File(widget.imagePath);

    // Load and decode the original image only once
    originalImage = img.decodeImage(imageFile.readAsBytesSync())!;
    editedImage = originalImage; // Start with original image
    _applyImageChanges(); // Apply initial changes (none)
  }

  // List of settings with icons and labels
  final List<Map<String, dynamic>> settings = [
    {'icon': Icons.brightness_6, 'label': 'Brightness'},
    {'icon': Icons.contrast, 'label': 'Contrast'},
    {'icon': Icons.colorize, 'label': 'Saturation'},
    {'icon': Icons.color_lens, 'label': 'Hue'},
    {'icon': Icons.crop_rotate, 'label': 'Rotate'},
    {'icon': Icons.aspect_ratio, 'label': 'Resize'},
  ];

  Widget _buildImageDisplay() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0), // Adjust margin as needed
        child: FittedBox(
          fit: BoxFit.cover, // Ensures the image covers the screen without stretching
          child: editedImageBytes != null
              ? Image.memory(editedImageBytes!) // Display the edited image
              : Image.file(imageFile), // Display the original image initially
        ),
      ),
    );
  }

  // Widget to render the top bar with Cancel and Save buttons
  AppBar _buildTopBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Cancel', style: TextStyle(color: Colors.yellow,fontSize: 10)),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            // Save the image with the applied changes
            imageFile.writeAsBytesSync(editedImageBytes!); // Save the edited image bytes to file
            Navigator.pop(context, imageFile);
          },
          child: const Text('Save', style: TextStyle(color: Colors.yellow,fontSize:10)),
        ),
      ],
    );
  }

  // Function to render the bottom bar with icons and labels
  Widget _buildBottomBar() {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(settings.length, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedSettingIndex = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 20.0),
              child: Column(
                children: [
                  Icon(settings[index]['icon'], size: 30),
                  Text(settings[index]['label']),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSlider() {
    if (selectedSettingIndex == -1) return const SizedBox.shrink();

    String label = settings[selectedSettingIndex]['label'];
    double currentValue;
    switch (label) {
      case 'Brightness':
        currentValue = brightnessValue;
        break;
      case 'Contrast':
        currentValue = contrastValue;
        break;
      case 'Saturation':
        currentValue = saturationValue;
        break;
      case 'Hue':
        currentValue = hueValue;
        break;
      default:
        currentValue = 0;
        break;
    }

    return Column(
      children: [
        Text('$label Value: ${currentValue.toStringAsFixed(1)}'),
        Slider(
          value: currentValue,
          min: -100,
          max: 100,
          onChanged: (value) {
            setState(() {
              switch (label) {
                case 'Brightness':
                  brightnessValue = value;
                  break;
                case 'Contrast':
                  contrastValue = value;
                  break;
                case 'Saturation':
                  saturationValue = value;
                  break;
                case 'Hue':
                  hueValue = value;
                  break;
              }
              _applyImageChanges(); // Apply image changes on slider movement
            });
          },
        ),
      ],
    );
  }

  Future<void> _applyImageChanges() async {
    // Start by resetting to the original image before re-applying all edits
    editedImage = img.copyResize(originalImage);

    // Apply brightness
    if (brightnessValue != 0) {
      editedImage = img.adjustColor(editedImage, brightness: brightnessValue / 100);
    }

    // Apply contrast
    if (contrastValue != 0) {
      editedImage = img.adjustColor(editedImage, contrast: 1 + contrastValue / 100);
    }

    // Apply saturation
    if (saturationValue != 0) {
      editedImage = img.adjustColor(editedImage, saturation: saturationValue / 100);
    }

    // Apply hue
    if (hueValue != 0) {
      editedImage = img.adjustColor(editedImage, hue: hueValue);
    }

    // Save the modified image in memory (not writing to file system yet)
    List<int> imageBytes = img.encodeJpg(editedImage); // Encode to JPEG
    Uint8List updatedImageBytes = Uint8List.fromList(imageBytes);

    // Update the UI with the edited image
    setState(() {
      editedImageBytes = updatedImageBytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff465189),
      appBar: _buildTopBar(),
      body: Container(
        child: Column(
          children: [
            _buildImageDisplay(),
            _buildSlider(), // Display the slider when a setting is selected
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }
}
