// lib/expense_service.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:xpenso/Models/accountmodel.dart';
import 'package:xpenso/Models/budgetmodel.dart';
import 'package:xpenso/Models/categorymodel.dart';

import 'package:xpenso/Models/transactionmodel.dart';
import 'package:xpenso/notification/budgetnotification.dart';
import 'package:xpenso/services/other/graphfunctions.dart';
import 'package:xpenso/widgets/Piechart.dart';
import 'package:xpenso/widgets/Progressbar.dart';
import 'package:xpenso/widgets/custombargraph.dart';

class TransactionServices extends ChangeNotifier {
  final Box<Transaction> _transactionBox =
      Hive.box<Transaction>('transactions');
  final Box<Accounts> _accountBox = Hive.box<Accounts>('Accounts');
  final Box<Budget> _budgetBox = Hive.box<Budget>('Budgets');
  final Box<Category> _categoryBox = Hive.box<Category>('categories');

  List<Transaction> get transaction => _transactionBox.values.toList();
  List<Accounts> get accounts => _accountBox.values.toList();

//Other Service

  void addAccount(
      {String? id,
      required String name,
      required double initbal,
      required bal,
      required int icon,
      dynamic acKey}) {
    Accounts ac = Accounts(
        id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        icon: icon,
        bal: bal,
        initbal: initbal);
    acKey != null ? _accountBox.put(acKey, ac) : _accountBox.add(ac);

    notifyListeners();
  }

  void updateAccount(
      Accounts editedac, BuildContext context, String operation) {
    for (var ac in _accountBox.values) {
      if (editedac.id == ac.id) {
        for (var key in _accountBox.keys) {
          if (_accountBox.get(key) == ac) {
            if (operation == "Delete") {
              var deletebox = Hive.box('facdel');
              deletebox.add(editedac.id);

              deleteAccount(key);
              deleteTransactionOnAccountDeletion(editedac.name);
            } else {
              Accounts? updatedac = updateBalance(editedac);

              if (ac.name != editedac.name) {
                List<Transaction> txns = filterTransactionbyAccount(ac.name);
                for (var txn in txns) {
                  txn.account = updatedac!.name;

                  updateTransaction(txn, context, "Edit", txn.account);
                }
              }

              addAccount(
                  bal: updatedac!.bal,
                  id: updatedac.id,
                  name: updatedac.name,
                  initbal: updatedac.initbal,
                  icon: updatedac.icon,
                  acKey: key);
            }
          }
        }
      }
    }
  }

  List<Transaction> filterTransactionbyAccount(String account) {
    return _transactionBox.values
        .where((txn) => txn.account == account)
        .toList();
  }

  void updateTransaction(Transaction editedtxn, BuildContext context,
      String operation, String oldAccount) {
    for (var txn in _transactionBox.values) {
      if (editedtxn.id == txn.id) {
        for (var key in _transactionBox.keys) {
          if (_transactionBox.get(key) == txn) {
            if (operation == "Delete") {
              var deletebox = Hive.box('fexpdel');
              deletebox.add(editedtxn.id);

              deleteTransaction(key);
              updateAccountBalanceonTxns(editedtxn.account);
            } else {
              addTransaction(
                  context: context,
                  amount: editedtxn.amount,
                  date: editedtxn.date,
                  category: editedtxn.category,
                  account: editedtxn.account,
                  txnType: editedtxn.type,
                  id: editedtxn.id,
                  txnKey: key);
              updateAccountBalanceonTxns(oldAccount);
              updateAccountBalanceonTxns(editedtxn.account);
            }
          }
        }
      }
    }
  }

  Accounts? updateBalance(Accounts editedAc) {
    for (var ac in _accountBox.values) {
      if (editedAc.id == ac.id) {
        double difference = ac.initbal - editedAc.initbal;
        editedAc.bal =
            (difference < 0 ? difference.abs() : -difference) + editedAc.bal;
        return editedAc;
      }
    }
    return null;
  }

  void addTransaction(
      {context,
      required double amount,
      required DateTime date,
      required String category,
      required String account,
      required String txnType,
      String? id,
      dynamic txnKey}) {
    print(amount);
    Transaction transaction = Transaction(
        id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        amount: amount,
        category: category,
        date: date,
        account: account,
        type: txnType);

    print('Expense added');

    if (txnKey != null) {
      _transactionBox.put(txnKey, transaction);
    } else {
      _transactionBox.add(transaction);
    }
    updateAccountBalanceonTxns(account);

    notifyListeners();

    transaction.type != "Income" &&
            transaction.date.month == DateTime.now().month
        ? budgetAnalyse()
        : null;
  }

  void deleteTransaction(dynamic key) {
    for (var txn in _transactionBox.values) {
      for (key in _transactionBox.keys) {
        if (txn == _transactionBox.get(key)) {
          if (txn.type != "Income" && txn.date.month == DateTime.now().month) {
            budgetAnalyse();
          }
        }
      }
    }

    _transactionBox.delete(key);
    notifyListeners();
  }

  void deleteAccount(dynamic key) {
    _accountBox.delete(key);
    notifyListeners();
  }

  void updateAccountBalanceonTxns(
    String account,
  ) {
    List<Transaction> txns = filterTransactionbyAccount(account);
    double inTotal = getTotalTxn(txns, "Income");
    double expTotal = getTotalTxn(txns, "Expense");

    for (var ac in _accountBox.values) {
      if (ac.name == account) {
        ac.bal = ac.initbal;
        ac.bal = ac.bal + inTotal - expTotal;
        ac.save();
        notifyListeners();
      }
    }
  }

  double getTotalTxn(List<Transaction> txns, String type) {
    double inTotal = 0.0;
    double expTotal = 0.0;
    for (var txn in txns) {
      if (txn.type == "Income") {
        inTotal += txn.amount;
      } else {
        expTotal += txn.amount;
      }
    }

    if (type == "Income") {
      return inTotal;
    } else {
      return expTotal;
    }
  }

  List<Transaction> getExpense() {
    return _transactionBox.values
        .where((transaction) => transaction.type == "Expense")
        .toList();
  }

  List<Transaction> getIncome() {
    return _transactionBox.values
        .where((transaction) => transaction.type == "Income")
        .toList();
  }

  List<BarGraphData> fetchBarGraphData(
      {required String filterby,
      required String month,
      required String year,
      required String txnType}) {
    if (txnType == "Expense") {
      List<Transaction> txns = getExpense();
      return getBarGraphData(
          filterby: filterby, month: month, year: year, txns: txns);
    } else {
      List<Transaction> txns = getIncome();
      return getBarGraphData(
          filterby: filterby, month: month, year: year, txns: txns);
    }
  }

  List<BarGraphData> getBarGraphData(
      {required String filterby,
      required String month,
      required String year,
      required List<Transaction> txns}) {
    List<BarGraphData> filteredData = [];
    String x = "Month";

    if (filterby == "Month") {}

    for (var txn in txns) {
      DateTime date = txn.date;
      double amount = txn.amount;

      if (filterby == "Month") {
        x = DateFormat('MMMM-yyyy').format(date);
      } else if (filterby == "Year") {
        x = DateFormat('yyyy').format(date);
      } else {
        x = DateFormat('dd-MMMM-yyyy').format(date);
      }

      double y = amount;

      var exp = BarGraphData(y: y, x: x);

      filteredData.add(exp);
    }
    if (filterby != "Year") {
      List<BarGraphData> newData = fil(filteredData, filterby, month, year);
      List<BarGraphData> bargraphData = getTotalBargraphamount(newData);
      return bargraphData;
    }
    List<BarGraphData> bargraphData = getTotalBargraphamount(filteredData);
    return bargraphData;
  }

  List<PieChartData> fetchPieChartData(
      DateTime date, String filterby, String txnType) {
    List<Transaction> filteredTxns = [];
    List<PieChartData> filteredData = [];
    if (filterby == "Day") {
      filteredTxns = getDayTxns(date, txnType);
    } else if (filterby == "Month") {
      filteredTxns = getMonthTxns(date, txnType);
    } else {
      filteredTxns = getMonthTxns(date, txnType);
    }
    for (var expense in filteredTxns) {
      String category = expense.category;
      double amount = expense.amount;
      var exp = PieChartData(x: category, y: amount);
      filteredData.add(exp);
    }
    List<PieChartData> piehartData = getTotalPiechartamount(filteredData);
    return piehartData;
  }

  double getTotalExpenseForCurrentMonth() {
    DateTime now = DateTime.now();
    double total = 0.0;
    for (var txn in _transactionBox.values) {
      if (txn.date.year == now.year &&
          txn.date.month == now.month &&
          txn.type == "Expense") {
        total += txn.amount;
      }
    }
    return total;
  }

  double getTotalExpenseForCurrenYear() {
    DateTime now = DateTime.now();
    double total = 0.0;
    for (var txn in _transactionBox.values) {
      if (txn.date.year == now.year && txn.type == "Expense") {
        total += txn.amount;
      }
    }
    return total;
  }

  double getTotalIncomeForCurrenYear() {
    DateTime now = DateTime.now();
    double total = 0.0;
    for (var txn in _transactionBox.values) {
      if (txn.date.year == now.year && txn.type == "Income") {
        total += txn.amount;
      }
    }
    return total;
  }

  double getTotalIncomeForCurrentDay() {
    DateTime now = DateTime.now();
    double total = 0.0;
    for (var txn in _transactionBox.values) {
      if (txn.date.year == now.year &&
          txn.date.day == now.day &&
          txn.date.month == now.month &&
          txn.type == "Income") {
        total += txn.amount;
      }
    }
    return total;
  }

  double getTotalExpenseForCurrentDay() {
    DateTime now = DateTime.now();
    double total = 0.0;
    for (var txn in _transactionBox.values) {
      if (txn.date.year == now.year &&
          txn.date.day == now.day &&
          txn.date.month == now.month &&
          txn.type == "Expense") {
        total += txn.amount;
      }
    }
    return total;
  }

  double getTotalIncomeForCurrentMonth() {
    DateTime now = DateTime.now();
    double total = 0.0;
    for (var txn in _transactionBox.values) {
      if (txn.date.year == now.year &&
          txn.date.month == now.month &&
          txn.type == "Income") {
        total += txn.amount;
      }
    }
    return total;
  }

  List<Transaction> getDayTxns(DateTime date, String txnType) {
    if (txnType == "Expense" || txnType == "Income") {
      return _transactionBox.values
          .where((txn) =>
              txn.date.day == date.day &&
              txn.date.month == date.month &&
              txn.date.year == date.year &&
              txn.type == txnType)
          .toList();
    } else {
      return _transactionBox.values
          .where((txn) =>
              txn.date.day == date.day &&
              txn.date.month == date.month &&
              txn.date.year == date.year)
          .toList();
    }
  }

  List<Transaction> getMonthTxns(DateTime date, String txnType) {
    if (txnType == "Expense" || txnType == "Income") {
      return _transactionBox.values
          .where((txn) =>
              txn.date.month == date.month &&
              txn.date.year == date.year &&
              txn.type == txnType)
          .toList();
    } else {
      return _transactionBox.values
          .where((txn) =>
              txn.date.month == date.month && txn.date.year == date.year)
          .toList();
    }
  }

  List<Transaction> getYearTxns(DateTime date, String txnType) {
    if (txnType == "Expense" || txnType == "Income") {
      return _transactionBox.values
          .where((txn) => txn.date.year == date.year && txn.type == txnType)
          .toList();
    } else {
      return _transactionBox.values
          .where((txn) => txn.date.year == date.year)
          .toList();
    }
  }

  List<Transaction> getFilteredTransactions(
      {required DateTime currentDate,
      required String transactionTypeFilter,
      required String viewType,
      String? acType}) {
    final DateTime start;
    final DateTime end;

    switch (viewType) {
      case 'Daily':
        start = DateTime(currentDate.year, currentDate.month, currentDate.day);
        end = DateTime(
            currentDate.year, currentDate.month, currentDate.day, 23, 59, 59);
        break;
      case 'Weekly':
        start = currentDate.subtract(Duration(days: currentDate.weekday - 1));
        end = start.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case 'Monthly':
        start = DateTime(currentDate.year, currentDate.month, 1);
        end = DateTime(currentDate.year, currentDate.month + 1, 1)
            .subtract(Duration(seconds: 1));
        break;
      case 'Yearly':
        start = DateTime(currentDate.year, 1, 1);
        end =
            DateTime(currentDate.year + 1, 1, 1).subtract(Duration(seconds: 1));
        break;
      default:
        start = DateTime(currentDate.year, currentDate.month, 1);
        end = DateTime(currentDate.year, currentDate.month + 1, 1)
            .subtract(Duration(seconds: 1));
    }

    return _transactionBox.values.where((transaction) {
      final isInDateRange =
          transaction.date.isAfter(start.subtract(Duration(seconds: 1))) &&
              transaction.date.isBefore(end.add(Duration(seconds: 1)));
      final matchesType = transactionTypeFilter == 'All' ||
          transaction.type == transactionTypeFilter;
      final matchesAcTpe = transaction.account == acType;
      if (acType == null) {
        return isInDateRange && matchesType;
      } else {
        return isInDateRange && matchesType && matchesAcTpe;
      }
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  String getAccountName(int index) {
    Accounts? ac = _accountBox.getAt(index);
    return ac!.name;
  }

  void budgetAnalyse() {
    final now = DateTime.now();
    if (_budgetBox.containsKey('${now.month}-${now.year}')) {
      final currentMonthBudget = _budgetBox.get('${now.month}-${now.year}');

      double? totalBudget = currentMonthBudget!.totalBudget;

      if (totalBudget != null) {
        double expense = getTotalExpenseForCurrentMonth();
        if (expense >= 0.75 * totalBudget && expense < 0.95 * totalBudget) {
          LocalNotifications.showSimpleNotification(
              title: " Monthly budget  is going to expire ",
              body: '75%',
              payload: "");

          LocalNotifications.showPeriodicTotalBudgetsNotifications(
              title: " Monthly budget  is going to expire ",
              body: '75%',
              payload: "");
        } else if (expense >= 0.95 * totalBudget) {
          LocalNotifications.showSimpleNotification(
              title: " Monthly budget  is going to expire ",
              body: '95%',
              payload: "");

          try {
            LocalNotifications.cancelTotalBudgetNotifiactionFromDay(
                DateTime.now().day);
          } catch (e) {
            print("No notification");
          }

          LocalNotifications.showPeriodicTotalBudgetsNotifications(
              title: " Monthly budget  is going to expire ",
              body: '95%',
              payload: "");
        } else {
          try {
            LocalNotifications.cancelTotalBudgetNotifiactionFromDay(
                DateTime.now().day);
          } catch (e) {
            print("No notification");
          }
        }
        if (totalBudget < expense) {
          LocalNotifications.showSimpleNotification(
              title: "Monthly Budget Exceeded",
              body: "₹${expense.toString()}/₹${totalBudget.toString()}",
              payload: "");
        }
      }

      if (currentMonthBudget.categoryBudgets.isNotEmpty) {
        Map<String, double> categoryBudget = currentMonthBudget.categoryBudgets;
        categoryBudget.forEach((key, value) {
          double totalExpense = getCurrentMonthCategoryWiseTotalExpense(key);
          String? categoryId = getCategoryID(key);

          if (totalExpense >= 0.75 * value && totalExpense < 0.95 * value) {
            LocalNotifications.showSimpleNotification(
                title: " $key budget  is going to exceed ",
                body: '75%',
                payload: "");

            LocalNotifications.showCategorywiseNotifications(
                id: int.parse(categoryId ?? "1111"),
                title: " $key budget  is going to exceed ",
                body: '75%',
                payload: "");
          } else if (totalExpense >= 0.95 * value) {
            LocalNotifications.showSimpleNotification(
                title: " $key budget  is going to expire ",
                body: '95%',
                payload: "");

            try {
              LocalNotifications.cancelallCategoryNotificationFromDay(
                  (DateTime.now().day) + int.parse(categoryId ?? "1111"));
            } catch (e) {
              print("No notification");
            }

            LocalNotifications.showCategorywiseNotifications(
                id: int.parse(categoryId ?? "11111"),
                title: " $key budget  is going to expire ",
                body: '95%',
                payload: "");
          } else {
            try {
              LocalNotifications.cancelallCategoryNotificationFromDay(
                  (DateTime.now().day) + int.parse(categoryId ?? "1111"));
            } catch (e) {
              print("No notification");
            }
          }
          if (value < totalExpense) {
            LocalNotifications.showSimpleNotification(
                title: "$key Budget Exceeded",
                body: "₹${totalExpense.toString()}/₹${value.toString()}",
                payload: "");
          }
        });
      }
    }
  }

  String? getCategoryID(String category) {
    for (var cat in _categoryBox.values) {
      if (cat.name == category) {
        return cat.id;
      }
    }
    return null;
  }

  void clearBoxes() {
    _transactionBox.clear();
    _budgetBox.clear();
    _accountBox.clear();
    _categoryBox.clear();
  }

  double getCurrentMonthCategoryWiseTotalExpense(String category) {
    DateTime now = DateTime.now();
    double total = 0.0;
    for (var txn in _transactionBox.values) {
      if (txn.date.year == now.year &&
          txn.date.month == now.month &&
          txn.category == category &&
          txn.type == "Expense") {
        total += txn.amount;
      }
    }
    return total;
  }

//budget service

  Budget? getCurrentMonthBudget() {
    final now = DateTime.now();
    return _budgetBox.get('${now.month}-${now.year}');
  }

  void saveCurrentMonthBudget(Budget budget) {
    final now = DateTime.now();
    _budgetBox.put('${now.month}-${now.year}', budget);
    notifyListeners();
  }

  void deleteCurrentMonthBudget() {
    final now = DateTime.now();
    try {
      var deletebox = Hive.box('fbuddel');
      deletebox.add('${now.month}-${now.year}');
    } catch (e) {}

    _budgetBox.delete('${now.month}-${now.year}');
    notifyListeners();
  }

  void saveTotalBudget(double? totalBudget) {
    final now = DateTime.now();
    final currentBudget = getCurrentMonthBudget() ??
        Budget(
          totalBudget: null,
          categoryBudgets: {},
          month: now.month,
          year: now.year,
        );

    final totalCategoryBudget = currentBudget.categoryBudgets.values
        .fold(0.0, (sum, value) => sum + value);

    if (totalBudget != null && totalBudget < totalCategoryBudget) {
      throw Exception(
          'Total budget must be at least equal to the sum of category budgets.');
    }

    final updatedBudget = Budget(
      totalBudget: totalBudget,
      categoryBudgets: currentBudget.categoryBudgets,
      month: currentBudget.month,
      year: currentBudget.year,
    );

    saveCurrentMonthBudget(updatedBudget);
  }

  void deleteTotalBudget() {
    final now = DateTime.now();
    final currentBudget = getCurrentMonthBudget();
    if (currentBudget != null) {
      final updatedBudget = Budget(
        totalBudget: null,
        categoryBudgets: currentBudget.categoryBudgets,
        month: currentBudget.month,
        year: currentBudget.year,
      );

      saveCurrentMonthBudget(updatedBudget);
      if (getCurrentMonthBudget()!.totalBudget == null &&
          getCurrentMonthBudget()!.categoryBudgets.isEmpty) {
        print("Total Budget deleted");
        deleteCurrentMonthBudget();
      }
    }
  }

  double getSavingsCurrentMonth() {
    print("$getTotalExpenseForCurrentMonth()");
     print("$getTotalIncomeForCurrentMonth()");

    return  getTotalIncomeForCurrentMonth()  -  getTotalExpenseForCurrentMonth()  ;
  }

  void saveCategoryBudget(
      String monthYearKey, String categoryId, double budget) {
    final currentBudget = _budgetBox.get(monthYearKey) ??
        Budget(
          totalBudget: null,
          categoryBudgets: {},
          month: DateTime.now().month,
          year: DateTime.now().year,
        );

    final newCategoryBudgets =
        Map<String, double>.from(currentBudget.categoryBudgets)
          ..[categoryId] = budget;

    final totalCategoryBudget =
        newCategoryBudgets.values.fold(0.0, (sum, value) => sum + value);

    if (currentBudget.totalBudget != null &&
        totalCategoryBudget > currentBudget.totalBudget!) {
      throw Exception('Category budgets exceed the total budget.');
    }

    final updatedBudget = Budget(
      totalBudget: currentBudget.totalBudget,
      categoryBudgets: newCategoryBudgets,
      month: currentBudget.month,
      year: currentBudget.year,
    );

    _budgetBox.put(monthYearKey, updatedBudget);
    notifyListeners();
  }

  void deleteCategoryBudget(String monthYearKey, String categoryname) {
    final currentBudget = _budgetBox.get(monthYearKey);
    if (currentBudget != null) {
      final newCategoryBudgets =
          Map<String, double>.from(currentBudget.categoryBudgets)
            ..remove(categoryname);

      final updatedBudget = Budget(
        totalBudget: currentBudget.totalBudget,
        categoryBudgets: newCategoryBudgets,
        month: currentBudget.month,
        year: currentBudget.year,
      );

      _budgetBox.put(monthYearKey, updatedBudget);
      notifyListeners();

      if (currentBudget.totalBudget == null &&
          getCurrentMonthBudget()!.categoryBudgets.isEmpty) {
        print("Total Budget deleted");
        deleteCurrentMonthBudget();
      }
    }
  }

  void getTotalCategoryWiseMonthlytxn(List<Transaction> txns) {
    Map<String, double> categoryTxnTotalmap = {};

    for (var txn in txns) {
      if (categoryTxnTotalmap.containsKey(txn.category)) {
        categoryTxnTotalmap[txn.category] =
            (categoryTxnTotalmap[txn.category] ?? 0.0 + txn.amount);
      } else {
        categoryTxnTotalmap[txn.category] = txn.amount;
      }
    }
  }

  List<CategorywiseBudgetAnalyseData>
      getBudgetExpenseCategoryWiseCurrentMonth() {
    Budget? currentmonthBudget = getCurrentMonthBudget();
    List<CategorywiseBudgetAnalyseData> categoryBudgetData = [];

    if (currentmonthBudget != null) {
      if (currentmonthBudget.categoryBudgets.isNotEmpty) {
        currentmonthBudget.categoryBudgets.forEach((key, value) {
          double totalExpense = getCurrentMonthCategoryWiseTotalExpense(key);
          categoryBudgetData.add(CategorywiseBudgetAnalyseData(
              categoryName: key, expense: totalExpense, budget: value));
        });
      }
    }

    return categoryBudgetData;
  }

  void deleteTransactionOnAccountDeletion(String ac) {
    List<Transaction> txnList = getTxnsbyAccount(ac);
    for (var txn in txnList) {
      for (var key in _transactionBox.keys) {
        if (_transactionBox.get(key) == txn) {
          var deletebox = Hive.box('fexpdel');
          deletebox.add(txn.id);

          deleteTransaction(key);
        }
      }
    }
  }

  void deleteTransactionOnCategoryDeletion(String cat) {
    List<Transaction> txnList = getTxnsbyCategory(cat);
    for (var txn in txnList) {
      for (var key in _transactionBox.keys) {
        if (_transactionBox.get(key) == txn) {
          var deletebox = Hive.box('fexpdel');
          deletebox.add(txn.id);
          deleteTransaction(key);
        }
      }
    }
  }

  List<Transaction> getTxnsbyAccount(String ac) {
    List<Transaction> txnList =
        _transactionBox.values.where((txn) => txn.account == ac).toList();
    return txnList;
  }

  List<Transaction> getTxnsbyCategory(String cat) {
    List<Transaction> txnList =
        _transactionBox.values.where((txn) => txn.category == cat).toList();
    return txnList;
  }

  HomeScreenIncomeExpense getExpenseIncomeDataforHomeScreen(String choice) {
    if (choice == "Month") {
      double expense = getTotalExpenseForCurrentMonth();
      double income = getTotalIncomeForCurrentMonth();
      return HomeScreenIncomeExpense(
          totalExpense: expense, totalIncome: income);
    }
    if (choice == "Year") {
      double expense = getTotalExpenseForCurrenYear();
      double income = getTotalIncomeForCurrenYear();
      return HomeScreenIncomeExpense(
          totalExpense: expense, totalIncome: income);
    } else {
      double expense = getTotalExpenseForCurrentDay();
      double income = getTotalExpenseForCurrentDay();
      return HomeScreenIncomeExpense(
          totalExpense: expense, totalIncome: income);
    }
  }

  List<Transaction> getTxnExpense(String choice) {
    if (choice == "Month") {
      return getMonthTxns(DateTime.now(), "Expense");
    } else if (choice == "Year") {
      return getYearTxns(DateTime.now(), "Expense");
    } else {
      return getDayTxns(DateTime.now(), "Expense");
    }
  }

  List<CategorydataHome> getCategoryWiseHomeData(String choice) {
    Map<String, double> categoryMap = {};
    List<CategorydataHome> catData = [];

    for (var exp in getTxnExpense(choice)) {
      if (categoryMap.containsKey(exp.category)) {
        categoryMap[exp.category] =
            (categoryMap[exp.category] ?? 0.0 + exp.amount);
      } else {
        categoryMap[exp.category] = exp.amount;
      }
    }

    if (categoryMap.isNotEmpty) {
      categoryMap.forEach((key, value) {
        for (var cat in _categoryBox.values) {
          if (cat.name == key) {
            var ob = CategorydataHome(
                categoryName: key,
                categoryIcon: cat.icon,
                categoryTotalExpense: value);
            catData.add(ob);
          }
        }
      });
    }

    return catData;
  }
}

class HomeScreenIncomeExpense {
  double totalIncome;
  double totalExpense;
  HomeScreenIncomeExpense(
      {required this.totalExpense, required this.totalIncome});
}

class CategorydataHome {
  String categoryName;
  int categoryIcon;
  double categoryTotalExpense;

  CategorydataHome(
      {required this.categoryName,
      required this.categoryIcon,
      required this.categoryTotalExpense});
}
