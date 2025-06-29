import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_finance_perso/models/expense.dart';
import 'package:app_finance_perso/models/income.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtenir l'ID de l'utilisateur actuel
  String? get _currentUserId => _auth.currentUser?.uid;

  // Collection pour les dépenses
  CollectionReference<Map<String, dynamic>> get _expensesCollection =>
      _firestore.collection('users').doc(_currentUserId).collection('expenses');

  // Collection pour les revenus
  CollectionReference<Map<String, dynamic>> get _incomesCollection =>
      _firestore.collection('users').doc(_currentUserId).collection('incomes');

  // ===== OPÉRATIONS SUR LES DÉPENSES =====

  // Ajouter une dépense
  Future<void> addExpense(Expense expense) async {
    if (_currentUserId == null) throw Exception('Utilisateur non connecté');
    
    await _expensesCollection.add(expense.toFirestore());
  }

  // Obtenir toutes les dépenses
  Stream<List<Expense>> getExpenses() {
    if (_currentUserId == null) return Stream.value([]);
    
    return _expensesCollection
        .orderBy('income_date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromFirestore(doc))
            .toList());
  }

  // Obtenir une dépense par ID
  Future<Expense?> getExpense(String id) async {
    if (_currentUserId == null) return null;
    
    final doc = await _expensesCollection.doc(id).get();
    if (doc.exists) {
      return Expense.fromFirestore(doc);
    }
    return null;
  }

  // Mettre à jour une dépense
  Future<void> updateExpense(Expense expense) async {
    if (_currentUserId == null) throw Exception('Utilisateur non connecté');
    
    await _expensesCollection.doc(expense.id).update(expense.toFirestore());
  }

  // Supprimer une dépense
  Future<void> deleteExpense(String id) async {
    if (_currentUserId == null) throw Exception('Utilisateur non connecté');
    
    await _expensesCollection.doc(id).delete();
  }

  // ===== OPÉRATIONS SUR LES REVENUS =====

  // Ajouter un revenu
  Future<void> addIncome(Income income) async {
    if (_currentUserId == null) throw Exception('Utilisateur non connecté');
    
    await _incomesCollection.add(income.toFirestore());
  }

  // Obtenir tous les revenus
  Stream<List<Income>> getIncomes() {
    if (_currentUserId == null) return Stream.value([]);
    
    return _incomesCollection
        .orderBy('income_date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Income.fromFirestore(doc))
            .toList());
  }

  // Obtenir un revenu par ID
  Future<Income?> getIncome(String id) async {
    if (_currentUserId == null) return null;
    
    final doc = await _incomesCollection.doc(id).get();
    if (doc.exists) {
      return Income.fromFirestore(doc);
    }
    return null;
  }

  // Mettre à jour un revenu
  Future<void> updateIncome(Income income) async {
    if (_currentUserId == null) throw Exception('Utilisateur non connecté');
    
    await _incomesCollection.doc(income.id).update(income.toFirestore());
  }

  // Supprimer un revenu
  Future<void> deleteIncome(String id) async {
    if (_currentUserId == null) throw Exception('Utilisateur non connecté');
    
    await _incomesCollection.doc(id).delete();
  }

  // ===== STATISTIQUES ET CALCULS =====

  // Obtenir le total des dépenses pour une période
  Stream<double> getTotalExpenses({DateTime? startDate, DateTime? endDate}) {
    if (_currentUserId == null) return Stream.value(0.0);
    
    Query query = _expensesCollection;
    
    if (startDate != null) {
      query = query.where('income_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('income_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Expense.fromFirestore(doc))
        .fold(0.0, (sum, expense) => sum + expense.amount));
  }

  // Obtenir le total des revenus pour une période
  Stream<double> getTotalIncomes({DateTime? startDate, DateTime? endDate}) {
    if (_currentUserId == null) return Stream.value(0.0);
    
    Query query = _incomesCollection;
    
    if (startDate != null) {
      query = query.where('income_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('income_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Income.fromFirestore(doc))
        .fold(0.0, (sum, income) => sum + income.amount));
  }

  // Obtenir le solde (revenus - dépenses) - Version corrigée
  Stream<double> getBalance() {
    if (_currentUserId == null) return Stream.value(0.0);
    
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .snapshots()
        .asyncMap((_) async {
          final incomesSnapshot = await _incomesCollection.get();
          final expensesSnapshot = await _expensesCollection.get();
          
          final totalIncome = incomesSnapshot.docs
              .map((doc) => Income.fromFirestore(doc))
              .fold(0.0, (sum, income) => sum + income.amount);
              
          final totalExpense = expensesSnapshot.docs
              .map((doc) => Expense.fromFirestore(doc))
              .fold(0.0, (sum, expense) => sum + expense.amount);
              
          return totalIncome - totalExpense;
        });
  }

  // ===== RECHERCHE ET FILTRES =====

  // Rechercher des dépenses par label
  Stream<List<Expense>> searchExpenses(String query) {
    if (_currentUserId == null) return Stream.value([]);
    
    return _expensesCollection
        .orderBy('income_date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromFirestore(doc))
            .where((expense) => 
                expense.label.toLowerCase().contains(query.toLowerCase()) ||
                (expense.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList());
  }

  // Rechercher des revenus par label
  Stream<List<Income>> searchIncomes(String query) {
    if (_currentUserId == null) return Stream.value([]);
    
    return _incomesCollection
        .orderBy('income_date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Income.fromFirestore(doc))
            .where((income) => 
                income.label.toLowerCase().contains(query.toLowerCase()) ||
                (income.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList());
  }
} 