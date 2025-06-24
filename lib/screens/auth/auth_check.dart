// lib/screens/auth/auth_check.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_finance_perso/screens/auth/login_page.dart';
import 'package:app_finance_perso/screens/auth/register_page.dart';
import 'package:app_finance_perso/screens/dashboard_page.dart'; // <--- CORRIGÉ : Cette ligne est essentielle



class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          // Si l'utilisateur est connecté, rediriger vers le tableau de bord
          return const DashboardPage(); // <--- Utilisez la page du tableau de bord ici
        } else {
          if (showLoginPage) {
            return LoginPage(onRegisterTap: togglePages);
          } else {
            return RegisterPage(onSignInTap: togglePages);
          }
        }
      },
    );
  }
}