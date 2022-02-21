import 'package:expense_bud/config/constants.dart';
import 'package:expense_bud/config/theme.dart';
import 'package:expense_bud/core/utils/extensions.dart';
import 'package:expense_bud/core/widgets/gap.dart';
import 'package:expense_bud/core/widgets/state.dart';
import 'package:expense_bud/features/expense/domain/entities/expense.dart';
import 'package:expense_bud/features/expense/presentation/expense_list_item.dart';
import 'package:expense_bud/features/expense/presentation/provider/expense_provider.dart';
import 'package:expense_bud/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Tab { today, month }

class ExpenseTab extends StatefulWidget {
  const ExpenseTab({Key? key}) : super(key: key);

  @override
  State<ExpenseTab> createState() => _ExpenseTabState();
}

class _ExpenseTabState extends State<ExpenseTab> {
  Tab currentTab = Tab.today;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.lg,
            vertical: Insets.md,
          ),
          child: Container(
            height: 40,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppColors.kGrey200,
              borderRadius: Corners.lgBorder,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: Tab.values
                  .map(
                    (e) => Expanded(
                      child: TabItem((e.name.titleCaseSingle()),
                          value: e,
                          groupValue: currentTab,
                          onChanged: (value) =>
                              setState(() => currentTab = value)),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        IndexedStack(
          index: currentTab.index,
          children: const [TodayTab(), MonthTab()],
        ),
      ],
    );
  }
}

class TodayTab extends StatefulWidget {
  const TodayTab({Key? key}) : super(key: key);

  @override
  _TodayTabState createState() => _TodayTabState();
}

class _TodayTabState extends State<TodayTab> {
  @override
  void initState() {
    super.initState();
    final expenseProvider = context.read<ExpenseProvider>();
    expenseProvider.getDayEntries();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final date = expenseProvider.currentDateString;
    final entries = expenseProvider.currentDayEntries;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExpenseHeader(date: date),
          entries.when(
            loading: (msg) => const Center(child: Text("Loading...")),
            done: (entries) => entries.isEmpty
                ? const NoDataOrError("No entries today")
                : ExpenseList(entries),
            error: (msg) => NoDataOrError(msg!, variant: Variant.error),
          )
        ],
      ),
    );
  }
}

class MonthTab extends StatefulWidget {
  const MonthTab({Key? key}) : super(key: key);

  @override
  _MonthTabState createState() => _MonthTabState();
}

class _MonthTabState extends State<MonthTab> {
  @override
  void initState() {
    super.initState();
    final expenseProvider = context.read<ExpenseProvider>();
    expenseProvider.getMonthEntries();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final money = context.watch<SettingsProvider>().money;
    final entries = expenseProvider.allEntries;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          entries.when(
            loading: (msg) => const Center(child: Text("Loading...")),
            done: (data) => data.isEmpty
                ? const NoDataOrError("No entries this month")
                : Column(
                    children: [
                      ...data.keys
                          .map(
                            (key) => Column(
                              children: [
                                ExpenseHeader(
                                  date: context
                                      .read<ExpenseProvider>()
                                      .getReadableDateString(key),
                                  amount: money.formatValue(
                                    context
                                        .read<ExpenseProvider>()
                                        .getDayTotal(data[key]),
                                  ),
                                ),
                                ExpenseList(data[key]!),
                                Gap.md,
                              ],
                            ),
                          )
                          .toList()
                    ],
                  ),
            error: (msg) => NoDataOrError(msg!, variant: Variant.error),
          ),
        ],
      ),
    );
  }
}

class ExpenseList extends StatelessWidget {
  final List<ExpenseEntity> entries;
  const ExpenseList(this.entries, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: Insets.sm),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: entries.length,
      itemBuilder: (context, i) => ExpenseListItem(entries[i]),
    );
  }
}

class ExpenseHeader extends StatelessWidget {
  final String date;
  final String? amount;
  const ExpenseHeader({required this.date, this.amount, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(date, style: context.textTheme.bodyText1!),
        Text(
          amount ?? "",
          style: context.textTheme.bodyText2!.copyWith(
            color: const Color(0xFFE58D67),
            fontSize: FontSizes.s16,
          ),
        )
      ],
    );
  }
}

class TabItem extends StatelessWidget {
  final String title;
  final Tab value;
  final Tab groupValue;
  final ValueChanged<Tab> onChanged;

  const TabItem(
    this.title, {
    required this.value,
    required this.groupValue,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.kDark : AppColors.kGrey200,
        borderRadius: Corners.lgBorder,
      ),
      child: Center(
        child: Text(
          title,
          style: context.textTheme.bodyText1!.copyWith(
            color: isSelected ? Colors.white : AppColors.kDark,
          ),
        ),
      ),
    ).onTap(() => onChanged(value));
  }
}
