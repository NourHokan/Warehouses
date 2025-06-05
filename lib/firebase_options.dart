// File generated for Firebase initialization in Flutter Web
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAmL5oPHyitGcUo9Jdf9cNYMY6Px1CxtN4',
    authDomain: 'medicine-warehouse-management.firebaseapp.com',
    projectId: 'medicine-warehouse-management',
    storageBucket: 'medicine-warehouse-management.appspot.com',
    messagingSenderId: '29827955575',
    appId: '1:29827955575:web:ae567c403b1d373a54ff72',
    measurementId: 'G-YKEG0BG558',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmL5oPHyitGcUo9Jdf9cNYMY6Px1CxtN4',
    appId: '1:29827955575:web:ae567c403b1d373a54ff72',
    messagingSenderId: '29827955575',
    projectId: 'medicine-warehouse-management',
    storageBucket: 'medicine-warehouse-management.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAmL5oPHyitGcUo9Jdf9cNYMY6Px1CxtN4',
    appId: '1:29827955575:web:ae567c403b1d373a54ff72',
    messagingSenderId: '29827955575',
    projectId: 'medicine-warehouse-management',
    storageBucket: 'medicine-warehouse-management.appspot.com',
    iosBundleId: 'com.example.warehouses',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAmL5oPHyitGcUo9Jdf9cNYMY6Px1CxtN4',
    appId: '1:29827955575:web:ae567c403b1d373a54ff72',
    messagingSenderId: '29827955575',
    projectId: 'medicine-warehouse-management',
    storageBucket: 'medicine-warehouse-management.appspot.com',
    iosBundleId: 'com.example.warehouses',
  );
}
