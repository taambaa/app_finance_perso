// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_finance_perso/models/income.dart';
import 'package:app_finance_perso/models/expense.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // INCOME
  Stream<List<Income>> getIncomes() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('income')
        .orderBy('income_date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Income.fromFirestore(doc)).toList());
  }

  Future<void> addIncome(Income income) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('income').add(income.toFirestore());
  }

  Future<void> updateIncome(Income income) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('income').doc(income.id).update(income.toFirestore());
  }

  Future<void> deleteIncome(String incomeId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('income').doc(incomeId).delete();
  }

  // EXPENSE
  Stream<List<Expense>> getExpenses() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('expense')
        .orderBy('income_date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  Future<void> addExpense(Expense expense) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('expense').add(expense.toFirestore());
  }

  Future<void> updateExpense(Expense expense) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('expense').doc(expense.id).update(expense.toFirestore());
  }

  Future<void> deleteExpense(String expenseId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('expense').doc(expenseId).delete();
  }
}