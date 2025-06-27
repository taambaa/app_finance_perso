// lib/screens/add_transaction_page.dart

import 'package:flutter/material.dart';
import 'package:app_finance_perso/models/transaction.dart' as app_transaction;
import 'package:app_finance_perso/services/firestore_service.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _selectedType = 'expense'; // Type par défaut
  DateTime _selectedDate = DateTime.now(); // Date par défaut

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Déclenche onSaved pour tous les champs du formulaire

      try {
        final double amount = double.parse(_amountController.text);

        // Crée un objet Transaction sans ID (Firestore en générera un)
        final newTransaction = app_transaction.Transaction(
          id: '', // ID temporaire, sera ignoré par Firestore .add()
          userId: '', // L'UID de l'utilisateur sera ajouté par le service Firestore
          description: _descriptionController.text,
          amount: amount,
          date: _selectedDate,
          type: _selectedType,
        );

        // Utilise la méthode appropriée selon le type
        if (_selectedType == 'income') {
          // TODO: Créer une méthode addIncome dans FirestoreService
          // await _firestoreService.addIncome(newTransaction);
        } else {
          // TODO: Créer une méthode addExpense dans FirestoreService
          // await _firestoreService.addExpense(newTransaction);
        }

        if (!mounted) return; // Vérifiez si le widget est toujours monté
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction ajoutée avec succès !')),
        );
        Navigator.of(context).pop(); // Retourne à la page précédente (Dashboard)
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Dépense'),
                      value: 'expense',
                      groupValue: _selectedType,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Revenu'),
                      value: 'income',
                      groupValue: _selectedType,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _addTransaction,
                child: const Text('Ajouter la transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}