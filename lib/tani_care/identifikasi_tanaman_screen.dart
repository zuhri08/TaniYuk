import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../util/permission_helper.dart';
import '../util/media_picker_service.dart';
import '../util/live_camera_dialog.dart';
import '../services/plant_ai_service.dart';

class IdentifikasiTanamanScreen extends StatefulWidget {
  const IdentifikasiTanamanScreen({super.key});

  @override
  State<IdentifikasiTanamanScreen> createState() => _IdentifikasiTanamanScreenState();
}

class _IdentifikasiTanamanScreenState extends State<IdentifikasiTanamanScreen> {
  bool _isAnalyzing = false;
  bool _showResult = false;
  String _selectedImageName = '';
  String? _selectedImageUrl;
  Uint8List? _selectedImageBytes;

  PlantDiagnosisResult? _currentResult;

  final List<PlantDiagnosisResult> _historyList = [
    PlantDiagnosisResult(
      cropName: 'Tomat Merah',
      diseaseName: 'Bercak Daun Alternaria',
      fullTitle: 'Bercak Daun Alternaria (Tomat)',
      accuracy: 96.4,
      accuracyText: 'Akurasi 96.4%',
      isHealthy: false,
      severity: 'Sedang',
      symptoms: [
        'Bercak cokelat melingkar konsentris pada daun tua.',
        'Tepi daun membiru kusam dan membusuk.',
      ],
      recommendations: [
        '1. Pangkas dan musnahkan daun terinfeksi.',
        '2. Semprotkan fungisida organik Trichoderma secara berulang.',
        '3. Atur sirkulasi udara piringan lahan.',
      ],
      organicPesticides: ['Fungisida Trichoderma', 'Ekstrak Sirih'],
      diagnosedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PlantDiagnosisResult(
      cropName: 'Cabai Rawit',
      diseaseName: 'Tanaman Sehat & Bebas Hama',
      fullTitle: 'Tanaman Kondisi Optimal (Cabai)',
      accuracy: 98.2,
      accuracyText: 'Akurasi 98.2%',
      isHealthy: true,
      severity: 'Sehat',
      symptoms: ['Warna daun hijau pekat mengkilap.', 'Pertumbuhan pupus daun lancar.'],
      recommendations: [
        '1. Lanjutkan pemupukan organik cair 2 minggu sekali.',
        '2. Jaga kelembapan media tanam.',
      ],
      organicPesticides: ['Pupuk Cair Hayati POC'],
      diagnosedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  void _triggerRealCamera() async {
    var pickedMedia = await showModalBottomSheet<PickedMediaResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LiveCameraDialog(),
    );

    pickedMedia ??= await MediaPickerService.pickSamplePlantImage();

    if (pickedMedia != null) {
      _analyzeSelectedMedia(pickedMedia);
    }
  }

  void _triggerRealGallery() async {
    var pickedMedia = await MediaPickerService.pickImageFromGallery();
    pickedMedia ??= await MediaPickerService.pickSamplePlantImage();
    if (pickedMedia != null) {
      _analyzeSelectedMedia(pickedMedia);
    }
  }

  void _analyzeSelectedMedia(PickedMediaResult media) async {
    setState(() {
      _selectedImageName = media.fileName;
      _selectedImageUrl = media.objectUrl;
      _selectedImageBytes = media.bytes;
      _isAnalyzing = true;
      _showResult = false;
    });

    final result = await PlantAiService.analyzePlantImage(
      bytes: media.bytes,
      imageName: media.fileName,
    );

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
      _showResult = true;
      _currentResult = result;
      _historyList.insert(0, result);
    });

    // Trigger REAL Top Status Bar Notification on OS / Browser
    MediaPickerService.sendSystemNotification(
      title: '🔔 TaniYuk AI Diagnosa Selesai',
      body: 'Hasil: ${result.fullTitle} (${result.accuracyText}). Ketuk untuk rekomendasi.',
    );

    _showNotificationOverlay(result.fullTitle, result.accuracyText);
  }

  void _showNotificationOverlay(String title, String accuracy) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF132E25),
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
                    '🔔 Notifikasi AI Dikirim ke HP!',
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

  void _showHistoryDetailModal(PlantDiagnosisResult item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.fullTitle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isHealthy ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.severity,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: item.isHealthy ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.accuracyText,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF132E25)),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text('Gejala Terdeteksi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              ...item.symptoms.map((s) => Text('• $s', style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)))),
              const SizedBox(height: 12),
              const Text('Rekomendasi Perawatan AI:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              ...item.recommendations.map((r) => Text(r, style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937)))),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF132E25),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Identifikasi Pertanian AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Deteksi penyakit & solusi hama tanaman',
              style: TextStyle(color: Colors.white70, fontSize: 11),
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
              'Ambil foto daun atau bagian tanaman yang bermasalah untuk didiagnosis oleh AI TaniYuk.',
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
                  color: _selectedImageName.isNotEmpty ? const Color(0xFF132E25) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: _isAnalyzing
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(color: Color(0xFF132E25)),
                          SizedBox(height: 16),
                          Text(
                            'Menganalisis pola bercak & klorofil daun...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF132E25),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'AI sedang mencocokkan basis data penyakit',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_selectedImageBytes != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.memory(
                              _selectedImageBytes!,
                              width: 170,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        else if (_selectedImageUrl != null && _selectedImageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              _selectedImageUrl!,
                              width: 170,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 170,
                                height: 120,
                                color: const Color(0xFF89D7B7),
                                child: const Icon(Icons.broken_image_outlined, color: Color(0xFF132E25), size: 40),
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFF89D7B7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _selectedImageName.isNotEmpty ? Icons.image_search_rounded : Icons.center_focus_weak_rounded,
                              size: 48,
                              color: const Color(0xFF132E25),
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
                          _selectedImageName.isNotEmpty ? 'Foto siap dianalisis oleh AI TaniYuk' : 'Pastikan foto jelas dan cahaya cukup',
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
                        backgroundColor: const Color(0xFF132E25),
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
                      icon: const Icon(Icons.photo_library_outlined, size: 20, color: Color(0xFF132E25)),
                      label: const Text('Dari Galeri', style: TextStyle(color: Color(0xFF132E25), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF132E25)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Result Card if scan completed
            if (_showResult && _currentResult != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _currentResult!.isHealthy ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _currentResult!.isHealthy ? const Color(0xFFA7F3D0) : const Color(0xFFFCA5A5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '🔬 Hasil Diagnosa: ${_currentResult!.fullTitle}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _currentResult!.isHealthy ? const Color(0xFF047857) : const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _currentResult!.isHealthy ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _currentResult!.accuracyText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _currentResult!.isHealthy ? const Color(0xFF065F46) : const Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Komoditas: ${_currentResult!.cropName} • Keparahan: ${_currentResult!.severity}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 10),
                    const Text('Gejala Klinis:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
                    const SizedBox(height: 4),
                    ..._currentResult!.symptoms.map(
                      (s) => Text('• $s', style: TextStyle(fontSize: 12, color: _currentResult!.isHealthy ? const Color(0xFF065F46) : const Color(0xFF7F1D1D))),
                    ),
                    const SizedBox(height: 12),
                    const Text('Rekomendasi Tindakan AI:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
                    const SizedBox(height: 4),
                    ..._currentResult!.recommendations.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(r, style: TextStyle(fontSize: 12, color: _currentResult!.isHealthy ? const Color(0xFF047857) : const Color(0xFF991B1B), height: 1.3)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Pestisida / Agen Hayati Disarankan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _currentResult!.organicPesticides
                          .map(
                            (p) => Chip(
                              label: Text(p, style: const TextStyle(fontSize: 11, color: Color(0xFF132E25), fontWeight: FontWeight.bold)),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF89D7B7)),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✅ Perawatan berhasil dicatat ke agenda pemeliharaan!')),
                              );
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: const Text('Terapkan Perawatan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF132E25),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
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
              children: [
                const Text(
                  'Riwayat Identifikasi AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '${_historyList.length} Pemindaian',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF132E25), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._historyList.map((item) {
              final formattedDate =
                  '${item.diagnosedAt.day}/${item.diagnosedAt.month}/${item.diagnosedAt.year}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: GestureDetector(
                  onTap: () => _showHistoryDetailModal(item),
                  child: _historyItem(
                    title: '${item.cropName} • ${item.diseaseName}',
                    date: '$formattedDate • ${item.accuracyText}',
                    status: item.isHealthy ? 'Kondisi Baik' : item.severity,
                    isHealthy: item.isHealthy,
                  ),
                ),
              );
            }),
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
              color: isHealthy ? const Color(0xFF89D7B7) : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHealthy ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: isHealthy ? const Color(0xFF428475) : const Color(0xFFDC2626),
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
