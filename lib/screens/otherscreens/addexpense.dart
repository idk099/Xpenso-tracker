import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

class AddExpensePage extends StatefulWidget {
  

 
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _amountController = TextEditingController();
  late String _selectedCategory;
  late DateTime _selectedDate;
  late String uid;
  late DocumentReference userRef;

  List<String> _categories = [
    'Food',
    'Transportation',
    'Enter',
    'other',
    'new',
    'kk'
  ];
  Map<String, IconData> _categoryIcons = {
    'Food': Icons.fastfood, // Set custom icon for Food category
    'Transportation':
        Icons.directions_car, // Set custom icon for Transportation category
    // Default icons for other categories
    'Entertainment': Icons.movie,
    'Other': Icons.category,
  };

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    userRef = FirebaseFirestore.instance.collection('User').doc(uid);
    _selectedCategory = _categories.first;
    _selectedDate = DateTime.now();
      _fetchCategories();
  }
 Future<void> _fetchCategories() async {
  final categoriesSnapshot = await FirebaseFirestore.instance.collection('categories').get();
  setState(() {
    final fetchedCategories = categoriesSnapshot.docs.map((doc) => doc['category'] as String).toList();
    _categories.addAll(fetchedCategories);
    _selectedCategory = _categories.first;
  });
}



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double responsivePadding = screenWidth * 0.05;
    return Scaffold(
       resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Add Expense',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(responsivePadding),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(responsivePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.currency_rupee_outlined),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(10.0), // Set border radius
                    border: Border.all(color: Colors.grey), // Set border color
                  ),
                  child: DropdownButtonFormField(
                    value: _selectedCategory,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue.toString();
                      });
                    },
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(_categoryIcons[category] ??
                                Icons
                                    .category), // Use custom icon if available, otherwise use default icon
                            SizedBox(width: 10.0),
                            Text(category),
                          ],
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      hintText: 'Select Category', // Set hint text
                      border: InputBorder.none, // Remove border
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: responsivePadding), // Add padding
                    ),
                    style: TextStyle(
                        color: Colors.black), // Set text color to black
                    iconEnabledColor: Colors.black, // Set icon color to black
                    selectedItemBuilder: (BuildContext context) {
                      return _categories.map<Widget>((String category) {
                        return Row(
                          children: <Widget>[
                            Icon(_categoryIcons[category] ?? Icons.category,
                                color: Colors.black),
                            SizedBox(width: 10),
                            Text(
                              category,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 10.0),
                    Text(
                      'Date: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        'Change Date',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () => _addExpense(),
                  child: Text(
                    'Add Expense',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate)
      setState(() {
        _selectedDate = pickedDate;
      });
  }

  void _addExpense() async {
    final amount = int.tryParse(_amountController.text);
    if (amount != null) {
      final expensesRef = userRef.collection('expenses');
      final monthYear = DateFormat('MMMM-yyyy').format(_selectedDate);
      final dayMonthYear = DateFormat('dd-MMMM-yyyy').format(_selectedDate);
      final year = DateFormat('yyyy').format(_selectedDate);
      final added_date = DateTime.now();
      _amountController.clear();

      // Add expense to expenses collection
      await expensesRef.add({
        'amount': amount,
        'category': _selectedCategory,
        'date': Timestamp.fromDate(_selectedDate),
        'added_date': added_date,
        'monthYear': monthYear,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Expense added successfully!'),
      ));
      FocusScope.of(context).unfocus(); 

      // Update daily expenses
      await _updateDailyExpenses(dayMonthYear, amount);

      //monthlyexpenses
      await _updateMonthlyExpenses(monthYear, amount);
      await _updateYearlyExpenses(year, amount);
      await _updateCategoryMonthlyExpenses(monthYear, amount);

      // Update budget info and category-specific budget info
      await _updateBudgetInfo(monthYear, amount);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid amount!'),
      ));
    }
  }

  Future<void> _updateBudgetInfo(String monthYear, int expenseAmount) async {
    final budgetRef = userRef.collection('budgets');
    final budgetInfoRef = userRef.collection('budgetinfo');

    final docSnapshot = await budgetRef.doc(monthYear).get();
    if (docSnapshot.exists) {
      final budgetData = docSnapshot.data() as Map<String, dynamic>;
      final totalBudget = budgetData['totalBudget'] as int;

      final expensesSnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('monthYear', isEqualTo: monthYear)
          .get();

      final totalExpenses = expensesSnapshot.docs.fold<int>(
        0,
        (total, doc) => total + (doc['amount'] ?? 0) as int,
      );

      final amountToExceed = totalBudget - totalExpenses;
      final exceededAmount =
          amountToExceed < 0 ? totalExpenses - totalBudget : 0;

      await budgetInfoRef.doc(monthYear).set({
        'amountToExceed': amountToExceed,
        'exceededAmount': exceededAmount,
        'monthYear': monthYear,
      }, SetOptions(merge: true));

      if (amountToExceed < 0 && totalBudget > 0) {
        _showBudgetExceededAlert();
      }

      // Update category-specific budget info
      for (String category in _categories) {
        await _updateCategoryBudgetInfo(monthYear, expenseAmount, category);
      }
    }
  }

  Future<void> _updateCategoryBudgetInfo(
      String monthYear, int expenseAmount, String category) async {
    final categoryBudgetRef = userRef.collection('${category}budget');
    final categoryBudgetInfoRef = userRef.collection('${category}budgetinfo');

    // Check if the corresponding budget collection exists for the selected month
    final budgetDocSnapshot = await categoryBudgetRef.doc(monthYear).get();

    if (budgetDocSnapshot.exists) {
      // If the budget collection exists, proceed to update the category budget info
      final budgetData = budgetDocSnapshot.data() as Map<String, dynamic>;
      final totalCategoryBudget = budgetData['totalBudget'] as int;

      // Check if the category budget info document exists
      final budgetInfoDocSnapshot =
          await categoryBudgetInfoRef.doc(monthYear).get();

      if (!budgetInfoDocSnapshot.exists) {
        // If the document doesn't exist, create it
        await categoryBudgetInfoRef.doc(monthYear).set({
          'amountToExceed': 0,
          'exceededAmount': 0,
          'monthYear': monthYear,
        });
      }

      // Update category budget info
      final categoryExpensesSnapshot = await userRef
          .collection('expenses')
          .where('monthYear', isEqualTo: monthYear)
          .where('category', isEqualTo: category)
          .get();

      final totalCategoryExpenses = categoryExpensesSnapshot.docs.fold<int>(
        0,
        (total, doc) => total + (doc['amount'] ?? 0) as int,
      );

      final amountToExceed = totalCategoryBudget - totalCategoryExpenses;
      final exceededAmount =
          amountToExceed < 0 ? totalCategoryExpenses - totalCategoryBudget : 0;

      await categoryBudgetInfoRef.doc(monthYear).set({
        'amountToExceed': amountToExceed,
        'exceededAmount': exceededAmount,
        'monthYear': monthYear,
      }, SetOptions(merge: true));
      if (amountToExceed < 0 && totalCategoryBudget > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$category budget exceeded by $exceededAmount'),
        ));
      }
    }
  }

  Future<void> _updateMonthlyExpenses(
      String monthYear, int expenseAmount) async {
    final monthlyExpensesRef = userRef.collection('MonthlyExpenses');
    final monthDoc = monthlyExpensesRef.doc(monthYear);

    // Use a transaction to update the amount atomically
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(monthDoc);
      if (docSnapshot.exists) {
        // Update existing month document
        final currentAmount = docSnapshot['amount'] as int;
        transaction.update(monthDoc, {'amount': currentAmount + expenseAmount});
      } else {
        // Create new month document if it doesn't exist
        transaction.set(monthDoc, {'amount': expenseAmount});
      }
    });
  }

  Future<void> _updateDailyExpenses(
      String dayMonthYear, int expenseAmount) async {
    final dailyExpensesRef = userRef.collection('DailyExpenses');
    final dayDoc = dailyExpensesRef.doc(dayMonthYear);

    // Use a transaction to update the amount atomically
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(dayDoc);
      if (docSnapshot.exists) {
        // Update existing day document
        final currentAmount = docSnapshot['amount'] as int;
        transaction.update(dayDoc, {'amount': currentAmount + expenseAmount});
      } else {
        // Create new day document if it doesn't exist
        transaction.set(dayDoc, {'amount': expenseAmount});
      }
    });
  }

  Future<void> _updateYearlyExpenses(String year, int expenseAmount) async {
    final yearlyExpensesRef = userRef.collection('YearlyExpenses');
    final yearDoc = yearlyExpensesRef.doc(year);

    // Use a transaction to update the amount atomically
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(yearDoc);
      if (docSnapshot.exists) {
        // Update existing year document
        final currentAmount = docSnapshot['amount'] as int;
        transaction.update(yearDoc, {'amount': currentAmount + expenseAmount});
      } else {
        // Create new year document if it doesn't exist
        transaction.set(yearDoc, {'amount': expenseAmount});
      }
    });
  }

  Future<void> _updateCategoryMonthlyExpenses(
      String monthYear, int expenseAmount) async {
    final categoryMonthlyExpensesRef =
        userRef.collection('${_selectedCategory}month');
    final monthDoc = categoryMonthlyExpensesRef.doc(monthYear);

    // Use a transaction to update the amount atomically
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(monthDoc);
      if (docSnapshot.exists) {
        // Update existing month document
        final currentAmount = docSnapshot['amount'] as int;
        transaction.update(monthDoc, {'amount': currentAmount + expenseAmount});
      } else {
        // Create new month document if it doesn't exist
        transaction.set(monthDoc, {'amount': expenseAmount});
      }
    });
  }

  void _showBudgetExceededAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text('Monthly budget exceeded.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
