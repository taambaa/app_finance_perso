// lib/screens/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Pour obtenir l'utilisateur actuel
import 'package:app_finance_perso/services/auth_service.dart'; // Pour la déconnexion
import 'package:app_finance_perso/services/firestore_service.dart'; // Importer le service Firestore
// Importer le modèle de transaction
// Importer la page d'ajout de transaction
import 'package:app_finance_perso/models/income.dart';
import 'package:app_finance_perso/models/expense.dart';
import 'income/add_income_page.dart';
import 'income/list_income_page.dart';
import 'expense/add_expense_page.dart';
import 'expense/list_expense_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenez l'utilisateur Firebase actuellement connecté
    final user = FirebaseAuth.instance.currentUser;
    final AuthService authService = AuthService(); // Instancier le service d'authentification
    final FirestoreService firestoreService = FirestoreService(); // Instancier le service Firestore

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut(); // Appelle la méthode de déconnexion
              // AuthCheck va automatiquement rediriger l'utilisateur vers LoginPage après la déconnexion
            },
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Solde et totaux
            StreamBuilder<List<Income>>(
              stream: firestoreService.getIncomes(),
              builder: (context, incomeSnapshot) {
                return StreamBuilder<List<Expense>>(
                  stream: firestoreService.getExpenses(),
                  builder: (context, expenseSnapshot) {
                    final incomes = incomeSnapshot.data ?? [];
                    final expenses = expenseSnapshot.data ?? [];
                    final totalIncome = incomes.fold<double>(0, (sum, i) => sum + i.amount);
                    final totalExpense = expenses.fold<double>(0, (sum, e) => sum + e.amount);
                    final balance = totalIncome - totalExpense;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
                        Card(
                          color: Colors.blue[50],
                          child: Padding(
            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text('Solde actuel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('${balance.toStringAsFixed(2)} €', style: TextStyle(fontSize: 32, color: balance >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        const Text('Revenus', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text('+${totalIncome.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.green)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Text('Dépenses', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text('-${totalExpense.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Accès rapides
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter revenu'),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const AddIncomePage()),
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter dépense'),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const AddExpensePage()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.list),
                              label: const Text('Voir revenus'),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const ListIncomePage()),
                              ),
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.list),
                              label: const Text('Voir dépenses'),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const ListExpensePage()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
          ),
        ],
      ),
      ),
    );
  }
}