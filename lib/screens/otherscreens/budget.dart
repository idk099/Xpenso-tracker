import 'package:flutter/material.dart';
import 'package:xpenso/screens/otherscreens/categorywisebudget.dart';
import 'package:xpenso/screens/otherscreens/totalbudget.dart';

class Budget extends StatefulWidget {
  @override
  State<Budget> createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  int _selectedIndex = 0;

  void _onPageSelected(int? index) {
    if(index != null) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.amber,
        
        title: Text('Budget Setting ',style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          DropdownButton<int>(
            value: _selectedIndex,
            items: [
              DropdownMenuItem(
                child: Text('Total budget',style: TextStyle(fontWeight: FontWeight.bold),),
                value: 0,
              ),
              DropdownMenuItem(
                child: Text('Category wise total',style: TextStyle(fontWeight: FontWeight.bold),),
                value: 1,
              ),
            ],
            onChanged: _onPageSelected,
            style: TextStyle(color: Colors.black), // Text color of dropdown items
            iconEnabledColor: Colors.black, // Icon color of dropdown button
            underline: Container(  // Remove default underline
              height: 0,
              color: Colors.transparent,
            ),
            // Add decoration directly inside DropdownButton
            dropdownColor: Colors.white, // Set dropdown background color
            elevation: 2, // Set elevation to provide shadow
            borderRadius: BorderRadius.circular(5.0), // Set border radius
            icon: Icon(Icons.arrow_drop_down), // Add dropdown icon
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          BudgetSettingPage(),
          CategoryBudgetSettingPage(),
        ],
      ),
    );
  }
}


