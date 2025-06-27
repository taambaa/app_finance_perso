import 'package:flutter/material.dart';
import 'package:app_finance_perso/models/expense.dart';
import 'package:app_finance_perso/services/firestore_service.dart';

class ListExpensePage extends StatelessWidget {
  const ListExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des dépenses'),
      ),
      body: StreamBuilder<List<Expense>>(
        stream: firestoreService.getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune dépense enregistrée.'));
          }
          final expenses = snapshot.data!;
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(expense.label),
                  subtitle: Text(expense.expenseDate.toLocal().toString().split(' ')[0]),
                  trailing: Text(
                    '-${expense.amount.toStringAsFixed(2)} €',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    // TODO: Naviguer vers EditExpensePage
                  },
                  onLongPress: () async {
                    // Suppression avec confirmation
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Supprimer cette dépense ?'),
                        content: const Text('Cette action est irréversible.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await firestoreService.deleteExpense(expense.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dépense supprimée.')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 