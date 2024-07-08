import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:xpenso/notification/notificationpage.dart';
import 'package:xpenso/screens/otherscreens/accounts.dart';
import 'package:xpenso/screens/otherscreens/budgets.dart';
import 'package:xpenso/screens/otherscreens/homescreen.dart';
import 'package:xpenso/screens/otherscreens/transactionrecord.dart';
import 'package:xpenso/screens/otherscreens/txnAnalysis.dart';


class MainScreenPagesLayout extends StatefulWidget {
  const MainScreenPagesLayout({super.key});

  @override
  State<MainScreenPagesLayout> createState() => _MainScreenPagesLayoutState();
}

class _MainScreenPagesLayoutState extends State<MainScreenPagesLayout> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
     final islightmode = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
        
          TransactionRecord(),
          BudgetScreen(),
          TxnAccount(),
          Analysis()
         
        ],
      ),
      bottomNavigationBar:  Card(
        elevation: 6,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SalomonBottomBar(
            curve: Curves.linear,
            selectedItemColor: islightmode ? Colors.black : Color.fromARGB(255, 181, 131, 131),
            backgroundColor: islightmode ? const Color.fromARGB(255, 175, 224, 248) : Colors.black12,
            unselectedItemColor: Colors.grey,
            items: [

              
                  
                  SalomonBottomBarItem(
                  icon: Icon(Icons.receipt_long_sharp, color: islightmode ? Colors.black : Colors.white),
                  title: Text('Records')),
                  SalomonBottomBarItem(
                  icon: Icon(Icons.money, color: islightmode ? Colors.black : Colors.white),
                  title: Text('Budget')),
              SalomonBottomBarItem(
                  icon: Icon(Icons.credit_card, color: islightmode ? Colors.black : Colors.white),
                  title: Text('Account')),
                  
              
              
              SalomonBottomBarItem(
                  icon: Icon(Icons.analytics_outlined, color: islightmode ? Colors.black : Colors.white),
                  title: Text('Analysis')),

                 
            ],
            currentIndex: _selectedIndex,
            onTap:  _onItemTapped,
          ),
        ),
      ),
    );
  }
}
