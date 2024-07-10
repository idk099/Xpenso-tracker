// lib/expense_model.dart
import 'package:hive/hive.dart';

part 'expensemodel.g.dart';

@HiveType(typeId: 1)
class Expense extends HiveObject {
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


  Expense(
      {required this.id,required this.category, required this.amount, required this.date,required this.account});
}
