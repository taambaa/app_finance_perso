import 'package:flutter/material.dart';
import 'package:app_finance_perso/models/expense.dart';
import 'package:app_finance_perso/services/firestore_service.dart';

class EditExpensePage extends StatefulWidget {
  final Expense expense;
  const EditExpensePage({super.key, required this.expense});

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.expense.label);
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _descriptionController = TextEditingController(text: widget.expense.description ?? '');
    _selectedDate = widget.expense.expenseDate;
  }

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

  Future<void> _updateExpense() async {
    if (_formKey.currentState!.validate()) {
      try {
        final double amount = double.parse(_amountController.text);
        final updatedExpense = Expense(
          id: widget.expense.id,
          label: _labelController.text,
          amount: amount,
          expenseDate: _selectedDate,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        );
        await _firestoreService.updateExpense(updatedExpense);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dépense modifiée avec succès !'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la modification: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteExpense() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette dépense ?'),
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
      await _firestoreService.deleteExpense(widget.expense.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dépense supprimée.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la dépense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteExpense,
            tooltip: 'Supprimer',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la dépense',
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
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (facultatif)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _updateExpense,
                child: const Text('Enregistrer les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 