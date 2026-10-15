import 'package:flutter/material.dart';
import '../util/permission_helper.dart';
import '../util/media_picker_service.dart';
import '../util/live_camera_dialog.dart';

class IdentifikasiTanamanScreen extends StatefulWidget {
  const IdentifikasiTanamanScreen({super.key});

  @override
  State<IdentifikasiTanamanScreen> createState() => _IdentifikasiTanamanScreenState();
}

class _IdentifikasiTanamanScreenState extends State<IdentifikasiTanamanScreen> {
  bool _isAnalyzing = false;
  bool _showResult = false;
  String _selectedImageName = '';
  String _diagnosisTitle = 'Bercak Daun (Tomat)';
  String _accuracyText = 'Akurasi 96%';
  String _recommendationText =
      '1. Pangkas daun terinfeksi bercak cokelat.\n2. Semprotkan fungisida organik secara merata.\n3. Kurangi kelembapan di sekitar pangkal batang.';
  bool _isHealthy = false;

  void _triggerRealCamera() async {
    final photoLabel = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LiveCameraDialog(),
    );

    if (photoLabel != null && photoLabel.isNotEmpty) {
      _processImageSelection(
        imageLabel: photoLabel,
        title: 'Bercak Daun (Hasil Kamera Live)',
        accuracy: 'Akurasi 97%',
        recommendation:
            '1. Bersihkan area tanaman dari gulma.\n2. Semprotkan pupuk cair hayati secara merata.\n3. Pastikan pencahayaan cukup.',
        healthy: false,
      );
    }
  }

  void _triggerRealGallery() async {
    final pickedMedia = await MediaPickerService.pickImageFromGallery();
    if (pickedMedia != null) {
      _processImageSelection(
        imageLabel: '🖼️ Galeri HP: ${pickedMedia.fileName}',
        title: 'Diagnosa Foto Galeri HP',
        accuracy: 'Akurasi 95%',
        recommendation:
            '1. Lakukan pemangkasan daun terinfeksi.\n2. Gunakan cairan pestisida nabati/organik.\n3. Jaga sirkulasi udara di sekitar lahan.',
        healthy: false,
      );
    }
  }

  void _processImageSelection({
    required String imageLabel,
    required String title,
    required String accuracy,
    required String recommendation,
    required bool healthy,
  }) {
    setState(() {
      _selectedImageName = imageLabel;
      _isAnalyzing = true;
      _showResult = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _showResult = true;
          _diagnosisTitle = title;
          _accuracyText = accuracy;
          _recommendationText = recommendation;
          _isHealthy = healthy;
        });

        // Trigger REAL Top Status Bar Notification on OS / Browser
        MediaPickerService.sendSystemNotification(
          title: '🔔 TaniYuk AI Diagnosa Selesai',
          body: 'Hasil: $title ($accuracy). Ketuk untuk melihat rekomendasi perawatan.',
        );

        _showNotificationOverlay(title, accuracy);
      }
    });
  }

  void _showNotificationOverlay(String title, String accuracy) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F623F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🔔 Notifikasi Dikirim ke Bilah Atas HP!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                  Text(
                    'Diagnosa selesai: $title ($accuracy)',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Identifikasi Pertanian',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Kenali masalah tanaman dengan AI',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bagaimana kondisi tanamanmu?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ambil foto daun atau bagian tanaman yang bermasalah untuk mulai identifikasi.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),

            // Viewfinder / Scanner Container
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: _selectedImageName.isNotEmpty ? const Color(0xFFECFDF5) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedImageName.isNotEmpty ? const Color(0xFF0F623F) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: _isAnalyzing
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(color: Color(0xFF0F623F)),
                          SizedBox(height: 16),
                          Text(
                            'Menganalisis foto dengan AI...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F623F),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _selectedImageName.isNotEmpty ? const Color(0xFFDCFCE7) : const Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _selectedImageName.isNotEmpty ? Icons.image_search_rounded : Icons.center_focus_weak_rounded,
                            size: 48,
                            color: const Color(0xFF0F623F),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedImageName.isNotEmpty ? _selectedImageName : 'Foto tanamanmu di sini',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedImageName.isNotEmpty ? 'Foto asli siap didiagnosis oleh AI' : 'Pastikan foto jelas dan cahaya cukup',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        PermissionHelper.requestCameraPermission(
                          context,
                          onGranted: _triggerRealCamera,
                        );
                      },
                      icon: const Icon(Icons.camera_alt_outlined, size: 20),
                      label: const Text('Ambil Foto', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F623F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        PermissionHelper.requestGalleryPermission(
                          context,
                          onGranted: _triggerRealGallery,
                        );
                      },
                      icon: const Icon(Icons.photo_library_outlined, size: 20, color: Color(0xFF0F623F)),
                      label: const Text('Dari Galeri', style: TextStyle(color: Color(0xFF0F623F), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF0F623F)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Result Card if scan completed
            if (_showResult) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isHealthy ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _isHealthy ? const Color(0xFFA7F3D0) : const Color(0xFFFCA5A5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Hasil Identifikasi: $_diagnosisTitle',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _isHealthy ? const Color(0xFF166534) : const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                        Text(
                          _accuracyText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isHealthy ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rekomendasi Perawatan:\n$_recommendationText',
                      style: TextStyle(
                        fontSize: 13,
                        color: _isHealthy ? const Color(0xFF14532D) : const Color(0xFF7F1D1D),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Tips Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tips untuk hasil akurat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('• Pastikan daun atau batang yang sakit terlihat jelas.', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                  SizedBox(height: 6),
                  Text('• Ambil foto dari jarak dekat dengan fokus yang pas.', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                  SizedBox(height: 6),
                  Text('• Gunakan pencahayaan alami yang cukup terang.', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Scan History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Riwayat Identifikasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Lihat semua',
                  style: TextStyle(fontSize: 12, color: Color(0xFF0F623F), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _historyItem(
              title: 'Tomat • Bercak Daun',
              date: '10 Oktober 2026 • Akurasi 96%',
              status: 'Perlu perawatan',
            ),
            const SizedBox(height: 10),
            _historyItem(
              title: 'Cabai • Tanaman Sehat',
              date: '02 Oktober 2026 • Akurasi 98%',
              status: 'Kondisi Baik',
              isHealthy: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _historyItem({
    required String title,
    required String date,
    required String status,
    bool isHealthy = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isHealthy ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHealthy ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: isHealthy ? const Color(0xFF15803D) : const Color(0xFFDC2626),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}
