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
      default:
        throw UnsupportedError('Platform ini tidak didukung oleh Firebase');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDGQvZr7S-g2EAjOUspG_Ag22uZqT2qIwg',
    appId: '1:772617776826:android:7a69eeb9e1e8f416621c83',
    messagingSenderId: '772617776826',
    projectId: 'flutter-project-7ffab',
    storageBucket: 'flutter-project-7ffab.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_IOS_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCIq35h6CncUNW0TTqCtje0obc07y5G4Z0",
    authDomain: "flutter-project-7ffab.firebaseapp.com",
    projectId: "flutter-project-7ffab",
    storageBucket: "flutter-project-7ffab.firebasestorage.app",
    messagingSenderId: "772617776826",
    appId: "1:772617776826:web:4555255b89bb419f621c83",
    measurementId: "G-P3VR5MH4FY",
  );
}
