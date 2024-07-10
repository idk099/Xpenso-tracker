import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as c;
import 'package:xpenso/Models/accountmodel.dart';
import 'package:xpenso/Models/budgetmodel.dart';
import 'package:xpenso/Models/categorymodel.dart';

import 'package:xpenso/Models/transactionmodel.dart';

class Syncservices {
 String? uid = FirebaseAuth.instance.currentUser?.uid;
  void activate() {
    syncHiveToFirestoreOnStart();
    expenseListener();
    categoryListener();
    accountsListener();
    budgetListener();
  }

  void expenseListener() {
    final tbox = Hive.box<Transaction>('transactions');
    final box1 = Hive.box('fexpdel');
    final box2 = Hive.box('fexpadd');

    tbox.watch().listen((BoxEvent event) async {
      if (!event.deleted) {
        final txn = tbox.get(event.key);

        Map<String, dynamic> addmap = {
          'id': txn!.id,
          'category': txn.category,
          'amount': txn.amount,
          'date': txn.date,
          'account': txn.account,
          'type': txn.type,
        };

        box2.add(addmap);

        if (await isConnected()) {
          int i = 0;
          List addlist = box2.values.toList();
          for (var value in addlist) {
            try {
              await syncTxnToFirestore(value);
              await box2.deleteAt(i);
              i++;
            } catch (e) {}
          }
          print('Finished syncing');
        }
      }
      if (await isConnected() && event.deleted) {
        int i = 0;
        List deletelist = box1.values.toList();
        for (var id in deletelist) {
          await deleteTxnFromFirestore(id.toString());
          await box1.deleteAt(i);
          i++;
        }
        print('Finished deletion');
      }
    });
  }

  void categoryListener() {
    final cbox = Hive.box<Category>('categories');
    final box3 = Hive.box('fcatadd');
    final box4 = Hive.box('fcatdel');

    cbox.watch().listen((BoxEvent event) async {
      if (!event.deleted) {
        final cat = cbox.get(event.key);

        Map<String, dynamic> addmap = {
          'id': cat!.id,
          'name': cat.name,
          'icon': cat.icon,
        };

        box3.add(addmap);

        if (await isConnected()) {
          int i = 0;
          List addlist = box3.values.toList();
          for (var value in addlist) {
            try {
              await syncCategoryToFirestore(value);
              await box3.deleteAt(i);
              i++;
            } catch (e) {}
          }
          print('Finished syncing categories');
        }
      }
      if (await isConnected() && event.deleted) {
        int i = 0;
        List deletelist = box4.values.toList();
        for (var id in deletelist) {
          await deleteCategoryFromFirestore(id.toString());
          await box4.deleteAt(i);
          i++;
        }
        print('Finished category deletion');
      }
    });
  }

  void accountsListener() {
    final abox = Hive.box<Accounts>('Accounts');
    final box5 = Hive.box('facadd');
    final box6 = Hive.box('facdel');

    abox.watch().listen((BoxEvent event) async {
      if (!event.deleted) {
        final account = abox.get(event.key);

        Map<String, dynamic> addmap = {
          'id': account!.id,
          'name': account.name,
          'icon': account.icon,
          'bal': account.bal,
          'initbal': account.initbal,
        };

        box5.add(addmap);

        if (await isConnected()) {
          int i = 0;
          List addlist = box5.values.toList();
          for (var value in addlist) {
            try {
              await syncAccountToFirestore(value);
              await box5.deleteAt(i);
              i++;
            } catch (e) {}
          }
          print('Finished syncing accounts');
        }
      }
      if (await isConnected() && event.deleted) {
        int i = 0;
        List deletelist = box6.values.toList();
        for (var id in deletelist) {
          await deleteAccountFromFirestore(id.toString());
          await box6.deleteAt(i);
          i++;
        }
        print('Finished account deletion');
      }
    });
  }

  void budgetListener() {
    final bbox = Hive.box<Budget>('budgets');
    final box7 = Hive.box('fbudadd');
    final box8 = Hive.box('fbuddel');

    bbox.watch().listen((BoxEvent event) async {
      if (!event.deleted) {
        final budget = bbox.get(event.key);

        Map<String, dynamic> addmap = {
          'totalBudget': budget!.totalBudget,
          'categoryBudgets': budget.categoryBudgets,
          'month': budget.month,
          'year': budget.year
        };

        box7.add(addmap);

        if (await isConnected()) {
          int i = 0;
          List addlist = box7.values.toList();
          for (var value in addlist) {
            try {
              await syncBudgetToFirestore(value);
              await box7.deleteAt(i);
              i++;
            } catch (e) {}
          }
          print('Finished syncing budgets');
        }
      }
      if (await isConnected() && event.deleted) {
        int i = 0;
        List deletelist = box8.values.toList();
        for (var id in deletelist) {
          await deleteBudgetFromFirestore(id.toString());
          await box8.deleteAt(i);
          i++;
        }
        print('Finished budget deletion');
      }
    });
  }

  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  void syncHiveToFirestoreOnStart() {
    addFirestore('fexpadd');
    deleteFirestore('fexpdel');
    addFirestore('facadd');
    deleteFirestore('facdel');
    addFirestore('fcatadd');
    deleteFirestore('fcatdel');
    addFirestore('fbudadd');
    deleteFirestore('fbuddel');
  }

  Future<void> addFirestore(String name) async {
    final box = Hive.box(name);
    if (box.isEmpty) {
      return;
    }
    if (await isConnected()) {
      int i = 0;

      List addlist = box.values.toList();
      for (var value in addlist) {
        try {
          final additem = Map<String, dynamic>.from(value);

          if (name == 'fexpadd') {
            await syncTxnToFirestore(additem);
          } else if (name == 'fcatadd') {
            await syncCategoryToFirestore(additem);
          } else if (name == 'facadd') {
            await syncAccountToFirestore(additem);
          } else if (name == 'fbudadd') {
            await syncBudgetToFirestore(additem);
          }

          await box.deleteAt(i);
          i++;
        } catch (e) {}
      }
    }
  }

  Future<void> deleteFirestore(String name) async {
    final box = Hive.box(name);
    if (box.isEmpty) {
      return;
    }
    if (await isConnected()) {
      int i = 0;
      List deletelist = box.values.toList();
      for (var id in deletelist) {
        if (name == 'fexpdel') {
          await deleteTxnFromFirestore(id.toString());
        } else if (name == 'fcatdel') {
          await deleteCategoryFromFirestore(id.toString());
        } else if (name == 'facdel') {
          await deleteAccountFromFirestore(id.toString());
        } else if (name == 'fbuddel') {
          await deleteBudgetFromFirestore(id.toString());
        }

        await box.deleteAt(i);
        i++;
      }
    }
  }

  Future<void> syncTxnToFirestore(Map<String, dynamic> txn) async {
    await c.FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection('expenses')
        .doc(txn['id'])
        .set({
      'id': txn['id'],
      'category': txn['category'],
      'amount': txn['amount'],
      'date': (txn['date'] as DateTime),
      'account': txn['account'],
      'type': txn['type']
    });
  }

  Future<void> deleteTxnFromFirestore(String id) async {
    await c.FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection('expenses')
        .doc(id)
        .delete();
  }

  Future<void> syncAccountToFirestore(Map<String, dynamic> account) async {
    print(account['id']);
    print("hiiiiiiiiiiiii");
    await c.FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection('Accounts')
        .doc(account['id'])
        .set({
      'id': account['id'],
      'name': account['name'],
      'icon': account['icon'],
      'bal': account['bal'],
      'initbal': account['initbal'],
    });
  }

  Future<void> deleteAccountFromFirestore(String id) async {
    print(id);
    await c.FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection('Accounts')
        .doc(id)
        .delete();
    print("account deleted");
  }

  Future<void> syncCategoryToFirestore(Map<String, dynamic> category) async {
    await c.FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection('categories')
        .doc(category['id'])
        .set({
      'id': category['id'],
      'name': category['name'],
      'icon': category['icon'],
    });
  }

  Future<void> deleteCategoryFromFirestore(String id) async {
    await c.FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection('categories')
        .doc(id)
        .delete();
  }

  Future<void> syncBudgetToFirestore(Map<String, dynamic> budget) async {
    await c.FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection('budgets')
        .doc('${budget['month']}-${budget['year']}')
        .set({
      'totalBudgets': budget['totalBudget'],
      'categoryBudgets': budget['categoryBudgets'],
      'month': budget['month'],
      'year': budget['year']
    });
  }

  Future<void> deleteBudgetFromFirestore(String id) async {
    await c.FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .collection('budgets')
        .doc(id)
        .delete();
  }
}
