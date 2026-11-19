import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool isInitialized = false;

  /// Inisialisasi SDK Firebase Core & Firestore Collections
  static Future<void> initializeFirebase() async {
    if (isInitialized) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      isInitialized = true;
      debugPrint('Firebase Core initialized successfully.');

      // Otomatis sinkronkan koleksi data awal ke Cloud Firestore
      unawaited(seedInitialFirestoreCollections());
    } catch (e) {
      debugPrint('Firebase init notice: $e');
    }
  }

  // --- FIREBASE AUTH ---
  static FirebaseAuth get auth => FirebaseAuth.instance;

  static User? get currentUser => auth.currentUser;

  static Future<UserCredential?> registerUser({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    await initializeFirebase();
    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final displayName = (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : email.split('@').first;

      if (cred.user != null) {
        try {
          await cred.user!.updateDisplayName(displayName);
        } catch (e) {
          debugPrint('Update display name notice: $e');
        }

        await saveUserProfileToFirestore(
          uid: cred.user!.uid,
          name: displayName,
          email: email,
          phone: phone,
        );
      }
      return cred;
    } catch (e) {
      debugPrint('Firebase Auth Register Error: $e');
      rethrow;
    }
  }

  static Future<UserCredential?> loginUser({
    required String email,
    required String password,
  }) async {
    await initializeFirebase();
    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user != null) {
        final profileDoc = await getUserProfileFromFirestore(cred.user!.uid);
        final fetchedName = profileDoc?['name'] as String? ?? cred.user!.displayName ?? email.split('@').first;
        final fetchedPhone = profileDoc?['phone'] as String? ?? '081234567890';
        final fetchedLocation = profileDoc?['location'] as String? ?? 'Surabaya, Jawa Timur';

        await saveUserProfileToFirestore(
          uid: cred.user!.uid,
          name: fetchedName,
          email: cred.user!.email ?? email,
          phone: fetchedPhone,
          location: fetchedLocation,
        );
      }
      return cred;
    } catch (e) {
      debugPrint('Firebase Auth Login Error: $e');
      rethrow;
    }
  }

  static Future<UserCredential?> loginWithGoogle() async {
    await initializeFirebase();
    try {
      final googleProvider = GoogleAuthProvider();
      final cred = await auth.signInWithPopup(googleProvider);
      if (cred.user != null) {
        await saveUserProfileToFirestore(
          uid: cred.user!.uid,
          name: cred.user!.displayName ?? 'Petani Google TaniYuk',
          email: cred.user!.email ?? 'petani.google@taniyuk.id',
        );
      }
      return cred;
    } catch (e) {
      debugPrint('Firebase Google Auth Notice: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    await auth.signOut();
  }

  // --- CLOUD FIRESTORE DATABASE ---
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Mengambil Profil Pengguna dari Cloud Firestore
  static Future<Map<String, dynamic>?> getUserProfileFromFirestore(String uid) async {
    await initializeFirebase();
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('Firestore fetch user profile notice: $e');
    }
    return null;
  }

  /// Menyimpan Profil Pengguna ke Cloud Firestore ('users')
  static Future<void> saveUserProfileToFirestore({
    required String uid,
    required String name,
    required String email,
    String? phone,
    String? location,
  }) async {
    await initializeFirebase();
    try {
      await firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone ?? '081234567890',
        'role': 'Petani TaniYuk',
        'location': location ?? 'Surabaya, Jawa Timur',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('Cloud Firestore: User profile synced ($email)');
    } catch (e) {
      debugPrint('Firestore save user notice: $e');
    }
  }

  /// Menyimpan Postingan Komunitas ke Cloud Firestore ('ruang_tani')
  static Future<void> syncPostToFirestore(Map<String, dynamic> postData) async {
    await initializeFirebase();
    try {
      await firestore
          .collection('ruang_tani')
          .doc(postData['id'] as String)
          .set(postData, SetOptions(merge: true));
      debugPrint('Cloud Firestore: Post synced (${postData['id']})');
    } catch (e) {
      debugPrint('Firestore sync post notice: $e');
    }
  }

  /// Menyimpan Data Lahan ke Cloud Firestore ('lahan')
  static Future<void> syncLandToFirestore(Map<String, dynamic> landData) async {
    await initializeFirebase();
    try {
      await firestore
          .collection('lahan')
          .doc(landData['id'] as String)
          .set(landData, SetOptions(merge: true));
      debugPrint('Cloud Firestore: Land synced (${landData['id']})');
    } catch (e) {
      debugPrint('Firestore sync land notice: $e');
    }
  }

  /// Menyimpan Catatan Transaksi Keuangan ke Cloud Firestore ('transaksi_keuangan')
  static Future<void> syncTransactionToFirestore(Map<String, dynamic> txData) async {
    await initializeFirebase();
    try {
      await firestore
          .collection('transaksi_keuangan')
          .doc(txData['id'] as String)
          .set(txData, SetOptions(merge: true));
      debugPrint('Cloud Firestore: Transaction synced (${txData['id']})');
    } catch (e) {
      debugPrint('Firestore sync tx notice: $e');
    }
  }

  /// Menyimpan Produk Pertanian ke Cloud Firestore ('produk_tani')
  static Future<void> syncProductToFirestore(Map<String, dynamic> productData) async {
    await initializeFirebase();
    try {
      await firestore
          .collection('produk_tani')
          .doc(productData['id'] as String)
          .set(productData, SetOptions(merge: true));
      debugPrint('Cloud Firestore: Product synced (${productData['id']})');
    } catch (e) {
      debugPrint('Firestore sync product notice: $e');
    }
  }

  /// Otomatis membuat koleksi & data awal di Cloud Firestore agar Konsol tidak kosong
  static Future<void> seedInitialFirestoreCollections() async {
    try {
      // 1. Koleksi 'users'
      await firestore.collection('users').doc('petani_sampel').set({
        'uid': 'petani_sampel',
        'name': 'Budi Santoso',
        'email': 'budi.santoso@taniyuk.id',
        'phone': '081234567890',
        'role': 'Petani Tomat & Padi',
        'location': 'Surabaya, Jawa Timur',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Koleksi 'ruang_tani'
      await firestore.collection('ruang_tani').doc('post_sampel').set({
        'id': 'post_sampel',
        'userName': 'Budi Santoso',
        'userLocation': 'Surabaya',
        'postText': 'Selamat datang di Ruang Tani TaniYuk! Mari berbagi tips & pengalaman pertanian.',
        'category': 'Diskusi',
        'likeCount': 12,
        'commentCount': 3,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Koleksi 'lahan'
      await firestore.collection('lahan').doc('lahan_sampel').set({
        'id': 'lahan_sampel',
        'title': 'Lahan Padi Subur',
        'location': 'Surabaya, Jawa Timur',
        'areaSize': '2.5 Hektar',
        'cropType': 'Padi Ciherang',
        'status': 'Siap Panen',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 4. Koleksi 'transaksi_keuangan'
      await firestore.collection('transaksi_keuangan').doc('tx_sampel').set({
        'id': 'tx_sampel',
        'title': 'Penjualan Panen Padi',
        'amount': 6750000.0,
        'category': 'Penjualan Panen',
        'isIncome': true,
        'date': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 5. Koleksi 'produk_tani'
      await firestore.collection('produk_tani').doc('produk_sampel').set({
        'id': 'produk_sampel',
        'name': 'Tomat Merah Segar Organik',
        'price': 12000.0,
        'unit': 'kg',
        'category': 'Hasil Panen',
        'seller': 'Budi Santoso',
        'phone': '081234567890',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Cloud Firestore: Initial collections seeded successfully.');
    } catch (e) {
      debugPrint('Firestore seed notice: $e');
    }
  }
}
