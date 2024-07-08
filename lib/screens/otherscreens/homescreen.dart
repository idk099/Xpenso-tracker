import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class HomeScreen extends StatelessWidget {
 final String _formattedDate = DateFormat("MMMM-yyyy").format(DateTime.now());

  HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        
        children: [


          Center(child: Text(_formattedDate,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)),
      
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
