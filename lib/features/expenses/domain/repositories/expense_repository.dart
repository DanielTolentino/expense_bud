import 'package:dartz/dartz.dart';
import 'package:expense_bud/core/failure/failure.dart';
import 'package:expense_bud/features/expenses/domain/entities/expense.dart';

abstract class IExpenseRepository {
  Future<Either<Failure, List<ExpenseEntity>>> getCurrentDayEntries();
  Future<Either<Failure, Map<String, List<ExpenseEntity>>>>
      getCurrentMonthEntries();
  Future<Either<Failure, ExpenseEntity>> createExpenseEntry(
    ExpenseEntity expense,
  );
  Future<Either<Failure, Unit>> eraseEntries();
}
