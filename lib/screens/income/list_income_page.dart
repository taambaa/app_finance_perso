import 'package:flutter/material.dart';
import 'package:app_finance_perso/models/income.dart';
import 'package:app_finance_perso/services/firestore_service.dart';
import 'edit_income_page.dart';

class ListIncomePage extends StatelessWidget {
  const ListIncomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des revenus'),
      ),
      body: StreamBuilder<List<Income>>(
        stream: firestoreService.getIncomes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final incomes = snapshot.data ?? [];
          if (incomes.isEmpty) {
            return const Center(child: Text('Aucun revenu trouvé.'));
          }
          return ListView.separated(
            itemCount: incomes.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final income = incomes[index];
              return ListTile(
                title: Text(income.label),
                subtitle: Text('${income.amount.toStringAsFixed(2)} € - ${income.incomeDate.toLocal().toString().split(' ')[0]}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditIncomePage(income: income),
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
                            content: const Text('Voulez-vous vraiment supprimer ce revenu ?'),
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
                          await firestoreService.deleteIncome(income.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Revenu supprimé.')),
                          );
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditIncomePage(income: income),
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