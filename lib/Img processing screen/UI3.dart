import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class PhotoEditorScreen extends StatefulWidget {
  final String imagePath;

  const PhotoEditorScreen({Key? key, required this.imagePath}) : super(key: key);

  static const routeName = '/photo-editor';

  @override
  _PhotoEditorScreenState createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends State<PhotoEditorScreen> {
  late img.Image _image;
  img.Image _editedImage = img.Image(width:1,height: 1);
  String? _editedImagePath;
  double _blurAmount = 0;
  bool _isGrayscale = false;
  bool _isSegmented = false;
  bool _isNoisy = false; // Flag for noise effect
  bool _isSharp = false; // Flag for sharpness effect
  bool _isFlippedVertically = false;
  bool _isFlippedHorizontally = false;

  List<String> filters = ['None', 'Grayscale', 'Invert', 'Brightness', 'Contrast'];
  String selectedFilter = 'None';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final imageBytes = await File(widget.imagePath).readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image != null) {
        setState(() {
          _image = image;
          _editedImage = img.copyResize(_image, width: 600);
        });
      } else {
        throw Exception("Failed to decode image.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading image: $e')),
      );
    }
  }

  Future<void> _saveImage() async {
    try {
      final Uint8List bytes = Uint8List.fromList(img.encodePng(_editedImage));
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/edited_image.png';
      final File file = File(tempPath)..writeAsBytesSync(bytes);

      setState(() {
        _editedImagePath = tempPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to $tempPath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }

  Future<void> _saveToGallery() async {
    try {
      final Uint8List bytes = Uint8List.fromList(img.encodePng(_editedImage));
      final result = await ImageGallerySaver.saveImage(bytes, quality: 100);

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery.')),
        );
      } else {
        throw Exception("Failed to save image.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving to gallery: $e')),
      );
    }
  }

  void _rotateImage() {
    setState(() {
      _editedImage = img.copyRotate(_editedImage, angle: 90);
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;

      switch (filter) {
        case 'Grayscale':
          _editedImage = img.grayscale(_image);
          break;
        case 'Invert':
          _editedImage = _applyInvert(_image);
          break;
        case 'Brightness':
          _editedImage = _applyBrightness(_image, 1.2); // Increase brightness by 20%
          break;
        case 'Contrast':
          _editedImage = _applyContrast(_image, 1.5); // Increase contrast by 50%
          break;
        default:
          _editedImage = _image;
      }
    });
  }

  img.Image _applyInvert(img.Image image) {
    return img.invert(image);
  }

  img.Image _applyBrightness(img.Image image, double factor) {
    return img.adjustColor(image, brightness: factor);
  }

  img.Image _applyContrast(img.Image image, double factor) {
    return img.adjustColor(image, contrast: factor);
  }

  img.Image _applySharpness(img.Image image) {
    return img.convolution(image, filter: [
      0, -1, 0,
      -1, 9, -1,
      0, -1, 0
    ]);
  }

  void _undoChanges() {
    setState(() {
      _editedImage = _image;
      _blurAmount = 0;
      _isGrayscale = false;
      _isSegmented = false;
      _isSharp = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes undone.')),
    );
  }

  void _closeEditor() {
    Navigator.pop(context);
  }

  void _toggleNoiseOverlay() {
    setState(() {
      _isNoisy = !_isNoisy;
    });
  }

  void _toggleSharpness() {
    setState(() {
      _isSharp = !_isSharp;
      if (_isSharp) {
        _editedImage = _applySharpness(_image);
      } else {
        _editedImage = _image;
      }
    });
  }

  // Flip image vertically
  void _flipVertically() {
    setState(() {
      _isFlippedVertically = !_isFlippedVertically;
      _editedImage = _isFlippedVertically
          ? img.flipVertical(_image)
          : _image;
    });
  }

  // Flip image horizontally
  void _flipHorizontally() {
    setState(() {
      _isFlippedHorizontally = !_isFlippedHorizontally;
      _editedImage = _isFlippedHorizontally
          ? img.flipHorizontal(_image)
          : _image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff19166f),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Edit Screen',
          style: TextStyle(color: Colors.amber),
        ).tr(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.amber),
            onPressed: _closeEditor, // Close the editor
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.amber),
            onPressed: _saveToGallery,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Image.memory(
                  Uint8List.fromList(img.encodePng(_editedImage)),
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
                if (_isNoisy)
                  Opacity(
                    opacity: 0.5,
                    child: Image.memory(
                      Uint8List.fromList(img.encodePng(_image)),
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _blurAmount,
                    sigmaY: _blurAmount,
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ],
            ),
          ),
          Slider(
            min: 0,
            max: 10,
            value: _blurAmount,
            onChanged: (value) => setState(() => _blurAmount = value),
            label: 'Blur: ${_blurAmount.toStringAsFixed(1)}',
          ),
          DropdownButton<String>(
            value: selectedFilter,
            onChanged: (String? newFilter) {
              if (newFilter != null) {
                _applyFilter(newFilter);
              }
            },
            items: filters.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconButton(Icons.rotate_right, 'Rotate'.tr(), _rotateImage),
              _buildIconButton(
                _isGrayscale ? Icons.filter_b_and_w : Icons.filter_none,
                'Grayscale'.tr(),
                    () {
                  setState(() {
                    _isGrayscale = !_isGrayscale;
                    _editedImage = _isGrayscale ? img.grayscale(_image) : _image;
                  });
                },
              ),
              _buildIconButton(
                Icons.refresh,
                'Flip Horizontal'.tr(),
                _flipHorizontally,
              ),
              _buildIconButton(
                Icons.flip,
                'Flip Vertical'.tr(),
                _flipVertically,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconButton(Icons.api_sharp, 'Sharpness'.tr(), _toggleSharpness),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onTap,
        ),
        Text(label, style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
