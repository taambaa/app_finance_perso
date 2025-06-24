// lib/models/transaction.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String userId; // L'ID de l'utilisateur qui a fait la transaction
  final String description;
  final double amount;
  final DateTime date;
  final String type; // 'income' (revenu) ou 'expense' (dépense)

  Transaction({
    required this.id,
    required this.userId,
    required this.description,
    required this.isDebit,
    required this.amount,
    required this.date,
    required this.type,
  });

  // Constructeur pour créer un objet Transaction à partir d'un document Firestore
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(), // Conversion Timestamp vers DateTime
      type: data['type'] ?? 'expense',
    );
  }

  // Méthode pour convertir l'objet Transaction en un Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date), // Conversion DateTime vers Timestamp
      'type': type,
    };
  }
}