import 'package:flutter/material.dart';
import '../services/app_store.dart';

class DataLahanScreen extends StatelessWidget {
  const DataLahanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E1),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Data Lahan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final lands = store.lands;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lahan Terdaftar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF132E25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${lands.length} lahan',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (lands.isEmpty)
                  _emptyState(context)
                else
                  ...List.generate(lands.length, (index) {
                    final land = lands[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _landCard(context, land),
                    );
                  }),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openLandForm(context),
        backgroundColor: const Color(0xFF132E25),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Lahan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF89D7B7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.landscape_outlined, color: Color(0xFF132E25), size: 36),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum ada lahan terdaftar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tambahkan lahanmu agar rekomendasi tanam dan catatan aktivitas lebih akurat.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openLandForm(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah Lahan Pertama'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF132E25),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _landCard(BuildContext context, LandModel land) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  land.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF89D7B7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  land.status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF428475),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') {
                    _openLandForm(context, land: land);
                  } else if (value == 'delete') {
                    _confirmDelete(context, land);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: Color(0xFF132E25)),
                        SizedBox(width: 8),
                        Text('Ubah'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(land.location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _infoBox('Luas', land.area)),
              const SizedBox(width: 8),
              Expanded(child: _infoBox('Jenis Tanah', land.soil)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, LandModel land) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Hapus lahan?'),
        content: Text('"${land.name}" akan dihapus dari daftar lahanmu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              AppStore.instance.removeLand(land);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${land.name} berhasil dihapus.')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openLandForm(BuildContext context, {LandModel? land}) {
    final messenger = ScaffoldMessenger.of(context);
    final nameController = TextEditingController(text: land?.name ?? '');
    final locationController = TextEditingController(text: land?.location ?? '');
    final areaController = TextEditingController(text: land?.area ?? '');
    String selectedSoil = land?.soil ?? 'Lempung';
    String selectedStatus = land?.status ?? 'Aktif Tanam';

    const soils = ['Lempung', 'Liat', 'Berpasir', 'Humus', 'Vulkanik'];
    const statuses = ['Aktif Tanam', 'Siap Panen', 'Persiapan Lahan', 'Istirahat'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          land == null ? 'Tambah Lahan Baru' : 'Ubah Data Lahan',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _formField('Nama Lahan', nameController, 'Contoh: Lahan Tomat Belakang'),
                    const SizedBox(height: 12),
                    _formField('Lokasi', locationController, 'Contoh: Bandung, Jawa Barat'),
                    const SizedBox(height: 12),
                    _formField(
                      'Luas Lahan',
                      areaController,
                      'Contoh: 1.000 m²',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    _dropdownField(
                      label: 'Jenis Tanah',
                      value: selectedSoil,
                      items: soils,
                      onChanged: (value) => setSheetState(() => selectedSoil = value),
                    ),
                    const SizedBox(height: 12),
                    _dropdownField(
                      label: 'Status Lahan',
                      value: selectedStatus,
                      items: statuses,
                      onChanged: (value) => setSheetState(() => selectedStatus = value),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final location = locationController.text.trim();
                          final area = areaController.text.trim();

                          if (name.isEmpty || location.isEmpty || area.isEmpty) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(
                                content: Text('Nama, lokasi, dan luas lahan wajib diisi.'),
                              ),
                            );
                            return;
                          }

                          if (land == null) {
                            AppStore.instance.addLand(
                              name: name,
                              location: location,
                              area: area,
                              soil: selectedSoil,
                              status: selectedStatus,
                            );
                          } else {
                            AppStore.instance.updateLand(
                              land,
                              name: name,
                              location: location,
                              area: area,
                              soil: selectedSoil,
                              status: selectedStatus,
                            );
                          }

                          Navigator.pop(sheetContext);
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                land == null
                                    ? 'Lahan "$name" berhasil ditambahkan.'
                                    : 'Data lahan "$name" berhasil diperbarui.',
                              ),
                            ),
                          );
                        },
                        icon: Icon(land == null ? Icons.add_rounded : Icons.save_rounded, size: 20),
                        label: Text(
                          land == null ? 'Simpan Lahan' : 'Simpan Perubahan',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _formField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: items
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (selected) {
                if (selected != null) onChanged(selected);
              },
            ),
          ),
        ),
      ],
    );
  }
}
