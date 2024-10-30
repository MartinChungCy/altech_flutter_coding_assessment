import 'package:equatable/equatable.dart';
import 'expense_item.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object> get props => [];
}

class LoadExpensesEvent extends ExpenseEvent {}

class AddExpenseEvent extends ExpenseEvent {
  final ExpenseItem expense;

  const AddExpenseEvent(this.expense);

  @override
  List<Object> get props => [expense];
}

class UpdateExpenseEvent extends ExpenseEvent {
  final int index;
  final ExpenseItem updatedExpense;

  const UpdateExpenseEvent(this.index, this.updatedExpense);
}

class DeleteExpenseEvent extends ExpenseEvent {
  final int index;

  const DeleteExpenseEvent(this.index);

  @override
  List<Object> get props => [index];
}
