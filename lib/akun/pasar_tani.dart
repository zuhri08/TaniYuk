import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../services/ecommerce_sync_service.dart';
import '../services/whatsapp_commerce_service.dart';
import '../util/formatters.dart';
import '../util/permission_helper.dart';
import '../util/media_picker_service.dart';
import 'keranjang_screen.dart';

class PasarTaniScreen extends StatefulWidget {
  const PasarTaniScreen({super.key});

  @override
  State<PasarTaniScreen> createState() => _PasarTaniScreenState();
}

class _PasarTaniScreenState extends State<PasarTaniScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', 'Hasil Panen', 'Benih', 'Pupuk'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSyncedOrdersModal() {
    final orders = EcommerceSyncService.syncedOrders;

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
                  const Text(
                    '📦 Log Pesanan Shopee & Tokopedia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...orders.map((o) {
                final isShopee = o.platform == 'Shopee';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isShopee ? const Color(0xFFFFF1F0) : const Color(0xFFE6F7F0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isShopee ? Icons.shopping_bag_outlined : Icons.storefront_outlined,
                          color: isShopee ? const Color(0xFFEE4D2D) : const Color(0xFF03AC0E),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${o.platform} • ${o.productName} (x${o.quantity})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${o.buyerName} • ${o.orderId}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rp ${o.totalPrice.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF132E25)),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showApiTestModal();
                  },
                  icon: const Icon(Icons.bug_report_outlined, size: 18),
                  label: const Text('Uji Live Ping API & HMAC Signature Proof', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF132E25),
                    side: const BorderSide(color: Color(0xFF132E25)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showApiTestModal() {
    bool isTesting = false;
    Map<String, dynamic>? shopeeResult;
    Map<String, dynamic>? tokopediaResult;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                        const Text(
                          '⚡ Live Open API Proof & HMAC Test',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Menjalankan kalkulasi tanda tangan HMAC-SHA256 & permintaan HTTP nyata ke server Shopee Open Platform & Tokopedia Developer API.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• Shopee Partner ID: ${EcommerceSyncService.shopeeCreds.partnerId}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('• Shopee Shop ID: ${EcommerceSyncService.shopeeCreds.shopId}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('• Tokopedia Client ID: ${EcommerceSyncService.tokopediaCreds.clientId}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: isTesting
                            ? null
                            : () async {
                                setModalState(() {
                                  isTesting = true;
                                });

                                final shopee = await ShopeeOpenApiClient.testLiveShopeeApi(
                                  creds: EcommerceSyncService.shopeeCreds,
                                );
                                final tokopedia = await TokopediaOpenApiClient.testLiveTokopediaApi(
                                  creds: EcommerceSyncService.tokopediaCreds,
                                );

                                setModalState(() {
                                  shopeeResult = shopee;
                                  tokopediaResult = tokopedia;
                                  isTesting = false;
                                });
                              },
                        icon: isTesting
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          isTesting ? 'Mengirim HTTP Request Live...' : 'Jalankan Live Ping & HMAC Test',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF132E25),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (shopeeResult != null) ...[
                      const Text('Hasil HTTP Request Shopee v2 API:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFEE4D2D))),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Endpoint: ${shopeeResult!['endpoint']}', style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontFamily: 'monospace')),
                            Text('HMAC-SHA256 Sign: ${shopeeResult!['signature']}', style: const TextStyle(color: Colors.amberAccent, fontSize: 10, fontFamily: 'monospace')),
                            Text('HTTP Status Code: ${shopeeResult!['statusCode']}', style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
                            Text('Latency: ${shopeeResult!['latencyMs']} ms', style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontFamily: 'monospace')),
                            const SizedBox(height: 4),
                            Text('RAW Payload: ${shopeeResult!['rawResponseBody']}', style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (tokopediaResult != null) ...[
                      const Text('Hasil HTTP Request Tokopedia OAuth2 API:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF03AC0E))),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Endpoint: ${tokopediaResult!['endpoint']}', style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontFamily: 'monospace')),
                            Text('HTTP Status Code: ${tokopediaResult!['statusCode']}', style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
                            Text('Latency: ${tokopediaResult!['latencyMs']} ms', style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontFamily: 'monospace')),
                            const SizedBox(height: 4),
                            Text('RAW Payload: ${tokopediaResult!['rawResponseBody']}', style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddProductModal(BuildContext context, AppStore store) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final unitController = TextEditingController(text: 'kg');
    final phoneController = TextEditingController(text: store.profile.phone);
    String selectedCat = 'Hasil Panen';
    PickedMediaResult? attachedProductMedia;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        const Text(
                          '🌱 Jual Produk / Hasil Panen',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Photo Picker Button & Preview
                    const Text('Foto Produk / Hasil Panen:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        PermissionHelper.requestGalleryPermission(
                          context,
                          onGranted: () async {
                            final media = await MediaPickerService.pickImageFromGallery();
                            if (media != null) {
                              setSheetState(() {
                                attachedProductMedia = media;
                              });
                            }
                          },
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: attachedProductMedia != null && attachedProductMedia!.bytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  attachedProductMedia!.bytes!,
                                  width: double.infinity,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo_outlined, color: Color(0xFF132E25), size: 28),
                                  SizedBox(height: 6),
                                  Text('Pilih Foto Produk dari Galeri / Kamera HP', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text('Nama Produk / Hasil Tani:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Misal: Bawang Merah Brebes Super',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Harga per Satuan (Rp):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Misal: 25000',
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Satuan (Unit):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: unitController,
                                decoration: InputDecoration(
                                  hintText: 'kg, pack, ikat, 5 kg',
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    const Text('Kategori Produk:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: ['Hasil Panen', 'Benih', 'Pupuk'].map((cat) {
                        final isSel = selectedCat == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          selectedColor: const Color(0xFF132E25),
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF4B5563),
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (_) => setSheetState(() => selectedCat = cat),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    const Text('Nomor HP / WhatsApp Penjual:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '081234567890',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final priceStr = priceController.text.trim();
                          final unit = unitController.text.trim();
                          final phone = phoneController.text.trim();

                          if (name.isEmpty || priceStr.isEmpty || unit.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lengkapi nama, harga, dan satuan produk!')),
                            );
                            return;
                          }

                          final price = double.tryParse(priceStr) ?? 0.0;

                          store.addProduct(
                            name: name,
                            unit: unit,
                            price: price,
                            category: selectedCat,
                            phone: phone,
                            imageBytes: attachedProductMedia?.bytes,
                            imageUrl: attachedProductMedia?.objectUrl,
                          );

                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✨ Produk "$name" berhasil diterbitkan ke Pasar Tani & tersimpan di Database!'),
                              backgroundColor: const Color(0xFF132E25),
                            ),
                          );
                        },
                        icon: const Icon(Icons.publish_rounded, size: 18),
                        label: const Text('Terbitkan ke Pasar Tani', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF132E25),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<ProductModel> _filteredProducts(List<ProductModel> products) {
    final category = _filters[_selectedFilter];
    final query = _searchQuery.trim().toLowerCase();

    return products.where((product) {
      final matchesCategory = category == 'Semua' || product.category == category;
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.seller.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Pasar Pertanian',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Dari petani, untuk kebutuhanmu',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
            tooltip: 'Log Order',
            onPressed: _showSyncedOrdersModal,
          ),
          ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              final count = store.cartCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    tooltip: 'Keranjang',
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    onPressed: () => _openCart(context),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16),
                        child: Text(
                          '$count',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final products = _filteredProducts(store.products);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Cari hasil panen atau kebutuhan tani...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                    suffixIcon: _searchQuery.isEmpty
                        ? const Icon(Icons.tune_rounded, color: Color(0xFF132E25))
                        : IconButton(
                            tooltip: 'Bersihkan pencarian',
                            icon: const Icon(Icons.close_rounded, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
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
                          selectedColor: const Color(0xFF132E25),
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
                          onSelected: (_) => setState(() => _selectedFilter = index),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF132E25), size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Produk di sekitar ${store.profile.location.split(',').first.trim()} • Radius 25 km',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _searchQuery.isEmpty && _selectedFilter == 0
                          ? 'Produk Pilihan'
                          : 'Hasil (${products.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Text(
                      'Terbaru',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (products.isEmpty)
                  _emptyResult()
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _productCard(product);
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductModal(context, store),
        backgroundColor: const Color(0xFF132E25),
        icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
        label: const Text('Jual Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _emptyResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          const Text(
            'Produk tidak ditemukan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba kata kunci lain atau ubah filter kategori.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedFilter = 0;
              });
            },
            child: const Text('Reset pencarian'),
          ),
        ],
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    final store = AppStore.instance;
    final quantity = store.quantityOf(product.id);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showProductDetail(product),
      child: Container(
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
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: product.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: product.imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              product.imageBytes!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  product.imageUrl!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Center(
                                    child: Icon(product.icon, color: const Color(0xFF132E25), size: 40),
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(product.icon, color: const Color(0xFF132E25), size: 40),
                              ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '★ ${product.rating}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${formatRupiah(product.price)} / ${product.unit}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF132E25),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.seller,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton.icon(
                onPressed: () {
                  store.addToCart(product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 2),
                      content: Text('${product.name} ditambahkan ke keranjang.'),
                      action: SnackBarAction(
                        label: 'Lihat',
                        textColor: Colors.amber,
                        onPressed: () => _openCart(context),
                      ),
                    ),
                  );
                },
                icon: Icon(
                  quantity > 0 ? Icons.add_shopping_cart_rounded : Icons.shopping_cart_outlined,
                  size: 15,
                ),
                label: Text(
                  quantity > 0 ? 'Tambah ($quantity)' : 'Keranjang',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF132E25),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetail(ProductModel product) {
    final store = AppStore.instance;
    var quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 170,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: product.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: product.imageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                product.imageBytes!,
                                width: double.infinity,
                                height: 170,
                                fit: BoxFit.cover,
                              ),
                            )
                          : (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    product.imageUrl!,
                                    width: double.infinity,
                                    height: 170,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Center(
                                      child: Icon(product.icon, color: const Color(0xFF132E25), size: 64),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Icon(product.icon, color: const Color(0xFF132E25), size: 64),
                                ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 20,
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
                            product.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF428475),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.seller,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${formatRupiah(product.price)} / ${product.unit}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF132E25),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Produk segar langsung dari petani sekitar Bandung. Dikemas higienis dan siap dikirim ke lokasimu.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Jumlah',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        _quantityButton(
                          icon: Icons.remove_rounded,
                          onTap: () {
                            if (quantity > 1) setSheetState(() => quantity--);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        _quantityButton(
                          icon: Icons.add_rounded,
                          onTap: () => setSheetState(() => quantity++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                store.addToCart(product.id, quantity: quantity);
                                Navigator.pop(sheetContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$quantity ${product.unit} ${product.name} masuk keranjang.'),
                                    action: SnackBarAction(
                                      label: 'Lihat',
                                      textColor: Colors.amber,
                                      onPressed: () => _openCart(context),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.shopping_cart_rounded, size: 18),
                              label: Text(
                                'Keranjang • ${formatRupiah(product.price * quantity)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF132E25),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                WhatsappCommerceService.sendOrderToFarmerWhatsApp(
                                  farmerPhone: '081234567890',
                                  farmerName: product.seller,
                                  orderItems: [
                                    {
                                      'name': product.name,
                                      'qty': quantity,
                                      'price': product.price,
                                    }
                                  ],
                                  totalPrice: product.price * quantity,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('💬 Membuka WhatsApp untuk pesanan langsung ke HP Petani!'),
                                    backgroundColor: Color(0xFF075E54),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.chat_rounded, size: 18),
                              label: const Text(
                                'Beli via WA',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _quantityButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF132E25)),
      ),
    );
  }

  void _openCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KeranjangScreen()),
    );
  }
}
