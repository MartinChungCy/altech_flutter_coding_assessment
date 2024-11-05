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
  final String id;
  final ExpenseItem updatedExpense;

  const UpdateExpenseEvent(this.id, this.updatedExpense);
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String id;

  const DeleteExpenseEvent(this.id);

  @override
  List<Object> get props => [id];
}
