import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool isInitialized = false;

  /// Inisialisasi SDK Firebase Core
  static Future<void> initializeFirebase() async {
    if (isInitialized) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      isInitialized = true;
      debugPrint('Firebase Core initialized successfully.');
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
  }) async {
    await initializeFirebase();
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Firebase Auth Login Error: $e');
      rethrow;
    }
  }

  static Future<void> logout() async {
    await auth.signOut();
  }

  // --- CLOUD FIRESTORE DATABASE ---
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Menyimpan Data Lahan ke Cloud Firestore
  static Future<void> syncLandToFirestore(Map<String, dynamic> landData) async {
    await initializeFirebase();
    try {
      await firestore
          .collection('lahan')
          .doc(landData['id'] as String)
          .set(landData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore sync land notice: $e');
    }
  }

  /// Menyimpan Catatan Transaksi Keuangan ke Cloud Firestore
  static Future<void> syncTransactionToFirestore(Map<String, dynamic> txData) async {
    await initializeFirebase();
    try {
      await firestore
          .collection('transaksi_keuangan')
          .doc(txData['id'] as String)
          .set(txData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore sync tx notice: $e');
    }
  }

  /// Menyimpan Produk Pertanian ke Cloud Firestore
  static Future<void> syncProductToFirestore(Map<String, dynamic> productData) async {
    await initializeFirebase();
    try {
      await firestore
          .collection('produk_tani')
          .doc(productData['id'] as String)
          .set(productData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore sync product notice: $e');
    }
  }
}
