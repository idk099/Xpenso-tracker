import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:xpenso/screens/otherscreens/addcategory.dart';
import 'package:xpenso/screens/otherscreens/addexpense.dart';

import 'package:xpenso/services/authenticate.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Authenticate _auth = Authenticate();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userRef = FirebaseFirestore.instance.collection('User').doc(uid);
    final currentMonth = DateFormat('MMMM-yyyy')
        .format(DateTime.now()); // Format current month using intl package
    final monthlyExpensesRef =
        userRef.collection('MonthlyExpenses').doc(currentMonth);

    double screenWidth = MediaQuery.of(context).size.width;
    double responsivePadding = screenWidth * 0.05;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue,
      appBar: AppBar(
        flexibleSpace: Center(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 30,
            ),
            child: SizedBox(
              height: 120,
              child: Image.asset(
                'assets/images/appbarlogo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app_sharp,
              color: Colors.white,
            ),
            onPressed: () async {
              signOutDialog();
            },
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(children: [
              Container(
                height: 50000,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          height: 78,
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: userRef.snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  snapshot.hasError ||
                                  !snapshot.hasData ||
                                  !snapshot.data!.exists) {
                                return SizedBox(
                                  height: 30,
                                );
                              }

                              final userName = snapshot.data!['Name'];

                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(responsivePadding),
                                  child: SizedBox(
                                    height: 40,
                                    child: Text(
                                      'Hello, $userName',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'This month ${DateFormat('MMMM-yyyy').format(DateTime.now())}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: responsivePadding),
                      child: Expanded(
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: monthlyExpensesRef.snapshots(),
                              builder: (context, snapshot) {
                                // Handling loading state
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.trending_down,
                                              size: 30,
                                              color: Colors.green,
                                            ),
                                            Text(
                                              ' Expense',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          '₹ 0',
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // Handling case where no data or collection does not exist
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.trending_down,
                                              size: 30,
                                              color: Colors.red,
                                            ),
                                            Text(
                                              ' Expense',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          '₹ 0',
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                final totalExpense =
                                    snapshot.data!['totalAmount'];

                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.trending_down,
                                            size: 30,
                                            color: Colors.red,
                                          ),
                                          Text(
                                            ' Expense',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '₹ $totalExpense',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: responsivePadding),
                      child: Container(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('User')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('budgets')
                              .doc(_getCurrentMonthYear())
                              .snapshots(),
                          builder: (context, budgetSnapshot) {
                            if (!budgetSnapshot.hasData ||
                                budgetSnapshot.data == null) {
                              return Container(); // Return empty container if budget collection does not exist
                            }
                            var budgetData = budgetSnapshot.data;
                            if (budgetData!.exists) {
                              double totalBudget =
                                  (budgetData!['totalBudget'] ?? 0).toDouble();

                              return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('User')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('MonthlyExpenses')
                                    .doc(_getCurrentMonthYear())
                                    .snapshots(),
                                builder: (context, expenseSnapshot) {
                                  if (!expenseSnapshot.hasData ||
                                      expenseSnapshot.data == null ||
                                      !expenseSnapshot.data!.exists) {
                                    return Container(); // Return empty container if monthly expenses collection does not exist
                                  }
                                  var expenseData = expenseSnapshot.data;
                                  double totalExpenses =
                                      (expenseData!['totalAmount'] ?? 0)
                                          .toDouble();

                                  double exceededAmount =
                                      totalExpenses - totalBudget;
                                  bool isBudgetExceeded = exceededAmount > 0;
                                  double remainingAmount =
                                      totalBudget - totalExpenses;

                                  // Calculate progress percentage
                                  double progress =
                                      (totalExpenses / totalBudget)
                                          .clamp(0.0, 1.0);

                                  return Container(
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Monthly Budget',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isBudgetExceeded)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.red.withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Exceeded by ₹ ${exceededAmount.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${totalExpenses.toStringAsFixed(2)} / ${totalBudget.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.grey[800],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  LinearProgressIndicator(
                                                    minHeight: 20,
                                                    value: progress,
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (!isBudgetExceeded)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                children: [
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      'Remaining ₹ ${remainingAmount.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${totalExpenses.toStringAsFixed(2)} / ${totalBudget.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.grey[800],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  LinearProgressIndicator(
                                                    minHeight: 20,
                                                    value: progress,
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  
                  ],
                ),
              ),
            ]),
            Positioned(
              bottom: responsivePadding,
              right: responsivePadding,
              child: SpeedDial(
                activeIcon: Icons.close,
                icon: Icons.add,
                backgroundColor: Colors.white,
                overlayOpacity: 0.1,
                direction: SpeedDialDirection.up,
                children: [
                  SpeedDialChild(
                    child: Icon(Icons.category),
                    label: 'Add category',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCategoryPage(),
                        ),
                      );
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.receipt),
                    label: 'Add expense',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddExpensePage(),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentMonthYear() {
    DateTime now = DateTime.now();
    return '${DateFormat('MMMM-yyyy').format(now)}';
  }

  Future<void> signOutDialog() async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Center(child: Text('CONFIRM')),
        content: Text('Are you sure want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _auth.siginOut();
            },
            child: Text('Signout'),
          ),
        ],
      ),
    );
  }
}

