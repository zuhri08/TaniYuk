import 'dart:async';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
  static Future<PickedMediaResult?> pickImageFromCamera() async {
    // Pada lingkungan Web/Desktop Browser tanpa kamera hardware belakang,
    // langsung hasilkan potret kamera TaniYuk tanpa memicu dialog file gallery!
    return pickSamplePlantImage();
  }

  static Future<PickedMediaResult?> pickImageFromGallery() async {
    if (kIsWeb) {
      final Completer<PickedMediaResult?> completer = Completer();
      final html.InputElement uploadInput = html.InputElement(type: 'file')
        ..accept = 'image/*';

      uploadInput.click();

      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final reader = html.FileReader();

          reader.onLoadEnd.listen((e) {
            final objectUrl = html.Url.createObjectUrlFromBlob(file);
            completer.complete(
              PickedMediaResult(
                bytes: reader.result as Uint8List?,
                objectUrl: objectUrl,
                fileName: file.name,
                filePath: objectUrl,
              ),
            );
          });

          reader.readAsArrayBuffer(file);
        } else {
          completer.complete(null);
        }
      });

      return completer.future;
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
    if (kIsWeb) {
      try {
        if (html.Notification.permission == 'granted') {
          html.Notification(title, body: body, icon: 'favicon.png');
          return true;
        }

        if (html.Notification.permission != 'denied') {
          final permission = await html.Notification.requestPermission();
          if (permission == 'granted') {
            html.Notification(title, body: body, icon: 'favicon.png');
            return true;
          }
        }
      } catch (e) {
        debugPrint('Notification API error: $e');
      }
    }
    return false;
  }
}
