// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_finance_perso/firebase_options.dart'; // <--- N'oubliez pas cette ligne !
import 'package:app_finance_perso/screens/auth/auth_check.dart'; // <--- Sera créé dans l'étape suivante

void main() async {
  // Assure que les bindings Flutter sont initialisés avant d'appeler des méthodes natives
  // Ceci est crucial pour que Firebase.initializeApp() fonctionne.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase en utilisant les options générées par FlutterFire CLI.
  // Ces options contiennent toutes les clés et configurations pour chaque plateforme.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lance l'application Flutter.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Finances Personnelles', 
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Adapte la densité visuelle à la plateforme (Android/iOS/Web).
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Le point d'entrée de l'application sera la page AuthCheck.
      // Cette page décidera si l'utilisateur doit voir l'écran de connexion ou le tableau de bord.
      home: const AuthCheck(), 
    );
  }
}