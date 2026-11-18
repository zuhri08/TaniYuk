import 'package:flutter/material.dart';
import 'media_picker_service.dart';

class PermissionHelper {
  static bool isNotificationGranted = false;
  static bool isCameraGranted = false;
  static bool isGalleryGranted = false;

  /// Requests Notification Permission with System Dialog UI.
  /// Dialog ditampilkan saat izin belum dicatat; aksi "Izinkan" akan
  /// meminta izin notifikasi sistem (web Notification API bila tersedia).
  static void requestNotificationPermission(
    BuildContext context, {
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) {
    if (isNotificationGranted) {
      if (onGranted != null) onGranted();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF89D7B7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFF132E25),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 16, color: Color(0xFF1F2937), height: 1.4),
                    children: [
                      TextSpan(text: 'Izinkan '),
                      TextSpan(
                        text: 'TaniYuk',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' mengirim notifikasi kepada Anda?'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      isNotificationGranted = true;
                      Navigator.pop(dialogContext);
                      if (onGranted != null) onGranted();

                      // Meminta izin/menampilkan notifikasi sistem bila tersedia.
                      MediaPickerService.sendSystemNotification(
                        title: '🔔 TaniYuk Notifikasi Status Bar',
                        body: 'Izin notifikasi aktif! Anda akan menerima update cuaca & harga pasar secara realtime.',
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF132E25),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          content: Row(
                            children: const [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Notifikasi diaktifkan. Izinkan juga di pengaturan browser bila diminta.',
                                  style: TextStyle(fontSize: 13, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Izinkan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF132E25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      isNotificationGranted = false;
                      Navigator.pop(dialogContext);
                      if (onDenied != null) onDenied();
                    },
                    child: const Text(
                      'Jangan izinkan',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF132E25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Requests Camera Permission with System Dialog UI
  static void requestCameraPermission(
    BuildContext context, {
    required VoidCallback onGranted,
  }) {
    if (isCameraGranted) {
      onGranted();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF89D7B7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF132E25),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 16, color: Color(0xFF1F2937), height: 1.4),
                    children: [
                      TextSpan(text: 'Izinkan '),
                      TextSpan(
                        text: 'TaniYuk',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' mengambil gambar dan merekam video?'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: TextButton(
                    onPressed: () {
                      isCameraGranted = true;
                      Navigator.pop(dialogContext);
                      onGranted();
                    },
                    child: const Text(
                      'Saat aplikasi digunakan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF132E25)),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: TextButton(
                    onPressed: () {
                      isCameraGranted = true;
                      Navigator.pop(dialogContext);
                      onGranted();
                    },
                    child: const Text(
                      'Hanya kali ini',
                      style: TextStyle(fontSize: 15, color: Color(0xFF132E25)),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Izin kamera ditolak. Buka pengaturan HP untuk memberikan izin.')),
                      );
                    },
                    child: const Text(
                      'Jangan izinkan',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Requests Gallery/Storage Permission with System Dialog UI
  static void requestGalleryPermission(
    BuildContext context, {
    required VoidCallback onGranted,
  }) {
    if (isGalleryGranted) {
      onGranted();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF0284C7),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 16, color: Color(0xFF1F2937), height: 1.4),
                    children: [
                      TextSpan(text: 'Izinkan '),
                      TextSpan(
                        text: 'TaniYuk',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' mengakses foto dan media di perangkat Anda?'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      isGalleryGranted = true;
                      Navigator.pop(dialogContext);
                      onGranted();
                    },
                    child: const Text(
                      'Izinkan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF132E25)),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Izin galeri ditolak.')),
                      );
                    },
                    child: const Text(
                      'Jangan izinkan',
                      style: TextStyle(fontSize: 15, color: Color(0xFF132E25)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
