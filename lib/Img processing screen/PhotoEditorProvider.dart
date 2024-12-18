import 'package:flutter/material.dart';
import 'dart:typed_data';

class AppImageProvider with ChangeNotifier {
  Uint8List? _currentImage;

  Uint8List? get currentImage => _currentImage;

  void changeImage(Uint8List newImage) {
    _currentImage = newImage;
    notifyListeners();  // Notify listeners that the image has changed
  }
}
