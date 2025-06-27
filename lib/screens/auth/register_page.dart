import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final VoidCallback onSignInTap;
  const RegisterPage({Key? key, required this.onSignInTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Register Page'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSignInTap,
              child: const Text('Déjà inscrit ? Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
} 