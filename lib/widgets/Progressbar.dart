import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:xpenso/services/Provider/transactionservices.dart';

class TotalBudgetProgressBar extends StatelessWidget {
  const TotalBudgetProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionServices>(
      builder: (context, budgetServices, child) {
        double totalExpenses = budgetServices.getTotalExpenseForCurrentMonth();
        if (budgetServices.getCurrentMonthBudget() != null) {
          double? totalBudget =
              budgetServices.getCurrentMonthBudget()!.totalBudget;
          if (totalBudget != null) {
            double exceededAmount = totalExpenses - totalBudget;
            bool isBudgetExceeded = exceededAmount > 0;
            double remainingAmount = totalBudget - totalExpenses;
            double progress = (totalExpenses / totalBudget).clamp(0.0, 1.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                     
                    ],
                  ),
                ),
                if (isBudgetExceeded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Exceeded by ₹ ${exceededAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${totalExpenses.toStringAsFixed(2)} / ${totalBudget.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            LinearProgressIndicator(
                              minHeight: 20,
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!isBudgetExceeded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Remaining ₹ ${remainingAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${totalExpenses.toStringAsFixed(2)} / ${totalBudget.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            LinearProgressIndicator(
                              minHeight: 20,
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
        }

        return Container();
      },
    );
  }
}

class CategoryWiseBudgetProgressBar extends StatelessWidget {
  const CategoryWiseBudgetProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionServices>(
      builder: (context, budgetServices, child) {
        List<CategorywiseBudgetAnalyseData> categoryData =
            budgetServices.getBudgetExpenseCategoryWiseCurrentMonth();
        if (categoryData.isNotEmpty) {
          return ListView.builder(
            itemCount: categoryData.length,
            itemBuilder: (context, index) {
              double expense = categoryData[index].expense;
              double budget = categoryData[index].budget;
              double exceededAmount = expense - budget;
              double progress = (expense / budget).clamp(0.0, 1.0);

              String categoryName = categoryData[index].categoryName;
              return Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 2), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black
                      ),
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300]!,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 8),
                    Text(
                      exceededAmount > 0
                          ? 'Exceeded by: ₹ ${exceededAmount.toStringAsFixed(2)}'
                          : 'Remaining: ₹ ${(budget - expense).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: exceededAmount > 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Limit: ₹ ${budget.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: exceededAmount > 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
        return Container();
      },
    );
  }
}

class CategorywiseBudgetAnalyseData {
  String categoryName;
  double expense;
  double budget;

  CategorywiseBudgetAnalyseData(
      {required this.categoryName,
      required this.expense,
      required this.budget});
}
