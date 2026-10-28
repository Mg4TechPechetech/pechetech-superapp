import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer le profil de l'utilisateur courant
  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return getUserProfile(user.uid);
  }

  // Stream du profil de l'utilisateur courant (pour mises à jour réelles)
  Stream<UserModel?> get currentUserProfileStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Récupérer un profil par UID
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération du profil: $e');
    }
    return null;
  }

  // Créer ou mettre à jour un profil
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(
        user.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du profil: $e');
      throw Exception('Impossible de sauvegarder le profil');
    }
  }

  // Créer un profil de base lors de l'inscription
  Future<void> createInitialProfile({
    required String uid,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String role,
  }) async {
    final newUser = UserModel(
      uid: uid,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      createdAt: DateTime.now(),
    );
    await saveUserProfile(newUser);
  }

  // Sauvegarder l'image de profil en Base64 dans Firestore (Alternative à Storage)
  Future<String> uploadProfileImage(String uid, Uint8List fileBytes) async {
    try {
      // Conversion en Base64
      final base64String = base64Encode(fileBytes);
      final dataUri = 'data:image/jpeg;base64,$base64String';
      
      // Mettre à jour le profil dans Firestore directement
      await _firestore.collection('users').doc(uid).update({'photoUrl': dataUri});
      
      return dataUri;
    } catch (e) {
      debugPrint('Erreur lors de l\'encodage Base64: $e');
      throw Exception('Impossible de sauvegarder l\'image dans Firestore');
    }
  }
}
