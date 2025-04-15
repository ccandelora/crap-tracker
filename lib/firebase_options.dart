import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// This is a placeholder class. You need to replace it with actual Firebase Options 
/// generated from the Firebase Console. 
/// 
/// To generate this file, run:
/// ```
/// flutterfire configure
/// ```
/// 
/// See: https://firebase.flutter.dev/docs/cli/
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Replace these placeholder values with your actual Firebase configuration
  // from the Firebase Console
  
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR-API-KEY',
    appId: 'YOUR-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    authDomain: 'YOUR-PROJECT-ID.firebaseapp.com',
    storageBucket: 'YOUR-PROJECT-ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAF2GZFAdSbDehtmdCllQwx5wCKulDmYJw',
    appId: '1:190629246870:ios:45ad3679b4698f910bcfb7',
    messagingSenderId: '190629246870',
    projectId: 'the-rail-5b4e7',
    storageBucket: 'the-rail-5b4e7.firebasestorage.app',
    iosBundleId: 'com.therailpro.crapstracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAF2GZFAdSbDehtmdCllQwx5wCKulDmYJw',
    appId: '1:190629246870:ios:45ad3679b4698f910bcfb7',
    messagingSenderId: '190629246870',
    projectId: 'the-rail-5b4e7',
    storageBucket: 'the-rail-5b4e7.firebasestorage.app',
    iosBundleId: 'com.therailapp.craptracker',
  );

} 
