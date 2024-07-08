import 'package:hive/hive.dart';

part 'budgetmodel.g.dart';

@HiveType(typeId: 5)

class Budget {
  @HiveField(0)
   double? totalBudget;
  
  @HiveField(1)
   Map<String, double> categoryBudgets;

  @HiveField(2)
   int month;

  @HiveField(3)
   int year;

  Budget({
    required this.totalBudget,
    required this.categoryBudgets,
    required this.month,
    required this.year,
  });
}
