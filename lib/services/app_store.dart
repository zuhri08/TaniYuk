import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';

/// Model lahan yang dikelola pengguna.
class LandModel {
  String id;
  String name;
  String location;
  String area;
  String soil;
  String status;

  LandModel({
    required this.id,
    required this.name,
    required this.location,
    required this.area,
    required this.soil,
    required this.status,
  });
}

/// Model transaksi keuangan tani. [amount] selalu bernilai positif,
/// arah uang ditentukan oleh [isIncome].
class TransactionModel {
  final String id;
  String title;
  DateTime date;
  double amount;
  bool isIncome;
  String category;

  TransactionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.category,
  });
}

/// Produk yang dijual di Pasar Tani.
class ProductModel {
  final String id;
  final String name;
  final String seller;
  final String unit;
  final double price;
  final String category;
  final IconData icon;
  final Color backgroundColor;
  final double rating;
  final String? phone;
  final bool isUserProduct;
  final Uint8List? imageBytes;
  final String? imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.seller,
    required this.unit,
    required this.price,
    required this.category,
    required this.icon,
    required this.backgroundColor,
    required this.rating,
    this.phone,
    this.isUserProduct = false,
    this.imageBytes,
    this.imageUrl,
  });
}

class ProfileModel {
  String name;
  String email;
  String phone;
  String location;
  String role;
  String joinedSince;

  ProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.role = 'Petani',
    this.joinedSince = 'Januari 2026',
  });
}

/// Sumber data tunggal yang terhubung dengan SQLite Database.
class AppStore extends ChangeNotifier {
  AppStore._() {
    _seed();
    _loadFromDatabase();
  }

  static final AppStore instance = AppStore._();

  late ProfileModel profile;
  final List<LandModel> lands = [];
  final List<TransactionModel> transactions = [];
  final List<ProductModel> products = [];
  final Map<String, int> cart = {};

  Future<void> _loadFromDatabase() async {
    try {
      final dbLands = await DbHelper.getLahanList();
      if (dbLands.isNotEmpty) {
        lands.clear();
        lands.addAll(dbLands);
      }

      final dbTrx = await DbHelper.getTransactions();
      if (dbTrx.isNotEmpty) {
        transactions.clear();
        transactions.addAll(dbTrx);
      }

      final dbCart = await DbHelper.getCartItems();
      if (dbCart.isNotEmpty) {
        cart.clear();
        cart.addAll(dbCart);
      }

      final dbProducts = await DbHelper.getProdukList();
      if (dbProducts.isNotEmpty) {
        for (var userProd in dbProducts) {
          if (!products.any((p) => p.id == userProd.id)) {
            products.insert(0, userProd);
          }
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('AppStore DB load notice: $e');
    }
  }

  void _seed() {
    profile = ProfileModel(
      name: 'Budi Santoso',
      email: 'budi.santoso@email.com',
      phone: '081234567890',
      location: 'Bandung, Jawa Barat',
    );

    lands.addAll([
      LandModel(
        id: 'land-1',
        name: 'Lahan Utama (Tomat)',
        location: 'Bandung, Jawa Barat',
        area: '1.000 m²',
        soil: 'Lempung',
        status: 'Aktif Tanam',
      ),
      LandModel(
        id: 'land-2',
        name: 'Lahan Cabai Lembang',
        location: 'Lembang, Jawa Barat',
        area: '750 m²',
        soil: 'Humus',
        status: 'Siap Panen',
      ),
      LandModel(
        id: 'land-3',
        name: 'Lahan Garut (Padi)',
        location: 'Garut, Jawa Barat',
        area: '2.500 m²',
        soil: 'Liat',
        status: 'Persiapan Lahan',
      ),
    ]);

    transactions.addAll([
      TransactionModel(
        id: 'trx-1',
        title: 'Penjualan Tomat',
        date: DateTime(2026, 10, 10),
        amount: 1500000,
        isIncome: true,
        category: 'Penjualan',
      ),
      TransactionModel(
        id: 'trx-2',
        title: 'Penjualan Cabai',
        date: DateTime(2026, 10, 7),
        amount: 2750000,
        isIncome: true,
        category: 'Penjualan',
      ),
      TransactionModel(
        id: 'trx-3',
        title: 'Penjualan Padi',
        date: DateTime(2026, 10, 2),
        amount: 2250000,
        isIncome: true,
        category: 'Penjualan',
      ),
      TransactionModel(
        id: 'trx-4',
        title: 'Pembelian Pupuk Organik',
        date: DateTime(2026, 10, 8),
        amount: 280000,
        isIncome: false,
        category: 'Pupuk',
      ),
      TransactionModel(
        id: 'trx-5',
        title: 'Biaya Tenaga Kerja Lahan',
        date: DateTime(2026, 10, 5),
        amount: 350000,
        isIncome: false,
        category: 'Tenaga Kerja',
      ),
      TransactionModel(
        id: 'trx-6',
        title: 'Pembelian Benih Selada',
        date: DateTime(2026, 10, 3),
        amount: 120000,
        isIncome: false,
        category: 'Benih',
      ),
      TransactionModel(
        id: 'trx-7',
        title: 'Perawatan & Pestisida',
        date: DateTime(2026, 10, 1),
        amount: 1500000,
        isIncome: false,
        category: 'Perawatan',
      ),
    ]);

    products.addAll(const [
      ProductModel(
        id: 'p-tomat',
        name: 'Tomat Segar',
        seller: 'Pak Joko • Bandung',
        unit: 'kg',
        price: 12000,
        category: 'Hasil Panen',
        icon: Icons.eco_outlined,
        backgroundColor: Color(0xFFFEF2F2),
        rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500',
      ),
      ProductModel(
        id: 'p-cabai',
        name: 'Cabai Merah',
        seller: 'Bu Siti • Lembang',
        unit: 'kg',
        price: 35000,
        category: 'Hasil Panen',
        icon: Icons.local_fire_department_outlined,
        backgroundColor: Color(0xFFFFF7ED),
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=500',
      ),
      ProductModel(
        id: 'p-bawang',
        name: 'Bawang Merah',
        seller: 'Tani Makmur • Garut',
        unit: 'kg',
        price: 28000,
        category: 'Hasil Panen',
        icon: Icons.spa_outlined,
        backgroundColor: Color(0xFFF5F3FF),
        rating: 4.7,
        imageUrl: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cf?w=500',
      ),
      ProductModel(
        id: 'p-jeruk',
        name: 'Jeruk Segar',
        seller: 'Kebun Ceria • Cimahi',
        unit: 'kg',
        price: 18000,
        category: 'Hasil Panen',
        icon: Icons.circle_outlined,
        backgroundColor: Color(0xFFFFFBEB),
        rating: 4.6,
        imageUrl: 'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?w=500',
      ),
      ProductModel(
        id: 'p-pupuk-organik',
        name: 'Pupuk Organik',
        seller: 'Tani Organik • Cimahi',
        unit: '5 kg',
        price: 25000,
        category: 'Pupuk',
        icon: Icons.compost_rounded,
        backgroundColor: Color(0xFFF0FDF4),
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1628352081506-83c43123ed6d?w=500',
      ),
      ProductModel(
        id: 'p-pupuk-npk',
        name: 'Pupuk NPK',
        seller: 'Sarana Tani • Bandung',
        unit: '5 kg',
        price: 45000,
        category: 'Pupuk',
        icon: Icons.grass_rounded,
        backgroundColor: Color(0xFFECFDF5),
        rating: 4.5,
        imageUrl: 'https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?w=500',
      ),
      ProductModel(
        id: 'p-benih-selada',
        name: 'Benih Selada',
        seller: 'Kebun Kita • Bandung',
        unit: 'pack',
        price: 15000,
        category: 'Benih',
        icon: Icons.spa_rounded,
        backgroundColor: Color(0xFFF7FEE7),
        rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1556801712-76c82798e4f1?w=500',
      ),
      ProductModel(
        id: 'p-benih-cabai',
        name: 'Benih Cabai',
        seller: 'Benih Unggul • Lembang',
        unit: 'pack',
        price: 20000,
        category: 'Benih',
        icon: Icons.energy_savings_leaf_outlined,
        backgroundColor: Color(0xFFFFF1F2),
        rating: 4.7,
        imageUrl: 'https://images.unsplash.com/photo-1563514227147-6d2ff665a6a0?w=500',
      ),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Profil
  // ---------------------------------------------------------------------------
  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? location,
  }) {
    if (name != null && name.trim().isNotEmpty) profile.name = name.trim();
    if (email != null && email.trim().isNotEmpty) profile.email = email.trim();
    if (phone != null && phone.trim().isNotEmpty) profile.phone = phone.trim();
    if (location != null && location.trim().isNotEmpty) {
      profile.location = location.trim();
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Lahan
  // ---------------------------------------------------------------------------
  void addLand({
    required String name,
    required String location,
    required String area,
    required String soil,
    required String status,
  }) {
    final land = LandModel(
      id: 'land-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      location: location,
      area: area,
      soil: soil,
      status: status,
    );
    lands.insert(0, land);
    DbHelper.insertLahan(land);
    notifyListeners();
  }

  void updateLand(
    LandModel land, {
    required String name,
    required String location,
    required String area,
    required String soil,
    required String status,
  }) {
    land
      ..name = name
      ..location = location
      ..area = area
      ..soil = soil
      ..status = status;
    DbHelper.updateLahan(land);
    notifyListeners();
  }

  void removeLand(LandModel land) {
    lands.remove(land);
    DbHelper.deleteLahan(land.id);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Keuangan
  // ---------------------------------------------------------------------------
  double get totalIncome => transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  /// Transaksi diurutkan dari yang terbaru.
  List<TransactionModel> get sortedTransactions {
    final list = List<TransactionModel>.from(transactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void addTransaction({
    required String title,
    required double amount,
    required bool isIncome,
    required String category,
    DateTime? date,
  }) {
    final tx = TransactionModel(
      id: 'trx-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      date: date ?? DateTime.now(),
      amount: amount.abs(),
      isIncome: isIncome,
      category: category,
    );
    transactions.add(tx);
    DbHelper.insertTransaction(tx);
    notifyListeners();
  }

  void removeTransaction(TransactionModel transaction) {
    transactions.remove(transaction);
    DbHelper.deleteTransaction(transaction.id);
    notifyListeners();
  }

  /// Total pemasukan/pengeluaran pada bulan & tahun tertentu.
  double incomeOfMonth(int year, int month) => transactions
      .where((t) => t.isIncome && t.date.year == year && t.date.month == month)
      .fold(0.0, (sum, t) => sum + t.amount);

  double expenseOfMonth(int year, int month) => transactions
      .where((t) => !t.isIncome && t.date.year == year && t.date.month == month)
      .fold(0.0, (sum, t) => sum + t.amount);

  // ---------------------------------------------------------------------------
  // Pasar Tani
  // ---------------------------------------------------------------------------
  ProductModel? productById(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  int quantityOf(String productId) => cart[productId] ?? 0;

  int get cartCount => cart.values.fold(0, (sum, qty) => sum + qty);

  double get cartTotal {
    var total = 0.0;
    cart.forEach((id, qty) {
      final product = productById(id);
      if (product != null) total += product.price * qty;
    });
    return total;
  }

  void addToCart(String productId, {int quantity = 1}) {
    final newQty = (cart[productId] ?? 0) + quantity;
    cart[productId] = newQty;
    DbHelper.updateCartItem(productId, newQty);
    notifyListeners();
  }

  void setCartQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      cart.remove(productId);
    } else {
      cart[productId] = quantity;
    }
    DbHelper.updateCartItem(productId, quantity);
    notifyListeners();
  }

  void removeFromCart(String productId) {
    cart.remove(productId);
    DbHelper.updateCartItem(productId, 0);
    notifyListeners();
  }

  void addProduct({
    required String name,
    required String unit,
    required double price,
    required String category,
    String? seller,
    String? phone,
    Uint8List? imageBytes,
    String? imageUrl,
  }) {
    final product = ProductModel(
      id: 'prod-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      seller: seller ?? '${profile.name} • ${profile.location}',
      unit: unit,
      price: price,
      category: category,
      icon: Icons.eco_outlined,
      backgroundColor: const Color(0xFFF0FDF4),
      rating: 5.0,
      phone: phone ?? profile.phone,
      isUserProduct: true,
      imageBytes: imageBytes,
      imageUrl: imageUrl,
    );

    products.insert(0, product);
    DbHelper.insertProduk(product);
    notifyListeners();
  }

  void deleteProduct(String productId) {
    products.removeWhere((p) => p.id == productId);
    DbHelper.deleteProduk(productId);
    notifyListeners();
  }

  /// Mengosongkan keranjang dan mengembalikan total pembayaran.
  double checkout() {
    final total = cartTotal;
    cart.clear();
    DbHelper.clearCart();
    notifyListeners();
    return total;
  }
}
