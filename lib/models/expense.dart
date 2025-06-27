import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String label;
  final double amount;
  final DateTime expenseDate;
  final String? description;

  Expense({
    required this.id,
    required this.label,
    required this.amount,
    required this.expenseDate,
    this.description,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      label: data['label'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      expenseDate: (data['income_date'] as Timestamp).toDate(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'amount': amount,
      'income_date': Timestamp.fromDate(expenseDate),
      'description': description,
    };
  }
} 