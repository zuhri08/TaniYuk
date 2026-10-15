import 'package:flutter/material.dart';

class CatatanItem {
  final String title;
  final String time;
  final String description;
  final String tag;
  final Color tagColor;
  final Color textColor;
  final IconData icon;

  CatatanItem({
    required this.title,
    required this.time,
    required this.description,
    required this.tag,
    required this.tagColor,
    required this.textColor,
    required this.icon,
  });
}

class CatatanAktivitasScreen extends StatefulWidget {
  const CatatanAktivitasScreen({super.key});

  @override
  State<CatatanAktivitasScreen> createState() => _CatatanAktivitasScreenState();
}

class _CatatanAktivitasScreenState extends State<CatatanAktivitasScreen> {
  int _selectedChip = 0;
  final List<String> _filters = ['Semua', 'Perawatan', 'Panen', 'Pemupukan', 'Pengecekan'];
  String _searchQuery = '';

  final List<CatatanItem> _catatanList = [
    CatatanItem(
      title: 'Penyiraman Lahan Tomat',
      time: 'Hari ini, 07:00',
      description: 'Penyiraman pagi selesai. Kondisi tanah lembap, tanaman tumbuh baik.',
      tag: 'Perawatan',
      tagColor: const Color(0xFFE0F2FE),
      textColor: const Color(0xFF1E40AF),
      icon: Icons.water_drop_outlined,
    ),
    CatatanItem(
      title: 'Pemupukan Lahan Cabai',
      time: 'Kemarin, 08:30',
      description: 'Pupuk organik 10 kg diberikan merata pada lahan cabai.',
      tag: 'Pemupukan',
      tagColor: const Color(0xFFFEF3C7),
      textColor: const Color(0xFF92400E),
      icon: Icons.compost_rounded,
    ),
    CatatanItem(
      title: 'Pengecekan Hama',
      time: '10 Oktober 2026, 16:00',
      description: 'Ditemukan ulat pada beberapa daun. Lakukan penanganan besok pagi.',
      tag: 'Pengecekan',
      tagColor: const Color(0xFFFEE2E2),
      textColor: const Color(0xFF991B1B),
      icon: Icons.bug_report_outlined,
    ),
    CatatanItem(
      title: 'Panen Tomat Musim Pertama',
      time: '05 Oktober 2026, 09:00',
      description: 'Hasil panen 45 kg tomat segar kualitas A.',
      tag: 'Panen',
      tagColor: const Color(0xFFDCFCE7),
      textColor: const Color(0xFF166534),
      icon: Icons.eco_outlined,
    ),
  ];

  List<CatatanItem> get _filteredList {
    return _catatanList.where((item) {
      final filterTag = _filters[_selectedChip];
      final matchesFilter = filterTag == 'Semua' || item.tag == filterTag;
      final matchesQuery = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();
  }

  void _showTambahCatatanModal() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Perawatan';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      const Text(
                        'Tambah Catatan Aktivitas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Judul Aktivitas
                  const Text(
                    'Judul Aktivitas',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Pemupukan Lahan Tomat',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Kategori Dropdown
                  const Text(
                    'Kategori',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        items: ['Perawatan', 'Pemupukan', 'Pengecekan', 'Panen']
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat, style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedCategory = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Deskripsi
                  const Text(
                    'Catatan / Detail Aktivitas',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan detail aktivitas pertanianmu di sini...',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Judul aktivitas tidak boleh kosong!')),
                          );
                          return;
                        }

                        Color tagBg;
                        Color tagTxt;
                        IconData tagIcon;

                        switch (selectedCategory) {
                          case 'Pemupukan':
                            tagBg = const Color(0xFFFEF3C7);
                            tagTxt = const Color(0xFF92400E);
                            tagIcon = Icons.compost_rounded;
                            break;
                          case 'Pengecekan':
                            tagBg = const Color(0xFFFEE2E2);
                            tagTxt = const Color(0xFF991B1B);
                            tagIcon = Icons.bug_report_outlined;
                            break;
                          case 'Panen':
                            tagBg = const Color(0xFFDCFCE7);
                            tagTxt = const Color(0xFF166534);
                            tagIcon = Icons.eco_outlined;
                            break;
                          default:
                            tagBg = const Color(0xFFE0F2FE);
                            tagTxt = const Color(0xFF1E40AF);
                            tagIcon = Icons.water_drop_outlined;
                        }

                        setState(() {
                          _catatanList.insert(
                            0,
                            CatatanItem(
                              title: titleController.text.trim(),
                              time: 'Hari ini, Baru saja',
                              description: descController.text.trim().isNotEmpty
                                  ? descController.text.trim()
                                  : 'Tidak ada detail catatan tambahan.',
                              tag: selectedCategory,
                              tagColor: tagBg,
                              textColor: tagTxt,
                              icon: tagIcon,
                            ),
                          );
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Catatan berhasil ditambahkan!'),
                            backgroundColor: Color(0xFF0F623F),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F623F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Simpan Catatan',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
              'Catatan Pertanian',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Rekam aktivitas, pantau perkembangan',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF0F623F)),
            tooltip: 'Tambah Catatan',
            onPressed: _showTambahCatatanModal,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari catatan aktivitas...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                suffixIcon: const Icon(Icons.calendar_month_outlined, color: Color(0xFF0F623F)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedChip == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_filters[index]),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0F623F),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF4B5563),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(color: Colors.grey.shade200),
                      onSelected: (selected) {
                        setState(() {
                          _selectedChip = index;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 18),

            // Banner Aktivitas Bulan Ini
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F623F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_catatanList.length} Aktivitas Bulan Ini',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F623F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Lahan terawat, hasil panen meningkat.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Catatan Terbaru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Catatan Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Oktober 2026',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (_filteredList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.notes_rounded, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada catatan aktivitas',
                      style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredList.length,
                itemBuilder: (context, index) {
                  final item = _filteredList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _activityCard(
                      title: item.title,
                      time: item.time,
                      description: item.description,
                      tag: item.tag,
                      tagColor: item.tagColor,
                      textColor: item.textColor,
                      icon: item.icon,
                    ),
                  );
                },
              ),
            const SizedBox(height: 60),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTambahCatatanModal,
        backgroundColor: const Color(0xFF0F623F),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Catatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _activityCard({
    required String title,
    required String time,
    required String description,
    required String tag,
    required Color tagColor,
    required Color textColor,
    required IconData icon,
  }) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF0F623F), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.3),
          ),
        ],
      ),
    );
  }
}
