import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:xpenso/screens/otherscreens/addtxnscreen.dart';
import 'package:xpenso/services/Provider/transactionservices.dart';
import 'package:xpenso/services/authenticate.dart';
import 'package:xpenso/widgets/customscaffold.dart';

class HomeScreen extends StatelessWidget {
  final String _formattedDate = DateFormat("MMMM-yyyy").format(DateTime.now());

  HomeScreen({super.key});
  final Authenticate _auth = Authenticate();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userRef = FirebaseFirestore.instance.collection('User').doc(uid);
    var txn = Provider.of<TransactionServices>(context, listen: true);
    return CustomScaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddPage()),
        ),
        child: Icon(Icons.add),
      ),
      showiconbutton: true,
      signout: () {
        signOutDialog(context);
      },
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: 78,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: userRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
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
                        padding: EdgeInsets.all(16),
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
            _formattedDate,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Container(
            // Ensures the GridView has a bounded height
            height: 320,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.8),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_down,
                              color: Colors.red,
                            ),
                            Text(
                              " Total Expense ",
                              style: TextStyle(
                                fontSize: 21,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹ ${txn.getTotalExpenseForCurrentMonth()}',
                          style: TextStyle(fontSize: 21, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.8),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_up_outlined,
                              color: Colors.green,
                            ),
                            Text(
                              " Total Income ",
                              style: TextStyle(
                                fontSize: 21,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹ ${txn.getTotalIncomeForCurrentMonth()}',
                          style: TextStyle(fontSize: 21, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),

                  SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.8),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.savings,
                              color: Colors.pink,
                            ),
                            Text(
                               "Savings" ,
                              style: TextStyle(
                                fontSize: 21,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹ ${txn.getSavingsCurrentMonth()}',
                          style: TextStyle(fontSize: 21, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),








               



















              

              ],
            ),
          ),
        ],
      ),
    );
  }

  void signOutDialog(context) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
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
