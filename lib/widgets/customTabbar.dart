import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:xpenso/services/Provider/transactionservices.dart';
import 'package:xpenso/widgets/Piechart.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({super.key});

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with TickerProviderStateMixin{
 
    TabController? _tabController;

  List<Widget> _pages=[];

   
    
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _pages = [
      const PieChart(txnType: "Expense"),
       const PieChart( txnType: "Income")
    ];
  }

  @override
  Widget build(BuildContext context) {
       final islightmode = Theme.of(context).brightness == Brightness.light;
   
    return Container(
      height: 700,
      
    
      
    
      child: Column(
        children: [
          
          
          Card(
            color: islightmode?Colors.white:null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
             
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Colors.transparent),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: islightmode?Colors.black:null,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(color: Colors.red,borderRadius: BorderRadius.circular(12)),
                  labelPadding: EdgeInsets.all(10),
                controller: _tabController,
                  tabs: [
                    
                  Tab(
                    child: Text("Expense",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                  ),
                  Tab(
                    child: Text("Income",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                  )
                ]),
              ),
            ),
          ),SizedBox(height: 10),

          Expanded(
        
            child: TabBarView(
                controller: _tabController,
                children: _pages
                    .map(
                      (piechart) => piechart,
                    )
                    .toList()),
          )
        ],
      ),
    );
  }

   
}

class PieChartData {
  String x;
  double y;
  PieChartData({required this.x, required this.y});
}
