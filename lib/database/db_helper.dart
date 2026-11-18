import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../services/app_store.dart';

class DbHelper {
  static Database? _database;

  static Future<Database?> get database async {
    if (kIsWeb) return null; // Web fallback menggunakan in-memory state & SharedPreferences
    if (_database != null) return _database;
    _database = await _initDb();
    return _database;
  }

  static Future<Database> _initDb() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, 'taniyuk.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 1. Tabel Data Lahan
        await db.execute('''
          CREATE TABLE lahan (
            id TEXT PRIMARY KEY,
            name TEXT,
            location TEXT,
            area TEXT,
            soil TEXT,
            status TEXT
          )
        ''');

        // 2. Tabel Transaksi Keuangan UangTani
        await db.execute('''
          CREATE TABLE transaksi_keuangan (
            id TEXT PRIMARY KEY,
            title TEXT,
            date TEXT,
            amount REAL,
            is_income INTEGER,
            category TEXT
          )
        ''');

        // 3. Tabel Keranjang Belanja Pasar Tani
        await db.execute('''
          CREATE TABLE keranjang (
            product_id TEXT PRIMARY KEY,
            quantity INTEGER
          )
        ''');

        // 4. Tabel Produk Pertanian buatan Pengguna
        await db.execute('''
          CREATE TABLE produk_tani (
            id TEXT PRIMARY KEY,
            name TEXT,
            seller TEXT,
            unit TEXT,
            price REAL,
            category TEXT,
            phone TEXT,
            image_bytes BLOB,
            image_url TEXT
          )
        ''');

        // 5. Tabel Sesi / Pengaturan Pengguna
        await db.execute('''
          CREATE TABLE user_settings (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');

        // Insert Data Default Lahan
        await db.insert('lahan', {
          'id': '1',
          'name': 'Lahan Padi Utama',
          'location': 'Kec. Sambikerep, Surabaya Barat',
          'area': '1.000 m²',
          'soil': 'Lempung / Humus',
          'status': 'Aktif Tanam',
        });
        await db.insert('lahan', {
          'id': '2',
          'name': 'Lahan Tomat & Cabai',
          'location': 'Kec. Benowo, Surabaya Barat',
          'area': '500 m²',
          'soil': 'Berpasir / Humus',
          'status': 'Siap Olah Lahan',
        });

        // Insert Data Default Transaksi Keuangan
        await db.insert('transaksi_keuangan', {
          'id': '1',
          'title': 'Hasil Penjualan Panen Padi',
          'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'amount': 2500000.0,
          'is_income': 1,
          'category': 'Panen',
        });
        await db.insert('transaksi_keuangan', {
          'id': '2',
          'title': 'Beli Pupuk NPK & Urea',
          'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          'amount': 450000.0,
          'is_income': 0,
          'category': 'Pupuk',
        });
      },
    );
  }

  // --- METHODS LAHAN ---
  static Future<List<LandModel>> getLahanList() async {
    final db = await database;
    if (db == null) return [];
    final List<Map<String, dynamic>> maps = await db.query('lahan');
    return maps.map((map) {
      return LandModel(
        id: map['id'] as String,
        name: map['name'] as String,
        location: map['location'] as String,
        area: map['area'] as String,
        soil: map['soil'] as String,
        status: map['status'] as String,
      );
    }).toList();
  }

  static Future<void> insertLahan(LandModel land) async {
    final db = await database;
    if (db == null) return;
    await db.insert(
      'lahan',
      {
        'id': land.id,
        'name': land.name,
        'location': land.location,
        'area': land.area,
        'soil': land.soil,
        'status': land.status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateLahan(LandModel land) async {
    final db = await database;
    if (db == null) return;
    await db.update(
      'lahan',
      {
        'name': land.name,
        'location': land.location,
        'area': land.area,
        'soil': land.soil,
        'status': land.status,
      },
      where: 'id = ?',
      whereArgs: [land.id],
    );
  }

  static Future<void> deleteLahan(String id) async {
    final db = await database;
    if (db == null) return;
    await db.delete('lahan', where: 'id = ?', whereArgs: [id]);
  }

  // --- METHODS TRANSAKSI KEUANGAN ---
  static Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    if (db == null) return [];
    final List<Map<String, dynamic>> maps = await db.query('transaksi_keuangan', orderBy: 'date DESC');
    return maps.map((map) {
      return TransactionModel(
        id: map['id'] as String,
        title: map['title'] as String,
        date: DateTime.tryParse(map['date'] as String) ?? DateTime.now(),
        amount: (map['amount'] as num).toDouble(),
        isIncome: (map['is_income'] as int) == 1,
        category: map['category'] as String,
      );
    }).toList();
  }

  static Future<void> insertTransaction(TransactionModel tx) async {
    final db = await database;
    if (db == null) return;
    await db.insert(
      'transaksi_keuangan',
      {
        'id': tx.id,
        'title': tx.title,
        'date': tx.date.toIso8601String(),
        'amount': tx.amount,
        'is_income': tx.isIncome ? 1 : 0,
        'category': tx.category,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteTransaction(String id) async {
    final db = await database;
    if (db == null) return;
    await db.delete('transaksi_keuangan', where: 'id = ?', whereArgs: [id]);
  }

  // --- METHODS KERANJANG ---
  static Future<Map<String, int>> getCartItems() async {
    final db = await database;
    if (db == null) return {};
    final List<Map<String, dynamic>> maps = await db.query('keranjang');
    final Map<String, int> cart = {};
    for (var m in maps) {
      cart[m['product_id'] as String] = m['quantity'] as int;
    }
    return cart;
  }

  static Future<void> updateCartItem(String productId, int quantity) async {
    final db = await database;
    if (db == null) return;
    if (quantity <= 0) {
      await db.delete('keranjang', where: 'product_id = ?', whereArgs: [productId]);
    } else {
      await db.insert(
        'keranjang',
        {'product_id': productId, 'quantity': quantity},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<void> clearCart() async {
    final db = await database;
    if (db == null) return;
    await db.delete('keranjang');
  }

  // --- METHODS PRODUK TANI PENGGUNA ---
  static Future<List<ProductModel>> getProdukList() async {
    final db = await database;
    if (db == null) return [];
    try {
      final List<Map<String, dynamic>> maps = await db.query('produk_tani');
      return maps.map((map) {
        return ProductModel(
          id: map['id'] as String,
          name: map['name'] as String,
          seller: map['seller'] as String,
          unit: map['unit'] as String,
          price: (map['price'] as num).toDouble(),
          category: map['category'] as String,
          icon: Icons.eco_outlined,
          backgroundColor: const Color(0xFFF0FDF4),
          rating: 5.0,
          phone: map['phone'] as String?,
          isUserProduct: true,
          imageBytes: map['image_bytes'] as Uint8List?,
          imageUrl: map['image_url'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error query produk_tani: $e');
      return [];
    }
  }

  static Future<void> insertProduk(ProductModel product) async {
    final db = await database;
    if (db == null) return;
    await db.insert(
      'produk_tani',
      {
        'id': product.id,
        'name': product.name,
        'seller': product.seller,
        'unit': product.unit,
        'price': product.price,
        'category': product.category,
        'phone': product.phone ?? '081234567890',
        'image_bytes': product.imageBytes,
        'image_url': product.imageUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteProduk(String id) async {
    final db = await database;
    if (db == null) return;
    await db.delete('produk_tani', where: 'id = ?', whereArgs: [id]);
  }
}
