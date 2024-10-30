import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'bloc/expense_bloc.dart';
import 'bloc/expense_event.dart';
import 'bloc/expense_item.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  AddExpenseDialogState createState() => AddExpenseDialogState();
}

class AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;
  bool _noDateChosen = false;

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
        _noDateChosen = false;
      });
    });
  }

  void _submitExpense() {
    if (_formKey.currentState!.validate()) {
      final enteredTitle = _titleController.text;
      final enteredAmount = double.parse(_amountController.text);
      if (_selectedDate == null || _selectedCategory == null) {
        setState(() {
          _noDateChosen = _selectedDate == null;
        });
        return;
      }
      final newExpense = ExpenseItem(
        title: enteredTitle,
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory!,
      );
      context.read<ExpenseBloc>().add(AddExpenseEvent(newExpense));
      Navigator.of(context).pop();
    }
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(labelText: label);
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  Widget _buildDropdownButtonFormField() {
    return DropdownButtonFormField2<String>(
      decoration: const InputDecoration(
        labelText: 'Select Category',
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      value: _selectedCategory,
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildDatePickerRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _selectedDate == null
                ? 'No Date Chosen!'
                : 'Picked Date: ${DateFormat.yMd().format(_selectedDate!)}',
            style: TextStyle(
              color: _selectedDate == null && _noDateChosen
                  ? Colors.red
                  : Colors.black,
            ),
          ),
        ),
        TextButton(
          onPressed: _presentDatePicker,
          child: const Text(
            'Choose Date',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Expense'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: _buildInputDecoration('Title'),
              controller: _titleController,
              validator: _fieldValidator,
            ),
            TextFormField(
              decoration: _buildInputDecoration('Amount'),
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            _buildDropdownButtonFormField(),
            const SizedBox(height: 10),
            _buildDatePickerRow(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _closeDialog,
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: _submitExpense,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
