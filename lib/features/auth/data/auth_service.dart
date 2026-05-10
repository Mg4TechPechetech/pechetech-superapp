import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    if (!kIsWeb) {
      _googleSignIn = GoogleSignIn.instance;
    }
  }

  Future<void> init() async {
    if (!kIsWeb) {
      await _googleSignIn.initialize();
    }
  }

  // To store the result on Web
  ConfirmationResult? _webConfirmationResult;

  // Email & Password Registration
  Future<UserCredential?> registerWithEmail(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      throw Exception('Une erreur inattendue est survenue.');
    }
  }

  // Email & Password Login
  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      throw Exception('Une erreur inattendue est survenue.');
    }
  }

  // Phone Authentication: Verify Phone Number (Cross-platform)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
    dynamic webVerifier, // Using dynamic to avoid conditional import issues for now
  }) async {
    if (kIsWeb) {
      try {
        // On Web, we use signInWithPhoneNumber which returns a ConfirmationResult
        _webConfirmationResult = await _auth.signInWithPhoneNumber(
          phoneNumber,
          webVerifier,
        );
        // We simulate the codeSent callback for compatibility with our UI logic
        codeSent(_webConfirmationResult!.verificationId, null);
      } on FirebaseAuthException catch (e) {
        verificationFailed(e);
      }
    } else {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    }
  }

  // Phone Authentication: Sign In with Credential or SMS Code
  Future<UserCredential?> signInWithPhone(
      {String? smsCode, PhoneAuthCredential? credential}) async {
    try {
      if (kIsWeb && _webConfirmationResult != null && smsCode != null) {
        return await _webConfirmationResult!.confirm(smsCode);
      } else if (credential != null) {
        return await _auth.signInWithCredential(credential);
      }
      return null;
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      throw Exception('Une erreur inattendue est survenue.');
    }
  }

  // Legacy for backward compatibility in existing code
  Future<UserCredential?> signInWithPhoneCredential(
      PhoneAuthCredential credential) async {
    return signInWithPhone(credential: credential);
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        final googleUser = await _googleSignIn.authenticate();
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: null,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint('AuthService: Google Sign-In error: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    debugPrint('AuthService: Starting signOut process...');
    try {
      // Only attempt Google signOut if we're on mobile or if there's an active session
      // On Web, this can sometimes hang if not used
      if (!kIsWeb) {
        await _googleSignIn.signOut();
        debugPrint('AuthService: Google Sign-In signed out.');
      }
    } catch (e) {
      debugPrint('AuthService: Google Sign-In signOut error (ignored): $e');
    }

    try {
      await _auth.signOut();
      debugPrint('AuthService: Firebase Auth signed out.');
    } catch (e) {
      debugPrint('AuthService: Firebase Auth signOut error: $e');
      rethrow;
    }
    _webConfirmationResult = null;
    debugPrint('AuthService: signOut process completed.');
  }
}
