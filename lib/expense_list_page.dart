import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'add_expense_dialog.dart';
import 'bloc/expense_bloc.dart';
import 'bloc/expense_event.dart';
import 'bloc/expense_state.dart';
import 'edit_expense_dialog.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  ExpenseListPageState createState() => ExpenseListPageState();
}

class ExpenseListPageState extends State<ExpenseListPage> {
  static const String appBarTitle = 'Expense Tracker';
  static const double paddingValue = 8.0;

  String searchQuery = '';
  String? selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Transport',
    'Food',
    'Clothes',
    'Others',
    'Utilities',
  ];

  final Map<String, Color> categoryColors = {
    'Transport': Colors.green,
    'Food': Colors.orange,
    'Clothes': Colors.blue,
    'Others': Colors.grey,
    'Utilities': Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appBarTitle),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(paddingValue),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _buildSearchTextField(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: _buildCategoryDropdown(),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ExpenseLoaded) {
                  final expenses = state.expenses;
                  final sortedExpenses = List.from(expenses)
                    ..sort((a, b) => b.date.compareTo(a.date));

                  final filteredExpenses = _filterExpenses(sortedExpenses);

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Total Expenses: \$${_calculateTotalExpenses(expenses)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      filteredExpenses.isEmpty
                          ? const Center(child: Text('No Results Were Found.'))
                          : _buildExpensesList(filteredExpenses),
                    ],
                  );
                } else {
                  return const Center(child: Text('Something went wrong'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => BlocProvider.value(
            value: context.read<ExpenseBloc>(),
            child: const AddExpenseDialog(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchTextField() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Search',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField2<String>(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Select Category',
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      value: selectedCategory,
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
        });
      },
    );
  }

  Expanded _buildExpensesList(List filteredExpenses) {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredExpenses.length,
        itemBuilder: (context, index) {
          final expense = filteredExpenses[index];
          final categoryColor = categoryColors[expense.category] ?? Colors.grey;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: categoryColor,
                          border: Border.all(
                            color: categoryColor,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(' ${expense.category} '),
                      ),
                      Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                      ),
                      Text(
                        DateFormat.yMMMd().format(expense.date),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => BlocProvider.value(
                          value: context.read<ExpenseBloc>(),
                          child:
                              EditExpenseDialog(expense: expense, index: index),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => context.read<ExpenseBloc>().add(
                            DeleteExpenseEvent(filteredExpenses[index].id),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List _filterExpenses(List expenses) {
    return expenses.where((expense) {
      final query = searchQuery.toLowerCase();
      final titleMatches = expense.title.toLowerCase().contains(query);
      final amountMatches = RegExp(searchQuery.replaceAll(r'\d', r'[0-9]'))
          .hasMatch(expense.amount.toStringAsFixed(2));
      final matchesCategory = selectedCategory == null ||
          selectedCategory == 'All' ||
          expense.category == selectedCategory;
      return (titleMatches || amountMatches) && matchesCategory;
    }).toList();
  }

  String _calculateTotalExpenses(List expenses) {
    return expenses
        .fold(0.0, (sum, item) => sum + item.amount)
        .toStringAsFixed(2);
  }
}
