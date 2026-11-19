import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class PickedMediaResult {
  final Uint8List? bytes;
  final String? objectUrl;
  final String fileName;
  final String? filePath;

  PickedMediaResult({
    this.bytes,
    this.objectUrl,
    required this.fileName,
    this.filePath,
  });
}

class MediaPickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<PickedMediaResult?> pickImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        final Uint8List bytes = await photo.readAsBytes();
        return PickedMediaResult(
          bytes: bytes,
          objectUrl: photo.path,
          fileName: photo.name,
          filePath: photo.path,
        );
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
    }
    return null;
  }

  static Future<PickedMediaResult?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        return PickedMediaResult(
          bytes: bytes,
          objectUrl: image.path,
          fileName: image.name,
          filePath: image.path,
        );
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    }
    return null;
  }

  static Future<PickedMediaResult?> pickSamplePlantImage() async {
    return PickedMediaResult(
      fileName: '📷 Foto Kamera TaniYuk (Tanaman Tomat).jpg',
      objectUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500',
      filePath: null,
    );
  }

  static Future<bool> sendSystemNotification({
    required String title,
    required String body,
  }) async {
    return false;
  }
}
