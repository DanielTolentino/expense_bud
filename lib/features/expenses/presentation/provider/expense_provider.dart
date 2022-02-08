import 'package:expense_tracker/core/failure/failure.dart';
import 'package:expense_tracker/core/utils/async_value.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/core/utils/extensions.dart';
import 'package:expense_tracker/core/utils/money_formatter.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/create_entry_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_all_expenses_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_expenses_usecase.dart';
import 'package:flutter/material.dart';

class ExpenseProvider with ChangeNotifier {
  ExpenseProvider(
      {required GetAllExpensesUsecase getAllExpensesUsecase,
      required GetExpensesUsecase getExpensesUsecase,
      required CreateExpenseEntryUsecase createExpenseEntryUsecase})
      : _getAllExpensesUsecase = getAllExpensesUsecase,
        _getExpensesUsecase = getExpensesUsecase,
        _createExpenseEntryUsecase = createExpenseEntryUsecase;

  final GetAllExpensesUsecase _getAllExpensesUsecase;
  final GetExpensesUsecase _getExpensesUsecase;
  final CreateExpenseEntryUsecase _createExpenseEntryUsecase;

  final DateFormatter _dateFormatter = DateFormatter.instance;
  final MoneyFormatter _moneyFormatter = MoneyFormatter(
    currency: Currency(name: 'USD', symbol: "\$", locale: 'en_US'),
  );

  MoneyFormatter get moneyFormatter => _moneyFormatter;

  AsyncValue<List<ExpenseEntity>> _currentDayEntries = AsyncValue.loading();
  AsyncValue<List<ExpenseEntity>> get currentDayEntries => _currentDayEntries;

  AsyncValue<Map<String, List<ExpenseEntity>?>> _allEntries =
      AsyncValue.loading();
  AsyncValue<Map<String, List<ExpenseEntity>?>> get allEntries => _allEntries;

  String get currentDateString => _dateFormatter.datetimeToString(DateTime.now());

  String getReadableDateString(String key) =>
      _dateFormatter.datetimeToString(key.toDateTime());

  double getEntriesTotal(List<ExpenseEntity>? entries) {
    if (entries != null && entries.isNotEmpty) {
      return entries.fold(0, (sum, entry) => sum + entry.amount);
    }
    return 0;
  }

  double get currentDayEntriesTotal => getEntriesTotal(_currentDayEntries.data);

  void getCurrentDayEntries() async {
    final entriesOrFailure = await _getExpensesUsecase();
    entriesOrFailure.fold(
      (failure) =>
          _currentDayEntries = AsyncValue.error(_handleFailure(failure)),
      (data) => _currentDayEntries = AsyncValue.done(data),
    );
    notifyListeners();
  }

  void getAllEntries() async {
    final entriesOrFailure = await _getAllExpensesUsecase();
    entriesOrFailure.fold(
      (failure) => _allEntries = AsyncValue.error(_handleFailure(failure)),
      (data) {
        _allEntries = AsyncValue.done(data);
      },
    );
    notifyListeners();
  }

  Future<void> createExpenseEntry(ExpenseEntity entry) async {
    final entryOrFailure = await _createExpenseEntryUsecase(entry);
    entryOrFailure.fold((failure) => _handleFailure(failure), (entry) {
      _currentDayEntries =
          AsyncValue.done([entry, ..._currentDayEntries.data!]);
    });
    notifyListeners();
  }

  String _handleFailure(Failure failure) {
    switch (failure.runtimeType) {
      case CacheGetFailure:
        return "Error getting entries from device";
      case CachePutFailure:
        return "Error saving entry to device";
      default:
        return "An unexpected error occured";
    }
  }
}
