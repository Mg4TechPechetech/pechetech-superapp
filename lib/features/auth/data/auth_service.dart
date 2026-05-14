import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../profile/data/services/profile_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;
  final ProfileService _profileService = ProfileService();

  AuthService() {
    if (!kIsWeb) {
      _googleSignIn = GoogleSignIn.instance;
    }
  }

  Future<void> _ensureUserProfile(User user) async {
    final profile = await _profileService.getUserProfile(user.uid);
    if (profile == null) {
      await _profileService.createInitialProfile(
        uid: user.uid,
        fullName: user.displayName ?? 'Utilisateur',
        email: user.email ?? '',
        phoneNumber: user.phoneNumber ?? '',
        role: 'Pêcheur', // Default role
      );
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
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        await _ensureUserProfile(cred.user!);
      }
      return cred;
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
      UserCredential? cred;
      if (kIsWeb && _webConfirmationResult != null && smsCode != null) {
        cred = await _webConfirmationResult!.confirm(smsCode);
      } else if (credential != null) {
        cred = await _auth.signInWithCredential(credential);
      }
      
      if (cred != null && cred.user != null) {
        await _ensureUserProfile(cred.user!);
      }
      
      return cred;
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
      UserCredential? cred;
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        cred = await _auth.signInWithPopup(googleProvider);
      } else {
        final googleUser = await _googleSignIn.authenticate();
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        if (googleAuth.idToken == null) {
          throw Exception("Impossible de récupérer le jeton ID d'authentification.");
        }

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        cred = await _auth.signInWithCredential(credential);
      }
      
      if (cred.user != null) {
        await _ensureUserProfile(cred.user!);
      }
      
      return cred;
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

  // Change Password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception("Utilisateur non connecté ou email absent.");
    }

    try {
      // Re-authenticate
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      throw Exception('Une erreur est survenue lors de la modification du mot de passe.');
    }
  }
}
