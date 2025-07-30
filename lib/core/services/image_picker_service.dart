import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

/// Service pour la sélection d'images depuis la galerie
class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();
  
  /// Sélectionne une image depuis la galerie avec options par défaut
  static Future<File?> pickImageFromGallery({
    double maxWidth = 300.0,
    double maxHeight = 300.0,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      
      if (image != null) {
        return File(image.path);
      }
      
      return null;
    } catch (e) {
      // Log l'erreur si nécessaire
      return null;
    }
  }
  
  /// Sélectionne une image depuis la caméra avec options par défaut
  static Future<File?> pickImageFromCamera({
    double maxWidth = 300.0,
    double maxHeight = 300.0,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      
      if (image != null) {
        return File(image.path);
      }
      
      return null;
    } catch (e) {
      // Log l'erreur si nécessaire
      return null;
    }
  }
  
  /// Déclenche un retour haptique léger
  static void triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }
} 