import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  
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
    RecaptchaVerifier? webVerifier, // Added for Web support
  }) async {
    if (kIsWeb) {
      try {
        // On Web, we use signInWithPhoneNumber which returns a ConfirmationResult
        // If webVerifier is null, it uses an invisible one by default
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
      final GoogleSignInAccount user = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = user.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (_) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      // Try to sign out from Google if possible, but don't let it block Firebase sign out
      await _googleSignIn.signOut().timeout(const Duration(seconds: 2)).catchError((_) => null);
    } catch (_) {}
    
    try {
      await _auth.signOut();
    } catch (_) {
      rethrow;
    }
    _webConfirmationResult = null;
  }
}
