// lib/expense_model.dart
import 'package:hive/hive.dart';

part 'transactionmodel.g.dart';

@HiveType(typeId: 3)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String category;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String account;

  @HiveField(5)
  String type;



  Transaction(
      {required this.id,required this.category, required this.amount, required this.date,required this.account,required this.type});
}
