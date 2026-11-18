import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDcI_wP5WddNVwZ2UXiCfBayXcumciHOoM',
    appId: '1:401891419702:web:a9918237192837',
    messagingSenderId: '401891419702',
    projectId: 'taniyuk-dd4d2',
    authDomain: 'taniyuk-dd4d2.firebaseapp.com',
    storageBucket: 'taniyuk-dd4d2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDcI_wP5WddNVwZ2UXiCfBayXcumciHOoM',
    appId: '1:401891419702:android:cacdfbc5b145a6a84b5a97',
    messagingSenderId: '401891419702',
    projectId: 'taniyuk-dd4d2',
    storageBucket: 'taniyuk-dd4d2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDcI_wP5WddNVwZ2UXiCfBayXcumciHOoM',
    appId: '1:401891419702:ios:a9918237192837',
    messagingSenderId: '401891419702',
    projectId: 'taniyuk-dd4d2',
    storageBucket: 'taniyuk-dd4d2.firebasestorage.app',
    iosBundleId: 'com.TaniYuk',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDcI_wP5WddNVwZ2UXiCfBayXcumciHOoM',
    appId: '1:401891419702:ios:a9918237192837',
    messagingSenderId: '401891419702',
    projectId: 'taniyuk-dd4d2',
    storageBucket: 'taniyuk-dd4d2.firebasestorage.app',
    iosBundleId: 'com.TaniYuk',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDcI_wP5WddNVwZ2UXiCfBayXcumciHOoM',
    appId: '1:401891419702:web:a9918237192837',
    messagingSenderId: '401891419702',
    projectId: 'taniyuk-dd4d2',
    authDomain: 'taniyuk-dd4d2.firebaseapp.com',
    storageBucket: 'taniyuk-dd4d2.firebasestorage.app',
  );
}
