import 'package:flutter/material.dart';
import 'media_picker_service.dart';

class LiveCameraDialog extends StatefulWidget {
  const LiveCameraDialog({super.key});

  @override
  State<LiveCameraDialog> createState() => _LiveCameraDialogState();
}

class _LiveCameraDialogState extends State<LiveCameraDialog> {
  bool _isCapturing = false;

  void _capturePhoto() async {
    if (_isCapturing) return;
    setState(() {
      _isCapturing = true;
    });

    var media = await MediaPickerService.pickImageFromCamera();
    media ??= await MediaPickerService.pickSamplePlantImage();

    if (!mounted) return;
    if (media != null) {
      Navigator.pop(context, media);
    } else {
      setState(() {
        _isCapturing = false;
      });
    }
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
                    'Kamera TaniYuk Live',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
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
                border: Border.all(color: const Color(0xFF132E25), width: 2),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isCapturing ? Icons.hourglass_top_rounded : Icons.photo_camera_rounded,
                      size: 64,
                      color: Colors.lightGreenAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isCapturing
                          ? 'Membuka Kamera Perangkat...'
                          : 'Tekan tombol di bawah untuk memotret dengan Kamera Perangkat',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                color: _isCapturing ? Colors.grey.shade700 : const Color(0xFF132E25),
              ),
              child: Center(
                child: _isCapturing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 38),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
