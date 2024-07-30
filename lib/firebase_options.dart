// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyC3G5cFCJqBcCov7UyRzevUORiww5qiUq4',
    appId: '1:757551575021:web:181d5ef40abcd25b1281e4',
    messagingSenderId: '757551575021',
    projectId: 'test-3fa24',
    authDomain: 'test-3fa24.firebaseapp.com',
    storageBucket: 'test-3fa24.appspot.com',
    measurementId: 'G-0PG5MRF8WB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAu6eWt_t7tNM9WkuSuy8VR46kOgApfaHw',
    appId: '1:757551575021:android:272fa375d8f668ea1281e4',
    messagingSenderId: '757551575021',
    projectId: 'test-3fa24',
    storageBucket: 'test-3fa24.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCf-peDkN4nXXLXr696N7giCnceZe9Tfo',
    appId: '1:757551575021:ios:99840d5b4cf79ee41281e4',
    messagingSenderId: '757551575021',
    projectId: 'test-3fa24',
    storageBucket: 'test-3fa24.appspot.com',
    androidClientId: '757551575021-2q6mhqemrbd74npnj9976g3ntfuh4n1a.apps.googleusercontent.com',
    iosClientId: '757551575021-b700kbmd3u3babbe6cro6rqc80p84r99.apps.googleusercontent.com',
    iosBundleId: 'com.example.uploadPage',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCCf-peDkN4nXXLXr696N7giCnceZe9Tfo',
    appId: '1:757551575021:ios:99840d5b4cf79ee41281e4',
    messagingSenderId: '757551575021',
    projectId: 'test-3fa24',
    storageBucket: 'test-3fa24.appspot.com',
    androidClientId: '757551575021-2q6mhqemrbd74npnj9976g3ntfuh4n1a.apps.googleusercontent.com',
    iosClientId: '757551575021-b700kbmd3u3babbe6cro6rqc80p84r99.apps.googleusercontent.com',
    iosBundleId: 'com.example.uploadPage',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC3G5cFCJqBcCov7UyRzevUORiww5qiUq4',
    appId: '1:757551575021:web:181d5ef40abcd25b1281e4',
    messagingSenderId: '757551575021',
    projectId: 'test-3fa24',
    authDomain: 'test-3fa24.firebaseapp.com',
    storageBucket: 'test-3fa24.appspot.com',
    measurementId: 'G-0PG5MRF8WB',
  );

}