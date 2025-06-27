import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final VoidCallback onRegisterTap;
  const LoginPage({Key? key, required this.onRegisterTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login Page'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRegisterTap,
              child: const Text('Pas de compte ? S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
} 