import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CategoryBudgetSettingPage extends StatefulWidget {
  @override
  _CategoryBudgetSettingPageState createState() =>
      _CategoryBudgetSettingPageState();
}

class _CategoryBudgetSettingPageState extends State<CategoryBudgetSettingPage> {
  final TextEditingController _budgetController = TextEditingController();
  late String _currentMonth;
  late int _currentYear;
 List<String> _categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Clothing',
    'Education',
  ];
  
  late DocumentReference userRef;
  late Map<String, int?> _categoryBudgets;
  bool _budgetExists = false;
  final Map<String, IconData> categoryIcons = {
  'Food': Icons.fastfood,
  'Transportation': Icons.directions_car,
  'Entertainment': Icons.movie,
   'Clothing':Icons.accessibility,
    'Education':Icons.book_sharp,
  // Add more categories and icons as needed
};


  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateFormat('MMMM').format(now); // Format to month name
    _currentYear = now.year;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    userRef = FirebaseFirestore.instance.collection('User').doc(uid);
      
   
    _categoryBudgets = Map.fromIterable(_categories,
        key: (category) => category, value: (_) => null);
    _loadCategoryBudgets();
  }

  @override
  Widget build(BuildContext context) {
     double screenWidth = MediaQuery.of(context).size.width;
    double responsivePadding1 = screenWidth * 0.05;
     double screenheight = MediaQuery.of(context).size.height;
    double responsivePadding2 = screenheight * 0.008;
    return Scaffold(
      backgroundColor: Colors.amber,
      resizeToAvoidBottomInset: false,
      
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(responsivePadding1),
            child:StreamBuilder<QuerySnapshot>(
  stream: userRef.collection('categories').snapshots(),
  builder: (context, snapshot) {
     if (!snapshot.hasData || snapshot.data == null ) {
            return Center(
             child: Container(),
            );
          } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else if (snapshot.hasData) {
      final categoriesFromFirestore = snapshot.data!.docs.map((doc) => doc['category'] as String).toList();
      final combinedCategories = [..._categories, ...categoriesFromFirestore];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: combinedCategories.map((category) {
          final budget = _categoryBudgets[category];
          return GestureDetector(
            onTap: () {
              if (_categoryBudgets[category] != null) {
                _showOptionsDialog(category);
              } else {
                _showBudgetDialog(category);
              }
            },
            child: Container(
              padding: EdgeInsets.all(responsivePadding1),
              margin: EdgeInsets.symmetric(vertical: responsivePadding2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(categoryIcons[category] ?? Icons.category),
                      SizedBox(width: 10),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    budget != null ? '$budget' : 'Not Set',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return Text('No data available');
    }
  },
)

          ),
        ),
      ),
    );
  }

  Future<void> _loadCategoryBudgets() async {
    for (String category in _categories) {
      final categoryBudgetRef = userRef
          .collection('${category}budget')
          .doc('$_currentMonth-$_currentYear');
      final docSnapshot = await categoryBudgetRef.get();

      if (docSnapshot.exists) {
        setState(() {
          _categoryBudgets[category] = docSnapshot.data()?['totalBudget'];
        });
      }
    }
  }

  Future<void> _showBudgetDialog(String category, {int? initialAmount}) async {
    int? newBudgetAmount = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Budget for $category'),
          content: TextField(
            controller: _budgetController
              ..text = initialAmount != null ? initialAmount.toString() : '',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter Budget Amount',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int? amount = int.tryParse(_budgetController.text);
                if (amount != null) {
                  Navigator.of(context).pop(amount);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please enter a valid budget amount!'),
                  ));
                }
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );

    if (newBudgetAmount != null) {
      await _saveOrUpdateBudget(category, newBudgetAmount);
    }
  }

  Future<void> _showOptionsDialog(String category) async {
    int? option = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options for $category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Update Budget'),
                onTap: () => Navigator.of(context).pop(1),
              ),
              ListTile(
                title: Text('Delete Budget'),
                onTap: () => Navigator.of(context).pop(2),
              ),
            ],
          ),
        );
      },
    );

    if (option == 1) {
      int? initialAmount =
          _categoryBudgets[category]; // Get initial budget amount
      _showBudgetDialog(category,
          initialAmount: initialAmount); // Pass it to the dialog
    } else if (option == 2) {
      await _deleteBudget(category);
    }
  }

  Future<void> _saveOrUpdateBudget(String category, int budgetAmount) async {
    final categoryBudgetRef =
       userRef.collection('${category}budget');

    // Get the reference to the 'budgets' collection
    final budgetsRef = userRef.collection('budgets');
    final budgetsDocRef = budgetsRef.doc('$_currentMonth-$_currentYear');

    // Check if the 'budgets' document exists
    final budgetsDocSnapshot = await budgetsDocRef.get();

    // If the 'budgets' document exists, check if the total budget exceeds the limit
    if (budgetsDocSnapshot.exists) {
      final totalBudget = budgetsDocSnapshot.data()?['totalBudget'] ?? 0;
      // Calculate the sum of budgets of other categories
     final sumOfOtherCategoryBudgets = _categoryBudgets.values
    .where((value) => value != null && value != budgetAmount && value != _categoryBudgets[category])
    .fold<int>(0, (previousValue, element) => previousValue + (element ?? 0));


      // Calculate the remaining budget after deducting the sum of other category budgets
      final remainingBudget = totalBudget - sumOfOtherCategoryBudgets;

      // Check if the new budget amount exceeds the remaining budget
      if (budgetAmount > remainingBudget) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Monthly budget exceeded!'),
        ));
        return; // Exit the method
      }
    }

    if (_categoryBudgets.containsKey(category)) {
      // If the document exists, update it
      await categoryBudgetRef.doc('$_currentMonth-$_currentYear').set({
        'month': _currentMonth,
        'year': _currentYear,
        'totalBudget': budgetAmount,
      }, SetOptions(merge: true));
      await _updateBudgetInfo(budgetAmount,
          category); // Merge with existing data if the document exists
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Budget for $category updated successfully!'),
      ));
    } else {
      // If the document doesn't exist, create it
      await categoryBudgetRef.doc('$_currentMonth-$_currentYear').set({
        'month': _currentMonth,
        'year': _currentYear,
        'totalBudget': budgetAmount,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Budget for $category saved successfully!'),
      ));
    }
    final budgetInfoRef =
        userRef.collection('${category}budgetinfo');

    final budgetInfoExists = await isCollectionExists('${category}budgetinfo');
    if (!budgetInfoExists) {
      await budgetInfoRef.doc('$_currentMonth-$_currentYear').set({
        'amountToExceed': budgetAmount,
        'exceededAmount': 0,
      });
    }

    setState(() {
      _categoryBudgets[category] = budgetAmount;
    });
  }

  Future<void> _deleteBudget(String category) async {
    final categoryBudgetRef =
        userRef.collection('${category}budget');

    await categoryBudgetRef.doc('$_currentMonth-$_currentYear').delete();

    final categoryBudgetInfoRef = userRef
        .collection('${category}budgetinfo')
        .doc('$_currentMonth-$_currentYear');
    final categoryBudgetInfoSnapshot = await categoryBudgetInfoRef.get();

    if (categoryBudgetInfoSnapshot.exists) {
      await categoryBudgetInfoRef.delete();
    }

    setState(() {
      _categoryBudgets[category] = null;
    });
  }

  Future<void> _updateBudgetInfo(int budgetAmount, String category) async {
  final budgetInfoRef = userRef
      .collection('${category}budgetinfo')
      .doc('$_currentMonth-$_currentYear');
  final budgetInfoSnapshot = await budgetInfoRef.get();
  if (budgetInfoSnapshot.exists) {
    final int currentAmountToExceed = budgetInfoSnapshot['amountToExceed'];
    final int budgetDifference = budgetAmount - (_categoryBudgets[category] ?? 0);
    
    final int updatedAmountToExceed = currentAmountToExceed + budgetDifference;
    final int updatedExceededAmount = updatedAmountToExceed < 0 ? -updatedAmountToExceed : 0;

    await budgetInfoRef.update({
      'amountToExceed': updatedAmountToExceed,
      'exceededAmount': updatedExceededAmount,
    });
  }
}


  Future<bool> isCollectionExists(String collectionPath) async {
    try {
      final collectionRef =
          userRef.collection(collectionPath);
      final snapshot = await collectionRef.get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      // An error occurred, which likely means the collection doesn't exist
      return false;
    }
  }
}
