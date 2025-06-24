// lib/screens/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Pour obtenir l'utilisateur actuel
import 'package:app_finance_perso/services/auth_service.dart'; // Pour la déconnexion
import 'package:app_finance_perso/services/firestore_service.dart'; // Importer le service Firestore
import 'package:app_finance_perso/models/transaction.dart' as app_transaction; // Importer le modèle de transaction
import 'package:app_finance_perso/screens/add_transaction_page.dart'; // Importer la page d'ajout de transaction

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenez l'utilisateur Firebase actuellement connecté
    final user = FirebaseAuth.instance.currentUser;
    final AuthService _authService = AuthService(); // Instancier le service d'authentification
    final FirestoreService _firestoreService = FirestoreService(); // Instancier le service Firestore

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord - Mes Finances'),
        actions: [
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut(); // Appelle la méthode de déconnexion
              // AuthCheck va automatiquement rediriger l'utilisateur vers LoginPage après la déconnexion
            },
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Column( // Utilisez Column pour organiser les éléments verticalement
        children: [
          // Section de bienvenue à l'utilisateur
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              user != null ? 'Bienvenue, ${user.email} !' : 'Bienvenue !',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Liste des transactions affichées en temps réel
          Expanded( // Expanded permet à la liste de prendre tout l'espace disponible restant
            child: StreamBuilder<List<app_transaction.Transaction>>(
              stream: _firestoreService.getTransactions(), // Écoute le flux de transactions de l'utilisateur
              builder: (context, snapshot) {
                // Si l'application est en attente des données
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // S'il y a une erreur lors du chargement des données
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                // S'il n'y a pas de données ou que la liste est vide
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucune transaction enregistrée.'));
                }

                // Affiche la liste des transactions si des données sont disponibles
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final transaction = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        // Icône indiquant si c'est un revenu ou une dépense
                        leading: Icon(
                          transaction.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                          color: transaction.type == 'income' ? Colors.green : Colors.red,
                        ),
                        // Description de la transaction
                        title: Text(transaction.description),
                        // Date de la transaction (format local, juste la date)
                        subtitle: Text(transaction.date.toLocal().toString().split(' ')[0]),
                        // Montant de la transaction avec signe et couleur appropriés
                        trailing: Text(
                          '${transaction.type == 'expense' ? '-' : '+'}${transaction.amount.toStringAsFixed(2)} €',
                          style: TextStyle(
                            color: transaction.type == 'income' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          // TODO: Option future pour modifier/supprimer une transaction
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Détails de: ${transaction.description}')),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Bouton flottant pour ajouter une nouvelle transaction
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigue vers la page d'ajout de transaction
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionPage(),
            ),
          );
        },
        child: const Icon(Icons.add), // Icône "+"
      ),
    );
  }
}