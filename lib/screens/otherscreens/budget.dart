import 'package:flutter/material.dart';

class Budget extends StatefulWidget {
  const Budget({super.key});

  @override
  State<Budget> createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      flexibleSpace: Center(
          child: Padding(
        padding: const EdgeInsets.only(
          top: 30,
        ),
        child: SizedBox(
            height: 120,
            child: Image.asset(
              'assets/images/appbarlogo.png',
              fit: BoxFit.cover,
            )),
      )),
      backgroundColor: Colors.blue,
    ));
  }
}
