import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'bloc/expense_bloc.dart';
import 'bloc/expense_event.dart';
import 'bloc/expense_item.dart';

class EditExpenseDialog extends StatefulWidget {
  final ExpenseItem expense;
  final int index;

  static DateTime firstDate = DateTime(2020);
  static DateTime lastDate = DateTime(2100);

  const EditExpenseDialog(
      {super.key, required this.expense, required this.index});

  @override
  EditExpenseDialogState createState() => EditExpenseDialogState();
}

class EditExpenseDialogState extends State<EditExpenseDialog> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late String _selectedCategory;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;

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
    DateTime initialDate = _selectedDate;
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: EditExpenseDialog.firstDate,
        lastDate: EditExpenseDialog.lastDate);
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
          date: _selectedDate);
      context
          .read<ExpenseBloc>()
          .add(UpdateExpenseEvent(updatedExpense.id, updatedExpense));
      Navigator.of(context).pop();
    }
  }

  String? _validateTitle(String? value) =>
      isEmptyOrNull(value) ? 'Please enter a title' : null;

  String? _validateAmount(String? value) {
    if (isEmptyOrNull(value)) return 'Please enter an amount';
    if (double.tryParse(value!) == null) return 'Please enter a valid number';
    return null;
  }

  String? _validateCategory(String? value) =>
      isEmptyOrNull(value) ? 'Please select a category' : null;

  bool isEmptyOrNull(String? value) => value == null || value.isEmpty;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Edit Expense'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitleField(),
            _buildAmountField(),
            _buildCategoryDropdown(),
            _buildDatePickerRow(context),
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

  TextFormField _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(labelText: 'Title'),
      style: const TextStyle(fontWeight: FontWeight.bold),
      validator: _validateTitle,
    );
  }

  TextFormField _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Amount',
      ),
      style: const TextStyle(fontWeight: FontWeight.bold),
      keyboardType: TextInputType.number,
      validator: _validateAmount,
    );
  }

  DropdownButtonFormField2<String> _buildCategoryDropdown() {
    return DropdownButtonFormField2<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Select Category',
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
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
    );
  }

  Row _buildDatePickerRow(BuildContext context) {
    return Row(
      children: [
        Text(
          // _selectedDate!.toLocal().toString().split(' ')[0],
          DateFormat('dd/MM/yyyy').format(_selectedDate),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _pickDate(context),
        ),
      ],
    );
  }
}
