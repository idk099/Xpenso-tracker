import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:xpenso/screens/otherscreens/addexpense.dart';
import 'package:xpenso/screens/otherscreens/analysis.dart';
import 'package:xpenso/screens/otherscreens/budget.dart';
import 'package:xpenso/screens/otherscreens/categorywisebudget.dart';

import 'package:xpenso/screens/otherscreens/expenselistmonth.dart';
import 'package:xpenso/screens/otherscreens/homepage.dart';
import 'package:xpenso/screens/otherscreens/homedata.dart';

import 'package:xpenso/screens/otherscreens/totalbudget.dart';
import 'package:xpenso/screens/otherscreens/records.dart';



class Pagelayout extends StatefulWidget {
  const Pagelayout({super.key});

  
  @override
  State<Pagelayout> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Pagelayout> {
  @override


  int _currentIndex = 0;

  final _page1 = GlobalKey<NavigatorState>();
  final _page2 = GlobalKey<NavigatorState>();
  final _page3 = GlobalKey<NavigatorState>();
  final _page4 = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(

      resizeToAvoidBottomInset: false,
     
       
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          Navigator(
            key: _page1,
            onGenerateRoute: (route) => MaterialPageRoute(
              settings: route,
              builder: (context) => Home(),
            ),
          ),
          Navigator(
            key: _page2,
            onGenerateRoute: (route) => MaterialPageRoute(
              settings: route,
              builder: (context) => Budget(),
            ),
          ),
          Navigator(
            key: _page3,
            onGenerateRoute: (route) => MaterialPageRoute(
              settings: route,
              builder: (context) => ExpenseListPage(),
            ),
            
          ),
           Navigator(
            key: _page4,
            onGenerateRoute: (route) => MaterialPageRoute(
              settings: route,
              builder: (context) =>  Analysis(),
            ),
          ),
     
        ],
      
      ),
      bottomNavigationBar: CurvedNavigationBar(
      
        
        backgroundColor: Colors.transparent,
        animationCurve: Easing.legacyAccelerate,
        animationDuration: Duration(milliseconds: 500),
        items:  const [
          
          CurvedNavigationBarItem(
            child: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.money),
            label: 'Budget',
          ),
          
          CurvedNavigationBarItem(
            child: Icon(Icons.receipt_long_sharp),
            label: 'Records',
          ),
          
           CurvedNavigationBarItem(
            child: Icon(Icons.analytics_outlined),
            label: 'Analysis',
          ),
        ],
        onTap: (index) {
          if(index==4)
          {
            
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

