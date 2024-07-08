import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:xpenso/services/Provider/transactionservices.dart';
import 'package:xpenso/widgets/Progressbar.dart';

class BudgetOverView extends StatelessWidget {
   BudgetOverView({super.key});
  
        String formattedDate = DateFormat("MMMM-yyyy").format(DateTime.now() );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TransactionServices>(builder: (context, value, child) {
        if (value.getCurrentMonthBudget() == null) {
          return Center(child: Text("Add Total Budget/Categorywise Budget",style: TextStyle( fontSize:17 ,  color: Colors.white),),);
        }

        else if(value.getCurrentMonthBudget()!.totalBudget==null&&value.getCurrentMonthBudget()!.categoryBudgets.isEmpty)
        {

          return Center(child: Text("Add Total Budget/Categorywise Budget",style: TextStyle(fontSize: 17, color: Colors.white),),);
        }
      


        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(formattedDate,style: TextStyle(fontSize: 29,fontWeight: FontWeight.bold,color: Colors.white),),
            TotalBudgetProgressBar(),
            SizedBox(
              height: 20,
            ),
            Expanded(child: CategoryWiseBudgetProgressBar())
          ],
        );
      }),
    );
  }
}
