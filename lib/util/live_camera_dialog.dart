import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'media_picker_service.dart';

class LiveCameraDialog extends StatefulWidget {
  const LiveCameraDialog({super.key});

  @override
  State<LiveCameraDialog> createState() => _LiveCameraDialogState();
}

class _LiveCameraDialogState extends State<LiveCameraDialog> {
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;
  bool _isCameraReady = false;
  final String _viewId = 'camera-video-view-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _startLiveCamera();
  }

  void _startLiveCamera() async {
    if (kIsWeb) {
      try {
        final stream = await html.window.navigator.mediaDevices?.getUserMedia({
          'video': {'facingMode': 'environment'},
          'audio': false,
        });

        if (stream != null) {
          _mediaStream = stream;
          _videoElement = html.VideoElement()
            ..srcObject = stream
            ..autoplay = true
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'cover';

          ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) => _videoElement!);

          if (mounted) {
            setState(() {
              _isCameraReady = true;
            });
          }
        }
      } catch (e) {
        debugPrint('WebCam Error: $e');
        if (mounted) {
          setState(() {
            _isCameraReady = false;
          });
        }
      }
    }
  }

  void _capturePhoto() {
    if (_videoElement != null) {
      try {
        final canvas = html.CanvasElement(
          width: _videoElement!.videoWidth > 0 ? _videoElement!.videoWidth : 640,
          height: _videoElement!.videoHeight > 0 ? _videoElement!.videoHeight : 480,
        );
        final ctx = canvas.context2D;
        ctx.drawImage(_videoElement!, 0, 0);

        final dataUrl = canvas.toDataUrl('image/jpeg');

        _stopCamera();
        Navigator.pop(
          context,
          PickedMediaResult(
            fileName: '📷 Foto Kamera (${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second})',
            objectUrl: dataUrl,
          ),
        );
        return;
      } catch (e) {
        debugPrint('Canvas export error: $e');
      }
    }

    _stopCamera();
    Navigator.pop(
      context,
      PickedMediaResult(
        fileName: '📷 Foto Kamera TaniYuk.jpg',
        objectUrl: null,
      ),
    );
  }

  void _stopCamera() {
    if (_mediaStream != null) {
      for (var track in _mediaStream!.getTracks()) {
        track.stop();
      }
    }
  }

  @override
  void dispose() {
    _stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.videocam_rounded, color: Colors.lightGreenAccent, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Kamera Fisik TaniYuk Live',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  _stopCamera();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0F623F), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isCameraReady)
                      HtmlElementView(viewType: _viewId)
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(color: Colors.lightGreenAccent),
                          SizedBox(height: 16),
                          Text(
                            'Menghubungkan ke kamera HP/laptop...',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),

                    // Viewfinder overlay frame
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.lightGreenAccent, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Kamera Aktif • Arahkan ke daun tanaman',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Shutter Button
          GestureDetector(
            onTap: _capturePhoto,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: const Color(0xFF0F623F),
              ),
              child: const Center(
                child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 38),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
