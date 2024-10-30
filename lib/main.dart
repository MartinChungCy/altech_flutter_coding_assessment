import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/expense_bloc.dart';
import 'bloc/expense_event.dart';
import 'expense_list_page.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ExpenseBloc()..add(LoadExpensesEvent()),
        ),
        // Add more BlocProviders here if needed in the future.
      ],
      child: const MaterialApp(
        title: 'Expense Tracker',
        home: ExpenseListPage(),
      ),
    );
  }
}