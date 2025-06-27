import 'package:flutter/material.dart';
import 'package:app_finance_perso/models/income.dart';
import 'package:app_finance_perso/services/firestore_service.dart';

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
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun revenu enregistré.'));
          }
          final incomes = snapshot.data!;
          return ListView.builder(
            itemCount: incomes.length,
            itemBuilder: (context, index) {
              final income = incomes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(income.label),
                  subtitle: Text(income.incomeDate.toLocal().toString().split(' ')[0]),
                  trailing: Text(
                    '+${income.amount.toStringAsFixed(2)} €',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    // TODO: Naviguer vers EditIncomePage
                  },
                  onLongPress: () async {
                    // Suppression avec confirmation
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Supprimer ce revenu ?'),
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
                      await firestoreService.deleteIncome(income.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Revenu supprimé.')),
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