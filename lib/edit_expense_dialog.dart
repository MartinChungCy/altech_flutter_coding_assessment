import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/expense_bloc.dart';
import 'bloc/expense_event.dart';
import 'bloc/expense_item.dart';

class EditExpenseDialog extends StatefulWidget {
  final ExpenseItem expense;
  final int index;

  const EditExpenseDialog(
      {super.key, required this.expense, required this.index});

  @override
  EditExpenseDialogState createState() => EditExpenseDialogState();
}

class EditExpenseDialogState extends State<EditExpenseDialog> {
  static DateTime firstDate = DateTime(2020);
  static DateTime lastDate = DateTime(2100);

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late String _selectedCategory;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _selectedCategory = widget.expense.category;
    _selectedDate = widget.expense.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate);
    if (picked != null && picked != initialDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateExpense() {
    if (_formKey.currentState!.validate()) {
      final String title = _titleController.text;
      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      final ExpenseItem updatedExpense = widget.expense.copyWith(
        title: title,
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate ?? DateTime.now(),
      );
      context
          .read<ExpenseBloc>()
          .add(UpdateExpenseEvent(widget.index, updatedExpense));
      Navigator.of(context).pop();
    }
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Expense'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: _validateTitle,
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: _validateAmount,
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              validator: _validateCategory,
            ),
            Row(
              children: [
                Text(_selectedDate != null
                    ? _selectedDate!.toLocal().toString().split(' ')[0]
                    : 'No date selected'),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _pickDate(context),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _updateExpense,
          child: const Text('Save'),
        ),
      ],
    );
  }
}