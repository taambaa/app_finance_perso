import 'package:flutter/material.dart';
import 'package:app_finance_perso/models/income.dart';
import 'package:app_finance_perso/services/firestore_service.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
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

  Future<void> _addIncome() async {
    if (_formKey.currentState!.validate()) {
      try {
        final double amount = double.parse(_amountController.text);
        final newIncome = Income(
          id: '',
          label: _labelController.text,
          amount: amount,
          incomeDate: _selectedDate,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        );
        await _firestoreService.addIncome(newIncome);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Revenu ajouté avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un revenu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Champ Label
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Nom du revenu',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Champ Montant
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  prefixIcon: Icon(Icons.euro),
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
                  if (double.parse(value) <= 0) {
                    return 'Le montant doit être positif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Sélecteur de date
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 20),

              // Champ Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (facultatif)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // Bouton d'ajout
              ElevatedButton.icon(
                onPressed: _addIncome,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter le revenu'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 