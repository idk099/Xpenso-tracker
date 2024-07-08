import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:xpenso/screens/otherscreens/budgetoverview.dart';
import 'package:xpenso/screens/otherscreens/bugetsetting.dart';
import 'package:xpenso/services/Provider/transactionservices.dart';
import 'package:xpenso/widgets/Piechart.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<BudgetScreen> {
  TabController? _tabController;

  List<Widget> _pages = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _pages = [BudgetSettingPage(), BudgetOverView()];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final islightmode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Budget',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Card(
                color: islightmode ? Colors.white : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: islightmode ? Colors.black : null,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12)),
                        labelPadding: EdgeInsets.all(10),
                        controller: _tabController,
                        tabs: [
                          Tab(
                            child: Text(
                              "Set Budget",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          Tab(
                            child: Text(
                              "Overview",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          )
                        ]),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: _pages
                        .map(
                          (piechart) => piechart,
                        )
                        .toList()),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
