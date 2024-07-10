import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as c;
import 'package:xpenso/Models/accountmodel.dart';
import 'package:xpenso/Models/budgetmodel.dart';
import 'package:xpenso/Models/categorymodel.dart';
import 'package:xpenso/Models/transactionmodel.dart';

class FirestoreToHiveSyncService {
  final c.FirebaseFirestore _firestore = c.FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> syncFirestoreToHive() async {
    await syncExpensesFromFirestore();
    await syncCategoriesFromFirestore();
    await syncAccountsFromFirestore();
    await syncBudgetsFromFirestore();
  }

  Future<void> syncExpensesFromFirestore() async {
    final txnBox = Hive.box<Transaction>('transactions');
    final expenseQuerySnapshot = await _firestore
        .collection('User')
        .doc(uid)
        .collection('transactions')
        .get();

    if (expenseQuerySnapshot.docs.isEmpty) {
      print('No expenses found in Firestore.');
      return;
    }

    for (var doc in expenseQuerySnapshot.docs) {
      final data = doc.data();
      final txn = Transaction(
        id: data['id'],
        category: data['category'],
        amount: data['amount'],
        date: (data['date'] as DateTime),
        account: data['account'],
        type: data['type'],
      );

      await txnBox.add(txn);
    }
  }

  Future<void> syncCategoriesFromFirestore() async {
    final categoryBox = Hive.box<Category>('categories');
    final categoryQuerySnapshot =
        await _firestore
        .collection('User')
        .doc(uid)
        .collection('categories').get();

    if (categoryQuerySnapshot.docs.isEmpty) {
      print('No categories found in Firestore.');
      return;
    }

    for (var doc in categoryQuerySnapshot.docs) {
      final data = doc.data();
      final category = Category(
        id: data['id'],
        name: data['name'],
        icon: data['icon'],
      );

      await categoryBox.add(category);
    }
  }

  Future<void> syncAccountsFromFirestore() async {
    final accountBox = Hive.box<Accounts>('Accounts');
    final accountQuerySnapshot =  await _firestore
        .collection('User')
        .doc(uid)
        .collection('Accounts').get();

    if (accountQuerySnapshot.docs.isEmpty) {
      print('No accounts found in Firestore.');
      return;
    }

    for (var doc in accountQuerySnapshot.docs) {
      final data = doc.data();
      final account = Accounts(
        id: data['id'],
        name: data['name'],
        icon: data['icon'],
        bal: data['bal'],
        initbal: data['initbal'],
      );

      await accountBox.add(account);
    }
  }

  Future<void> syncBudgetsFromFirestore() async {
    final budgetBox = Hive.box<Budget>('budgets');
    final budgetQuerySnapshot =  await _firestore
        .collection('User')
        .doc(uid)
        .collection('budgets').get();

    if (budgetQuerySnapshot.docs.isEmpty) {
      print('No budgets found in Firestore.');
      return;
    }

    for (var doc in budgetQuerySnapshot.docs) {
      final data = doc.data();
      final budget = Budget(
          totalBudget: data['totalBudget'],
          categoryBudgets: data['categoryBudgets'],
          month: data['month'],
          year: data['year']);

      await budgetBox.put("$data['month']-$data['year']", budget);
    }
  }
}
