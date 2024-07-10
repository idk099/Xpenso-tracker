import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:xpenso/Models/accountmodel.dart';

Future<void> addTxnAccount() async {
  final Box<Accounts> accountBox = Hive.box<Accounts>('Accounts');

  int bnkIcon = Icons.account_balance_rounded.codePoint;
  int cashIcon = Icons.money_outlined.codePoint;
if(accountBox.isEmpty)
{
 var bnkAc = Accounts(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: "Bank",
      icon: bnkIcon,
      bal: 0.0,
      initbal: 0.0);

  var cashAc = Accounts(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "Cash",
      icon: cashIcon,
      bal: 0.0,
      initbal: 0.0);

  accountBox.add(bnkAc);
  accountBox.add(cashAc);

}




 
}
