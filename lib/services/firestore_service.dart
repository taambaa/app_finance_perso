// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_finance_perso/models/transaction.dart' as app_transaction; // Alias pour éviter conflit de nom

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer toutes les transactions pour l'utilisateur actuellement connecté
  Stream<List<app_transaction.Transaction>> getTransactions() {
    User? user = _auth.currentUser; // Obtenir l'utilisateur actuel

    if (user == null) {
      // Si aucun utilisateur n'est connecté, retourner un stream vide
      return Stream.value([]);
    }

    // Écouter les changements dans la collection 'transactions'
    // Filtrer par 'userId' pour n'obtenir que les transactions de l'utilisateur connecté
    // Ordonner par date (du plus récent au plus ancien)
    return _db.collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => app_transaction.Transaction.fromFirestore(doc))
            .toList());
  }

  // Ajouter une nouvelle transaction
  Future<void> addTransaction(app_transaction.Transaction transaction) async {
    if (_auth.currentUser == null) {
      print('Erreur: Aucun utilisateur connecté pour ajouter une transaction.');
      return;
    }
    await _db.collection('transactions').add(transaction.toFirestore());
  }

  // Mettre à jour une transaction existante
  Future<void> updateTransaction(app_transaction.Transaction transaction) async {
    if (_auth.currentUser == null) {
      print('Erreur: Aucun utilisateur connecté pour mettre à jour une transaction.');
      return;
    }
    await _db.collection('transactions').doc(transaction.id).update(transaction.toFirestore());
  }

  // Supprimer une transaction
  Future<void> deleteTransaction(String transactionId) async {
    if (_auth.currentUser == null) {
      print('Erreur: Aucun utilisateur connecté pour supprimer une transaction.');
      return;
    }
    await _db.collection('transactions').doc(transactionId).delete();
  }
}