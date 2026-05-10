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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAM7lspLQ45LxCTyC11Zcj31ui_dfpW58U',
    appId: '1:680078149532:web:9f9e33937a5d4ae635ea59',
    messagingSenderId: '680078149532',
    projectId: 'pechetech-app-mg4',
    authDomain: 'pechetech-app-mg4.firebaseapp.com',
    storageBucket: 'pechetech-app-mg4.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3mRtErfQVoeqn9p0MaUyCRlBlLBJMs90',
    appId: '1:680078149532:android:eca6f23d8ee2479835ea59',
    messagingSenderId: '680078149532',
    projectId: 'pechetech-app-mg4',
    storageBucket: 'pechetech-app-mg4.firebasestorage.app',
  );
}
