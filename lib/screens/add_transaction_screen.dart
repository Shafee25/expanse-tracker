import 'package:my_expanse_tracker/database/hive_database.dart';
import 'package:my_expanse_tracker/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddTransactionScreen extends StatefulWidget {
  // We make this nullable. If it's null, we are ADDING.
  // If it's not null, we are EDITING.
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, required this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedCategory = 'Other';
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;
  late String _idToUpdate;

  @override
  void initState() {
    super.initState();
    // Check if we are in "Edit" mode
    if (widget.transaction != null) {
      _isEditing = true;
      final tx = widget.transaction!;

      // Pre-fill the form fields
      _idToUpdate = tx.id;
      _amountController.text = tx.amount.toString();
      _descriptionController.text = tx.description;
      _selectedType = tx.type;
      _selectedCategory = tx.category;
      _selectedDate = tx.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Date Picker
  Future<void> _pickDate(BuildContext context) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
      });
    }
  }

  // Save/Update logic
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final db = Provider.of<HiveDatabase>(context, listen: false);
      final amount = double.tryParse(_amountController.text);

      if (amount == null) return; // Should be caught by validator

      if (_isEditing) {
        // --- UPDATE ---
        final updatedTransaction = TransactionModel(
          id: _idToUpdate, // Use the original ID
          amount: amount,
          description: _descriptionController.text,
          date: _selectedDate,
          category: _selectedCategory,
          type: _selectedType,
        );
        db.updateTransaction(updatedTransaction);
      } else {
        // --- ADD NEW ---
        final newTransaction = TransactionModel(
          id: DateTime.now().toIso8601String(), // Unique ID
          amount: amount,
          description: _descriptionController.text,
          date: _selectedDate,
          category: _selectedCategory,
          type: _selectedType,
        );
        db.addTransaction(newTransaction);
      }

      Navigator.of(context).pop(); // Close the bottom sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Title ---
              Text(
                _isEditing ? 'Edit Transaction' : 'Add Transaction',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // --- Amount Field ---
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount (Rs.)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rs. ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- Description Field ---
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- Type Toggle (Income/Expense) ---
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'expense',
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    // If switching to income, set category to "Other"
                    if (_selectedType == 'income') {
                      _selectedCategory = 'Other';
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // --- Category & Date ---
              Row(
                children: [
                  // --- Category ---
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      // Disable if type is 'income'
                      // (or, you could have a separate list for income categories)
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      // Only show categories if it's an expense
                      items:
                          (_selectedType == 'expense'
                                  ? HiveDatabase.categories
                                  : ['Other']) // Only "Other" for income
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                      onChanged: _selectedType == 'income'
                          ? null // Disable if income
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // --- Date ---
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('MMM d, yyyy').format(_selectedDate),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Save Button ---
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _onSave,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(_isEditing ? 'Update' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
