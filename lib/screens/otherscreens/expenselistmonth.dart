import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ExpenseListPage extends StatefulWidget {
  @override
  _ExpenseListPageState createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  late TextEditingController _amountController;
  late String _selectedMonth;
  late int _selectedYear;
  late List<String> _months;
  late List<int> _years;
  late DocumentReference userRef;
  late String uid;
   List<String> _categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Clothing',
    'Education',
  ];

  late List<String> _availcat = ['All'];

  bool _sortByNewestFirst = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateFormat('MMMM').format(now);
    _selectedYear = now.year;
    _months = DateFormat('MMMM').dateSymbols.MONTHS;
    _years = _generateYears();
     uid = FirebaseAuth.instance.currentUser!.uid;
    userRef = FirebaseFirestore.instance.collection('User').doc(uid);
     _fetchCategories();

    // Initialize the controller here
    _amountController = TextEditingController();
  }

  List<int> _generateYears() {
    final currentYear = DateTime.now().year;
    return List.generate(10, (index) => currentYear - index);
  }

  Stream<List<DocumentSnapshot>> _getExpensesStream() {
    final expensesRef = userRef.collection('expenses');
    final String monthYear = '$_selectedMonth-$_selectedYear';
    Query query = expensesRef.where('monthYear', isEqualTo: monthYear);
    if (_selectedCategory != null) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }
    return query.snapshots().map((querySnapshot) => querySnapshot.docs);
  }

  Stream<DocumentSnapshot> _getCategoryStream(String category) {
    final String monthYear = '$_selectedMonth-$_selectedYear';
    return userRef
        .collection('${category}month')
        .doc(monthYear)
        .snapshots();
  }

  Stream<DocumentSnapshot> _getmonthStream() {
    final String monthYear = '$_selectedMonth-$_selectedYear';
    return userRef
        .collection('MonthlyExpenses')
        .doc(monthYear)
        .snapshots();
  }
  Future<void> _fetchCategories() async {
  final categoriesRef = userRef.collection('categories');
  categoriesRef.snapshots().listen((snapshot) {
    setState(() {
       // Clear the existing categories
       // Add the 'All' category
      final fetchedCategories = snapshot.docs.map((doc) => doc['category'] as String).toList();
      _categories.addAll(fetchedCategories); // Add new categories
    });
  });
}


  @override
  Widget build(BuildContext context) {
     double screenWidth = MediaQuery.of(context).size.width;
    double responsivePadding1 = screenWidth * 0.05;
     double screenheight = MediaQuery.of(context).size.height;
    double responsivePadding2 = screenheight * 0.008;
    return Scaffold(

      backgroundColor: Colors.orange,
      appBar: AppBar(backgroundColor: Colors.orange,
        title: Text('Records',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedMonth,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMonth = newValue!;
                    });
                  },
                  items: _months.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                dropdownColor: Colors.white, // Set the dropdown background color
  underline: SizedBox.shrink(), ),
                SizedBox(width: 20.0),
                DropdownButton<int>(
                  value: _selectedYear,
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedYear = newValue!;
                    });
                  },
                  items: _years.map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                 dropdownColor: Colors.white, 
  underline: SizedBox.shrink(),),
                SizedBox(
                  width: 20,
                ),
                _buildFilterButton(),
                SizedBox(
                  width: 5,
                ),
                IconButton(
                  icon: Icon(_sortByNewestFirst
                      ? Icons.arrow_downward
                      : Icons.arrow_upward),
                  onPressed: () {
                    setState(() {
                      _sortByNewestFirst = !_sortByNewestFirst;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20.0),
            StreamBuilder<DocumentSnapshot>(
                stream: _getmonthStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Container();
                  }
                  final totalAmount = snapshot.data?['totalAmount'] ?? 0;
                  return Center(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Total  \u{20B9}$totalAmount',
                          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                }),
            SizedBox(height: 10.0),
           
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: _getExpensesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                 
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No expenses found.'));
                  }
                  List<DocumentSnapshot> expenses = snapshot.data!;
                  if (_sortByNewestFirst) {
                    expenses.sort((a, b) => (b['date'] as Timestamp)
                        .compareTo(a['date'] as Timestamp));
                  } else {
                    expenses.sort((a, b) => (a['date'] as Timestamp)
                        .compareTo(b['date'] as Timestamp));
                  }
                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];

                      return Dismissible(
                        key: Key(expense.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: responsivePadding1),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Confirm'),
                              content: Text(
                                  'Are you sure you want to delete this entry?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) => _deleteEntry(expense),
                        child: Container(
                          decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10.0),
        ), margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: EdgeInsets.all(10.0),
                          child: GestureDetector(
                            onTap: () => _showEditExpenseDialog(expense),
                            child: ListTile(
                              title: Text(expense['category'],style: TextStyle(fontWeight: FontWeight.bold),),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Amount: ₹ ${expense['amount']}'),
                                  Text(
                                      'Date: ${DateFormat.yMMMd().format(expense['date'].toDate())}'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.filter_list),
      itemBuilder: (BuildContext context) {
        return _availcat.map((String category) {
          return PopupMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList();
      },
      onSelected: (String? selectedCategory) {
        setState(() {
          _selectedCategory =
              selectedCategory == 'All' ? null : selectedCategory;
        });
      },
    );
  }

  Future<void> _deleteEntry(DocumentSnapshot expense) async {
    final expenseRef =
        userRef.collection('expenses').doc(expense.id);
    final monthYear = expense['monthYear'] as String;
    final amount = expense['amount'] as int;
    final category = expense['category'] as String;
    final formattedDate = DateFormat('d-MMMM-yyyy').format(expense['date'].toDate());

    await expenseRef.delete();

    // Update budget info based on the deleted entry
    await _updateBudgetInfo(monthYear, amount, subtract: true);
    // Update category budget info based on the deleted entry
    await _updateCategoryBudgetInfo(monthYear, amount, category,
        subtract: true);
    
         await _updateMonthlyExpenses(monthYear, amount, subtract: true);
        

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Entry deleted.')),
    );
  }
  
Future<void> _updateMonthlyExpenses(String monthYear, int expenseAmount, {bool subtract = false}) async {
  final monthlyExpensesRef = userRef.collection('MonthlyExpenses').doc(monthYear);
  
  final monthlyExpensesSnapshot = await monthlyExpensesRef.get();
  if (monthlyExpensesSnapshot.exists) {
    final monthlyExpensesData = monthlyExpensesSnapshot.data() as Map<String, dynamic>;
    int totalAmount = monthlyExpensesData['totalAmount'] ?? 0;
    
    if (subtract) {
      totalAmount -= expenseAmount;
    } else {
      totalAmount += expenseAmount;
    }
    
    await monthlyExpensesRef.set({
      'totalAmount': totalAmount,
      'monthYear': monthYear,
    });
  }
}


  Future<void> _updateBudgetInfo(String monthYear, int expenseAmount,
      {bool subtract = false}) async {
    final budgetInfoRef =
        userRef.collection('budgetinfo').doc(monthYear);

    final budgetInfoSnapshot = await budgetInfoRef.get();
    if (!budgetInfoSnapshot.exists)
      return; // No budget info for this month, nothing to update

    int amountToExceed = budgetInfoSnapshot['amountToExceed'];
    if (subtract) {
      amountToExceed += expenseAmount; // Change to subtract
    } else {
      amountToExceed -= expenseAmount; // Change to add
    }

    await budgetInfoRef.set({
      'amountToExceed': amountToExceed,
      'exceededAmount': amountToExceed < 0
          ? -amountToExceed
          : 0, // If negative, set exceededAmount
      'monthYear': monthYear,
    });
  }

  Future<void> _updateCategoryBudgetInfo(
      String monthYear, int expenseAmount, String category,
      {bool subtract = false}) async {
    final categoryBudgetInfoRef = userRef
        .collection('${category}budgetinfo')
        .doc(monthYear);

    final categoryBudgetInfoSnapshot = await categoryBudgetInfoRef.get();
    if (!categoryBudgetInfoSnapshot.exists)
      return; // No category budget info for this month, nothing to update

    int categoryAmountToExceed = categoryBudgetInfoSnapshot['amountToExceed'];
    if (subtract) {
      categoryAmountToExceed += expenseAmount; // Change to subtract
    } else {
      categoryAmountToExceed -= expenseAmount; // Change to add
    }

    await categoryBudgetInfoRef.set({
      'amountToExceed': categoryAmountToExceed,
      'exceededAmount': categoryAmountToExceed < 0
          ? -categoryAmountToExceed
          : 0, // If negative, set exceededAmount
      'monthYear': monthYear,
    });
  }

 

  void _showEditExpenseDialog(DocumentSnapshot expense) {
    print(expense['amount']);
    _amountController =
        TextEditingController(text: expense['amount'].toString());
    String editedCategory = expense['category'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit Expense'),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: editedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          editedCategory = newValue!;
                        });
                      },
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                     Navigator.pop(context);
                  
                    _updateEntry(expense, editedCategory, expense['amount']);

                  },
                  child: Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  
  Future<void> _updateBudgetInfoonedit(
      String monthYear, int expenseAmount, String category,
      {bool subtract = false}) async {
    final budgetRef =
        userRef.collection('budgets').doc(monthYear);
    final budgetInfoRef =
       userRef.collection('budgetinfo').doc(monthYear);
    final categoryBudgetRef = userRef
        .collection('${category}budget')
        .doc(monthYear);
    final categoryBudgetInfoRef = userRef
        .collection('${category}budgetinfo')
        .doc(monthYear);

    final budgetSnapshot = await budgetRef.get();
    if (!budgetSnapshot.exists)
      return; // No budget for this month, nothing to update

    final budgetData = budgetSnapshot.data() as Map<String, dynamic>;
    final totalBudget = budgetData['totalBudget'] as int;

    final budgetInfoSnapshot = await budgetInfoRef.get();
    final categoryBudgetInfoSnapshot = await categoryBudgetInfoRef.get();

    int amountToExceed = budgetInfoSnapshot.exists
        ? budgetInfoSnapshot['amountToExceed']
        : totalBudget;
    int categoryAmountToExceed = categoryBudgetInfoSnapshot.exists
        ? categoryBudgetInfoSnapshot['amountToExceed']
        : 0;

    if (subtract) {
      amountToExceed += expenseAmount;
      categoryAmountToExceed += expenseAmount;
    } else {
      amountToExceed -= expenseAmount;
      categoryAmountToExceed -= expenseAmount;
    }

    await budgetInfoRef.set({
      'amountToExceed': amountToExceed,
      'exceededAmount': amountToExceed < 0
          ? -amountToExceed
          : 0, // If negative, set exceededAmount
      'monthYear': monthYear,
    });

    await categoryBudgetInfoRef.set({
      'amountToExceed': categoryAmountToExceed,
      'exceededAmount': categoryAmountToExceed < 0
          ? -categoryAmountToExceed
          : 0, // If negative, set exceededAmount
      'monthYear': monthYear,
    });
  }
  Future<void> _updateEntry(DocumentSnapshot expense, String category, int oldAmount) async {
  final amount = int.tryParse(_amountController.text);
  if (amount != null) {
    final expenseRef =
        userRef.collection('expenses').doc(expense.id);
final formattedDate = DateFormat('d-MMMM-yyyy').format(expense['date'].toDate());
    final DocumentSnapshot oldExpenseSnapshot = await expenseRef.get();
    final oldExpenseData = oldExpenseSnapshot.data() as Map<String, dynamic>;
    final monthYear = oldExpenseData['monthYear'] as String;
   
     
      final oldAmount = oldExpenseData['amount'] as int;
      final oldCategory = oldExpenseData['category'] as String;
     

    await expenseRef.update({
      'amount': amount,
      'category': category,
      // Update other fields as needed
    });

    // Update MonthlyExpenses based on old and new amounts
    await _updateMonthlyExpenses(monthYear, oldAmount, subtract: true);
    await _updateMonthlyExpenses(monthYear, amount);
   
      await _updateBudgetInfoonedit(monthYear, oldAmount, oldCategory,
          subtract: true);
      await _updateBudgetInfoonedit(monthYear, amount, category);
    


    
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter a valid amount!')),
    );
  }
  
}

}
