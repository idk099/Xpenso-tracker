import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

class BudgetSettingPage extends StatefulWidget {
  @override
  _BudgetSettingPageState createState() => _BudgetSettingPageState();
}

class _BudgetSettingPageState extends State<BudgetSettingPage> {
  final TextEditingController _budgetController = TextEditingController();
  late String _currentMonth;
  late int _currentYear;
  late String _uid = '';
  late DocumentReference userRef;
  bool _budgetExists = false;
  int? _existingBudget;
  List<String> categories = [ 'Food',
    'Transportation',
    'Entertainment',
    'Clothing',
    'Education',];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateFormat('MMMM').format(now); // Format to month name
    _currentYear = now.year;
    _uid = FirebaseAuth.instance.currentUser!.uid;
    userRef = FirebaseFirestore.instance.collection('User').doc(_uid);
    _checkExistingBudget();
     _fetchCategories();
  }
  Future<void> _fetchCategories() async {
  final categoriesSnapshot = await userRef.collection('categories').get();
  setState(() {
    final fetchedCategories = categoriesSnapshot.docs.map((doc) => doc['category'] as String).toList();
    categories.addAll(fetchedCategories);
   
  });
}
  

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double responsivePadding1 = screenWidth * 0.05;
     double screenheight = MediaQuery.of(context).size.height;
    double responsivePadding2 = screenheight * 0.008;
    
    return Scaffold(
      backgroundColor: Colors.amber,
      resizeToAvoidBottomInset:false ,
     
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(responsivePadding1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              SizedBox(height: 20.0),
              Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8.0),
  ),
  padding: EdgeInsets.symmetric(vertical: responsivePadding1),
  child: ListTile(
    title: Text(
      '$_currentMonth-$_currentYear',
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
      ),
    ),
    trailing: _budgetExists
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹ $_existingBudget',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                onPressed: _deleteBudgetDocument,
                icon: Icon(Icons.delete),
                color: Colors.red,
                tooltip: 'Delete Budget',
              ),
              IconButton(
                onPressed: _updateBudget1,
                icon: Icon(Icons.edit),
                color: Colors.black,
                tooltip: 'Update Budget',
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Set Budget',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: TextField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Total Budget',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _saveOrUpdateBudget();
                              Navigator.pop(context);
                            },
                            child: Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Set Budget'),
              ),
            ],
          ),
  ),
),

              SizedBox(height: 20.0),
              SizedBox(height: 20.0),
              Text(
                'Previous Month Budgets',
                style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
            Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('User')
        .doc(_uid)
        .collection('budgets')
        .snapshots(),
    builder: (context, snapshot) {
       if (!snapshot.hasData || snapshot.data == null ) {
            return Center(
             child: Container(),
            );
          }
else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        final List<Map<String, dynamic>> previousMonthBudgets = [];

        // Filter out the current month's data
        final now = DateTime.now();
        final currentMonth = DateFormat('MMMM').format(now);
        final currentYear = now.year;

        snapshot.data!.docs.forEach((doc) {
          final String month = doc['month'];
          final int totalBudget = doc['totalBudget'];
          final int year = doc['year'];

          if (month != currentMonth) {
            // Only add data for months other than the current month
            previousMonthBudgets.add({
              'month': month,
              'totalBudget': totalBudget,
              'year': year
            });
          }
        });

        if (previousMonthBudgets.isEmpty) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                'No data available',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: previousMonthBudgets.length,
          itemBuilder: (context, index) {
            final budgetData = previousMonthBudgets[index];
            final String month = budgetData['month'];
            final int budget = budgetData['totalBudget'];
            final int year = budgetData['year'];

            return Container(
              margin: EdgeInsets.symmetric(vertical:responsivePadding2),
              padding: EdgeInsets.all(responsivePadding1),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                title: Text(
                  '$month-$year',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Total Budget: ₹ $budget',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                ),
               
              ),
            );
          },
        );
      } else {
        return Text('No data available');
      }
    },
  ),
),

            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkExistingBudget() async {
    final budgetRef = FirebaseFirestore.instance
        .collection('User')
        .doc(_uid)
        .collection('budgets');
    final docSnapshot =
        await budgetRef.doc('$_currentMonth-$_currentYear').get();

    if (docSnapshot.exists) {
      setState(() {
        _budgetExists = true;
        _existingBudget = docSnapshot.data()?['totalBudget'];
      });
    }
  }

  Future<int?> _fetchTotalCategoryBudget() async {
    int totalBudget = 0;

    for (String category in categories) {
      final categoryBudgetRef = FirebaseFirestore.instance
          .collection('User')
          .doc(_uid)
          .collection('${category}budget')
          .doc('$_currentMonth-$_currentYear');
      final categoryBudgetSnapshot = await categoryBudgetRef.get();
      if (categoryBudgetSnapshot.exists) {
        totalBudget +=
            (categoryBudgetSnapshot.data()?['totalBudget'] ?? 0) as int;
      }
    }
    return totalBudget;
  }

  Future<void> _saveOrUpdateBudget() async {
    final budgetAmount = int.tryParse(_budgetController.text);
    _budgetController.clear();
    if (budgetAmount != null) {
      final totalCategoryBudget = await _fetchTotalCategoryBudget();
      if (totalCategoryBudget == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Failed to fetch total category budget. Please try again.'),
        ));
        return;
      }
      if (budgetAmount < totalCategoryBudget) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Entered amount is less than the total category-wise budget.'),
        ));
        return;
      }
 setState(() {
        _budgetExists = true;
        _existingBudget = budgetAmount;
      });
      final budgetRef = FirebaseFirestore.instance
          .collection('User')
          .doc(_uid)
          .collection('budgets');
      final budgetInfoRef = FirebaseFirestore.instance
          .collection('User')
          .doc(_uid)
          .collection('budgetinfo');

      final budgetDocId = '$_currentMonth-$_currentYear';

      await budgetRef.doc(budgetDocId).set({
        'month': _currentMonth,
        'year': _currentYear,
        'totalBudget': budgetAmount,
      });
      

      // Check if budgetinfo collection exists, if not create it and set initial fields
      final budgetInfoExists = await isCollectionExists('budgetinfo');
      if (!budgetInfoExists) {
        await budgetInfoRef.doc(budgetDocId).set({
          'amountToExceed': 0,
          'exceededAmount': 0,
        });
      }
       await _updateBudgetInfo(budgetAmount);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Budget saved successfully!'),
      ));
      
     
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid budget amount!'),
      ));
    }
  }


  Future<void> _updateBudgetInfo(int budgetAmount) async {
    final budgetInfoRef = FirebaseFirestore.instance
        .collection('User')
        .doc(_uid)
        .collection('budgetinfo')
        .doc('$_currentMonth-$_currentYear');
    final budgetInfoSnapshot = await budgetInfoRef.get();
    if (budgetInfoSnapshot.exists) {
      final int currentAmountToExceed =
          budgetInfoSnapshot['amountToExceed'] ?? 0;
      final int updatedAmountToExceed =
          currentAmountToExceed + (budgetAmount - (_existingBudget ?? 0));
      await budgetInfoRef.update({
        'amountToExceed': updatedAmountToExceed,
        'exceededAmount':
            updatedAmountToExceed < 0 ? -updatedAmountToExceed : 0,
      });
    }
  }

  Future<void> _deleteBudgetDocument() async {
    final budgetRef = FirebaseFirestore.instance
        .collection('User')
        .doc(_uid)
        .collection('budgets');
    final budgetInfoRef = FirebaseFirestore.instance
        .collection('User')
        .doc(_uid)
        .collection('budgetinfo');

    final budgetDocId = '$_currentMonth-$_currentYear';

    await budgetRef.doc(budgetDocId).delete();
    await budgetInfoRef.doc(budgetDocId).delete();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Budget document deleted successfully!'),
    ));

    setState(() {
      _budgetExists = false;
      _existingBudget = null;
    });
  }

  Future<bool> isCollectionExists(String collectionPath) async {
    try {
      final collectionRef = FirebaseFirestore.instance
          .collection('User')
          .doc(_uid)
          .collection(collectionPath);
      final snapshot = await collectionRef.get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      // An error occurred, which likely means the collection doesn't exist
      return false;
    }
  }

  void _updateBudget1() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Budget'),
          content: TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Total Budget',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveOrUpdateBudget();
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

 
}
