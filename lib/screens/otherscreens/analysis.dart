import 'package:flutter/material.dart';

class Analysis extends StatefulWidget {
  const Analysis({super.key});

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
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
