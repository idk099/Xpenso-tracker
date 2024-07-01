import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassName {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  late DocumentReference userRef =
      FirebaseFirestore.instance.collection('User').doc(uid);

  Future<void> calculateAndStoreCategoryExpenses() async {
    // Access Firestore collection 'expenses'
    CollectionReference expensesCollection =
       userRef.collection('expenses');

    try {
      // Get all documents from the 'expenses' collection
      QuerySnapshot expensesSnapshot = await expensesCollection.get();

      if (expensesSnapshot.docs.isEmpty) {
        print('No expenses found.');
        return;
      }

      // Initialize a map to store category monthly expenses
      Map<String, Map<String, double>> categoryExpenses = {};

      // Loop through each document in the 'expenses' collection
      for (QueryDocumentSnapshot expenseDoc in expensesSnapshot.docs) {
        Map<String, dynamic>? data = expenseDoc.data() as Map<String, dynamic>?;

        // Extract monthYear, category, and amount from the document
        String monthYear = data!['monthYear'];
        String category = data['category'];
       double expenseAmount = (data['amount'] ?? 0).toDouble();


        // Ensure categoryExpenses[monthYear] is initialized
        categoryExpenses[monthYear] ??= {};
        // Increment the total expense for the category in that month
        categoryExpenses[monthYear]![category] =
            (categoryExpenses[monthYear]![category] ?? 0.0) + expenseAmount;

        // Additional logging to check the extracted data
        print(
            'Processed expense: monthYear=$monthYear, category=$category, amount=$expenseAmount');
      }

      // Access Firestore collection 'category_expenses'
      CollectionReference categoryExpensesCollection =
          userRef.collection('category_expenses');
      print(categoryExpenses);

      // Loop through the category expenses map and store it in Firestore
      categoryExpenses.forEach((monthYear, categoryData) async {
        await categoryExpensesCollection.doc(monthYear).set(categoryData);
      });

      print('Category expenses stored successfully.');
    } catch (e) {
      print('Error: $e');
    }
  }
}
