import 'package:flutter/material.dart';
import 'package:app_finance_perso/models/expense.dart';
import 'package:app_finance_perso/services/firestore_service.dart';
import 'edit_expense_page.dart';

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
          final expenses = snapshot.data ?? [];
          if (expenses.isEmpty) {
            return const Center(child: Text('Aucune dépense trouvée.'));
          }
          return ListView.separated(
            itemCount: expenses.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ListTile(
                title: Text(expense.label),
                subtitle: Text('${expense.amount.toStringAsFixed(2)} € - ${expense.expenseDate.toLocal().toString().split(' ')[0]}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditExpensePage(expense: expense),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmer la suppression'),
                            content: const Text('Voulez-vous vraiment supprimer cette dépense ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
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
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditExpensePage(expense: expense),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 