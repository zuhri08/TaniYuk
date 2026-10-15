import 'package:flutter/material.dart';

class PasarTaniScreen extends StatefulWidget {
  const PasarTaniScreen({super.key});

  @override
  State<PasarTaniScreen> createState() => _PasarTaniScreenState();
}

class _PasarTaniScreenState extends State<PasarTaniScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', 'Hasil Panen', 'Benih', 'Pupuk'];

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
              'Pasar Pertanian',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Dari petani, untuk kebutuhanmu',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF0F623F)),
            onPressed: () {},
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
              decoration: InputDecoration(
                hintText: 'Cari hasil panen atau kebutuhan tani...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                suffixIcon: const Icon(Icons.tune_rounded, color: Color(0xFF0F623F)),
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
                  final isSelected = _selectedFilter == index;
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
                          _selectedFilter = index;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Location distance info
            Row(
              children: const [
                Icon(Icons.location_on, color: Color(0xFF0F623F), size: 16),
                SizedBox(width: 4),
                Text(
                  'Produk di sekitar Bandung • Radius 25 km',
                  style: TextStyle(fontSize: 12, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Section Produk Pilihan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Produk Pilihan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Terbaru',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Product Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.75,
              children: [
                _productCard(
                  name: 'Tomat Segar',
                  price: 'Rp12.000 / kg',
                  seller: 'Pak Joko • Bandung',
                  rating: '★ 4.8',
                  bgColor: Colors.red.shade50,
                  icon: Icons.eco_outlined,
                ),
                _productCard(
                  name: 'Cabai Merah',
                  price: 'Rp35.000 / kg',
                  seller: 'Bu Siti • Lembang',
                  rating: '★ 4.8',
                  bgColor: Colors.orange.shade50,
                  icon: Icons.local_fire_department_outlined,
                ),
                _productCard(
                  name: 'Pupuk Organik',
                  price: 'Rp25.000 / 5 kg',
                  seller: 'Tani Organik • Cimahi',
                  rating: '★ 4.9',
                  bgColor: Colors.green.shade50,
                  icon: Icons.compost_rounded,
                ),
                _productCard(
                  name: 'Benih Selada',
                  price: 'Rp15.000 / pack',
                  seller: 'Kebun Kita • Bandung',
                  rating: '★ 4.8',
                  bgColor: Colors.lightGreen.shade50,
                  icon: Icons.grass_rounded,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _productCard({
    required String name,
    required String price,
    required String seller,
    required String rating,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(icon, color: const Color(0xFF0F623F), size: 40),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F623F),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  seller,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
              Text(
                rating,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
