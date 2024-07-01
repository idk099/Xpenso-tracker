import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category Expenses'),
      ),
      body: CategoryListStream(),
    );
  }
}

class CategoryListStream extends StatelessWidget {
  const CategoryListStream({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Text('User not signed in'),
      );
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .collection('expenses')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Check if the expenses collection exists and is not empty
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox(); // Return an empty container if the collection does not exist or is empty
        }

        Set<String> categorySet = {};
        String currentMonthYear =
            DateFormat('MMMM-yyyy').format(DateTime.now());

        snapshot.data!.docs.forEach((doc) {
          String category = doc['category'];
          categorySet.add(category);
        });

        return ListView.builder(
          itemCount: categorySet.length,
          itemBuilder: (context, index) {
            String category = categorySet.elementAt(index);
            return CategoryTile(
              category: category,
              currentMonthYear: currentMonthYear,
            );
          },
        );
      },
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String category;
  final String currentMonthYear;

  const CategoryTile({
    Key? key,
    required this.category,
    required this.currentMonthYear,
  }) : super(key: key);

  // Define a map to associate categories with icons
  static const Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Education': Icons.school,
    'Entertainment': Icons.movie,
    'Clothing': Icons.shopping_bag,
  };

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return SizedBox();
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .collection('${category}budget')
          .doc(currentMonthYear)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> budgetSnapshot) {
        if (budgetSnapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(); // Return an empty container while waiting for data
        }

        // Check if the budget document exists
        if (!budgetSnapshot.hasData || !budgetSnapshot.data!.exists) {
          return SizedBox(); // Return an empty container if the document does not exist
        }

        int budget = (budgetSnapshot.data!.data()
                as Map<String, dynamic>?)?['totalBudget'] ??
            0;

        // Check if budget is greater than 0

        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('User')
              .doc(user.uid)
              .collection('category_expenses')
              .doc(currentMonthYear)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> expensesSnapshot) {
            if (expensesSnapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(); // Return an empty container while waiting for data
            }

            // Check if the expenses document exists
            if (!expensesSnapshot.hasData || !expensesSnapshot.data!.exists) {
              return SizedBox(); // Return an empty container if the document does not exist
            }

            double expenses = (expensesSnapshot.data!.data()
                    as Map<String, dynamic>?)?[category] ??
                0;
            double exceededAmount = expenses - budget;
            double progress = budget != 0.0 ? expenses / budget : 0.0;

            // Determine the icon for the category
            IconData? categoryIcon = categoryIcons[category];

            return Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        categoryIcon ??
                            Icons
                                .category, 
                        size: 32,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 16),
                      Text(
                        category,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300]!,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 8),
                  Text(
                    exceededAmount > 0
                        ? 'Exceeded by: ₹ ${exceededAmount.toStringAsFixed(2)}'
                        : 'Remaining: ₹ ${(budget - expenses).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: exceededAmount > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                  Text(
                    'Limit: ₹ ${budget.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: exceededAmount > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Widget categorylist() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection('expenses')
        .snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      // Check if the expenses collection exists and is not empty
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return SizedBox(); // Return an empty container if the collection does not exist or is empty
      }

      Set<String> categorySet = {};
      String currentMonthYear = DateFormat('MMMM-yyyy').format(DateTime.now());

      snapshot.data!.docs.forEach((doc) {
        String category = doc['category'];
        categorySet.add(category);
      });

      return ListView.builder(
        itemCount: categorySet.length,
        itemBuilder: (context, index) {
          String category = categorySet.elementAt(index);
          return CategoryTile(
            category: category,
            currentMonthYear: currentMonthYear,
          );
        },
      );
    },
  );
}

class ExpenseTile extends StatelessWidget {
  final String category;
  final String uid;


  const ExpenseTile({super.key, required this.category, required this.uid});
       

  @override
  Widget build(BuildContext context) {
    String currentMonthYear = DateFormat('MMMM-yyyy').format(DateTime.now());
 const Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Education': Icons.school,
    'Entertainment': Icons.movie,
    'Clothing': Icons.shopping_bag,
  };

    return StreamBuilder(









      
      stream: FirebaseFirestore.instance
          .collection('User')
          .doc(uid)
          .collection('category_expenses')
          .doc(currentMonthYear)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      

        if (!snapshot.hasData || !snapshot.data!.exists) {
         Container();
        }

        // Get the monthly expenses for the category
        double expense =
            (snapshot.data!.data() as Map<String, dynamic>?)?[category] ?? 0;
 IconData? categoryIcon = categoryIcons[category];
        return Row(
          children: [
             Icon(
                        categoryIcon ??
                            Icons
                                .category, 
                        size: 16,
                        color: Colors.blue,
                      ),
  
  
            Text(' $category: ',style: TextStyle(fontWeight: FontWeight.bold),),
            Text('₹ ${expense.toStringAsFixed(2)}')
          ],
        );

        ListTile(
          title: Text(category),
          subtitle: Text('Expense: \$${expense.toStringAsFixed(2)}'),
        );
      },
    );
  }
}
