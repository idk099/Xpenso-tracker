import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Records extends StatefulWidget {
  const Records({Key? key}) : super(key: key);

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              )),
        )),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Expense Overview', // Add your desired title text here
                style: TextStyle(
                  letterSpacing: 2,
                  fontSize: 20,
                ),
              ),
            ),
            Expanded(
              child: _buildExpenseList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('expenses')
          .orderBy('added_date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final expenseDocs = snapshot.data?.docs ?? [];
        return ListView.builder(
          itemCount: expenseDocs.length,
          itemBuilder: (context, index) {
            final expenseData =
                expenseDocs[index].data() as Map<String, dynamic>;
            return ExpenseCard(
              category: expenseData['category'],
              amount: expenseData['amount'],
              date: expenseData['added_date'].toDate(),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ExpenseCard extends StatelessWidget {
  final String category;
  final int amount;
  final DateTime date;

  ExpenseCard({
    required this.category,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xff90e0ef),
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.currency_rupee),
        title: Text(category),
        subtitle:
            Text('\₹$amount - ${DateFormat('dd MMMM yyyy').format(date)}'),
      ),
    );
  }
}
