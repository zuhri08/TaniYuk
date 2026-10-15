import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class PickedMediaResult {
  final Uint8List? bytes;
  final String? objectUrl;
  final String fileName;

  PickedMediaResult({
    this.bytes,
    this.objectUrl,
    required this.fileName,
  });
}

class MediaPickerService {
  /// Opens the REAL device Camera
  static Future<PickedMediaResult?> pickImageFromCamera() async {
    if (kIsWeb) {
      final Completer<PickedMediaResult?> completer = Completer();
      final html.InputElement uploadInput = html.InputElement(type: 'file')
        ..accept = 'image/*'
        ..setAttribute('capture', 'environment'); // Triggers real camera on mobile/laptops

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

  /// Opens the REAL device Gallery / File Picker
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

  /// Triggers a REAL System Top Status Bar Notification on the Device
  static Future<bool> sendSystemNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      try {
        if (html.Notification.permission == 'granted') {
          html.Notification(title, body: body, icon: '/favicon.png');
          return true;
        } else {
          final permission = await html.Notification.requestPermission();
          if (permission == 'granted') {
            html.Notification(title, body: body, icon: '/favicon.png');
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
