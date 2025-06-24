// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream pour écouter les changements d'état de l'utilisateur (connecté/déconnecté)
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Méthode pour l'inscription d'un nouvel utilisateur avec email et mot de passe
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user; // Retourne l'utilisateur créé
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs spécifiques de Firebase Authentication
      print('Erreur lors de l\'inscription: ${e.message}');
      // Vous pouvez renvoyer un message d'erreur plus convivial ici
      return null;
    } catch (e) {
      print('Erreur inattendue lors de l\'inscription: $e');
      return null;
    }
  }

  // Méthode pour la connexion d'un utilisateur existant avec email et mot de passe
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user; // Retourne l'utilisateur connecté
    } on FirebaseAuthException catch (e) {
      print('Erreur lors de la connexion: ${e.message}');
      return null;
    } catch (e) {
      print('Erreur inattendue lors de la connexion: $e');
      return null;
    }
  }

  // Méthode pour déconnecter l'utilisateur actuel
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      return null; // ou throw e; si vous voulez propager l'erreur
    }
  }
}