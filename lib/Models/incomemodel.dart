// lib/expense_model.dart
import 'package:hive/hive.dart';

part 'incomemodel.g.dart';

@HiveType(typeId: 2)
class Income extends HiveObject {
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


  Income(
      {required this.id,required this.category, required this.amount, required this.date,required this.account});
}
