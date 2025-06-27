import 'package:cloud_firestore/cloud_firestore.dart';

class Income {
  final String id;
  final String label;
  final double amount;
  final DateTime incomeDate;
  final String? description;

  Income({
    required this.id,
    required this.label,
    required this.amount,
    required this.incomeDate,
    this.description,
  });

  factory Income.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Income(
      id: doc.id,
      label: data['label'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      incomeDate: (data['income_date'] as Timestamp).toDate(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'amount': amount,
      'income_date': Timestamp.fromDate(incomeDate),
      'description': description,
    };
  }
} 