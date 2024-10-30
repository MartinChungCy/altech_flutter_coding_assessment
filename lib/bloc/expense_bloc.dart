import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'expense_item.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(ExpenseLoading()) {
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(
      LoadExpensesEvent event, Emitter<ExpenseState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final String? expenseListJson = prefs.getString('expenses');

    if (expenseListJson != null) {
      final List<dynamic> decodedExpenses = jsonDecode(expenseListJson);
      final expenses =
          decodedExpenses.map((item) => ExpenseItem.fromJson(item)).toList();
      emit(ExpenseLoaded(expenses));
    } else {
      emit(const ExpenseLoaded([]));
    }
  }

  Future<void> _onAddExpense(
      AddExpenseEvent event, Emitter<ExpenseState> emit) async {
    if (state is ExpenseLoaded) {
      final List<ExpenseItem> updatedExpenses =
          List.from((state as ExpenseLoaded).expenses)..add(event.expense);

      await _saveExpenses(updatedExpenses);
      emit(ExpenseLoaded(updatedExpenses));
    }
  }

  Future<void> _onUpdateExpense(
      UpdateExpenseEvent event, Emitter<ExpenseState> emit) async {
    if (state is ExpenseLoaded) {
      final List<ExpenseItem> updatedExpenses =
          List.from((state as ExpenseLoaded).expenses);
      updatedExpenses[event.index] = event.updatedExpense;
      await _saveExpenses(updatedExpenses);
      emit(ExpenseLoaded(updatedExpenses));
    }
  }

  Future<void> _onDeleteExpense(
      DeleteExpenseEvent event, Emitter<ExpenseState> emit) async {
    if (state is ExpenseLoaded) {
      final List<ExpenseItem> updatedExpenses =
          List.from((state as ExpenseLoaded).expenses)..removeAt(event.index);

      await _saveExpenses(updatedExpenses);
      emit(ExpenseLoaded(updatedExpenses));
    }
  }

  Future<void> _saveExpenses(List<ExpenseItem> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final String expenseListJson = jsonEncode(expenses);
    await prefs.setString('expenses', expenseListJson);
  }
}
