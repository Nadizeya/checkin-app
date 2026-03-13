import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCvpHIBbKYNmkr72CI4SI3dP60sC0GIG_k',
    appId: '1:917787443553:web:d468dfa3c5f8ee700cc520',
    messagingSenderId: '917787443553',
    projectId: 'smartcheck-in-7e73b',
    authDomain: 'smartcheck-in-7e73b.firebaseapp.com',
    storageBucket: 'smartcheck-in-7e73b.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBDVH9huDYsn5ApvBeSCdPg0FjZR5v-wQE',
    appId: '1:917787443553:android:1fdc46e9d956f0390cc520',
    messagingSenderId: '917787443553',
    projectId: 'smartcheck-in-7e73b',
    storageBucket: 'smartcheck-in-7e73b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBDVH9huDYsn5ApvBeSCdPg0FjZR5v-wQE',
    appId: '1:917787443553:ios:1fdc46e9d956f0390cc520',
    messagingSenderId: '917787443553',
    projectId: 'smartcheck-in-7e73b',
    storageBucket: 'smartcheck-in-7e73b.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBDVH9huDYsn5ApvBeSCdPg0FjZR5v-wQE',
    appId: '1:917787443553:macos:1fdc46e9d956f0390cc520',
    messagingSenderId: '917787443553',
    projectId: 'smartcheck-in-7e73b',
    storageBucket: 'smartcheck-in-7e73b.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBDVH9huDYsn5ApvBeSCdPg0FjZR5v-wQE',
    appId: '1:917787443553:windows:1fdc46e9d956f0390cc520',
    messagingSenderId: '917787443553',
    projectId: 'smartcheck-in-7e73b',
    storageBucket: 'smartcheck-in-7e73b.firebasestorage.app',
  );
}