import 'package:expense_tracker/config/theme.dart';
import 'package:expense_tracker/core/expense_category.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/core/utils/extensions.dart';
import 'package:expense_tracker/core/widgets/expense_avatar.dart';
import 'package:expense_tracker/core/widgets/gap.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/provider/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseListItem extends StatelessWidget {
  ExpenseListItem(this._expense, {Key? key}) : super(key: key);
  final ExpenseEntity _expense;
  // ignore: unused_field
  final DateFormatter _dateFormatter = DateFormatter.instance;

  @override
  Widget build(BuildContext context) {
    final _categoryItem = kExpenseCategoryItems
        .singleWhere((e) => e.category == _expense.category);
    final moneyFormatter = context.watch<ExpenseProvider>().moneyFormatter;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Row(
            children: [
              ExpenseAvatar(_categoryItem.category),
              Gap.md,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _categoryItem.title,
                    style: context.textTheme.bodyText1!
                        .copyWith(fontSize: FontSizes.s16),
                  ),
                  // Text(
                  //   "Added ${_dateFormatter.relativeToNow(_expense.createdAt)}",
                  //   style: context.textTheme.caption,
                  // ),
                ],
              )
            ],
          ),
          const Spacer(),
          Text(
            moneyFormatter.stringToMoney(_expense.amount.toString()),
            style: context.textTheme.bodyText2!.copyWith(
              color: const Color(0xFFE58D67),
            ),
          )
        ],
      ),
    );
  }
}
