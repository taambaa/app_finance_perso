// lib/screens/auth/auth_check.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_finance_perso/screens/auth/login_page.dart';    // <--- Importe la page de connexion
import 'package:app_finance_perso/screens/auth/register_page.dart'; // <--- Importe la page d'inscription

// TODO: Importer la DashboardPage quand elle sera créée
// import 'package:app_finance_perso/screens/dashboard_page.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  // Cette variable d'état contrôle quelle page est affichée (connexion ou inscription)
  bool showLoginPage = true;

  // Fonction pour basculer entre la page de connexion et d'inscription
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage; // Inverse la valeur de showLoginPage
    });
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder écoute les changements d'état d'authentification de Firebase
    // (par exemple, un utilisateur se connecte, se déconnecte, s'inscrit).
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Le flux d'état de l'authentification Firebase
      builder: (context, snapshot) {
        // État 1: L'application est en attente de la réponse de Firebase (premier démarrage ou rechargement)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Affiche un indicateur de chargement
            ),
          );
        }

        // État 2: Un utilisateur est actuellement connecté
        if (snapshot.hasData) {
          // Si snapshot.hasData est vrai, cela signifie qu'un objet User est disponible.
          // TODO: Remplacer ce Scaffold temporaire par votre DashboardPage réelle
          return Scaffold(
            appBar: AppBar(title: const Text("Tableau de bord (connecté)")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Affiche l'email de l'utilisateur connecté
                  Text('Connecté en tant que: ${snapshot.data!.email}'),
                  const SizedBox(height: 20),
                  // Bouton de déconnexion pour tester
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut(); // Appelle la méthode de déconnexion de Firebase
                    },
                    child: const Text('Déconnexion'),
                  ),
                ],
              ),
            ),
          );
        }

        // État 3: Aucun utilisateur n'est connecté
        else {
          // Si showLoginPage est vrai, affiche la page de connexion
          if (showLoginPage) {
            // Passe la fonction togglePages à LoginPage pour permettre le basculement vers RegisterPage
            return LoginPage(onRegisterTap: togglePages);
          }
          // Sinon (si showLoginPage est faux), affiche la page d'inscription
          else {
            // Passe la fonction togglePages à RegisterPage pour permettre le basculement vers LoginPage
            return RegisterPage(onSignInTap: togglePages);
          }
        }
      },
    );
  }
}