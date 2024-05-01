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
        backgroundColor: Colors.blue,
        title: Text(
          'Records',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: Color(0xffcaf0f8),
        child: Column(
          children: [
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
        leading: Icon(Icons.attach_money),
        title: Text(category),
        subtitle:
            Text('\$$amount - ${DateFormat('dd MMMM yyyy').format(date)}'),
      ),
    );
  }
}
