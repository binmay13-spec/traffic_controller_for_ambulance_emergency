import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for each platform.
///
/// For Android and iOS, run `flutterfire configure --project=tcma-9cb49`
/// to auto-generate the correct values.
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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBLGDgL90oGNF9HBddvRe7fOGLaZ6koQuM',
    appId: '1:407007548695:web:9055871435d14598805352',
    messagingSenderId: '407007548695',
    projectId: 'tcma-9cb49',
    authDomain: 'tcma-9cb49.firebaseapp.com',
    storageBucket: 'tcma-9cb49.firebasestorage.app',
    measurementId: 'G-G31XB9PSXP',
  );

  /// TODO: Replace with actual Android values from `flutterfire configure`
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBLGDgL90oGNF9HBddvRe7fOGLaZ6koQuM',
    appId: '1:407007548695:web:9055871435d14598805352',
    messagingSenderId: '407007548695',
    projectId: 'tcma-9cb49',
    storageBucket: 'tcma-9cb49.firebasestorage.app',
  );

  /// TODO: Replace with actual iOS values from `flutterfire configure`
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBLGDgL90oGNF9HBddvRe7fOGLaZ6koQuM',
    appId: '1:407007548695:web:9055871435d14598805352',
    messagingSenderId: '407007548695',
    projectId: 'tcma-9cb49',
    storageBucket: 'tcma-9cb49.firebasestorage.app',
    iosBundleId: 'com.example.ambulanceApp',
  );
}
