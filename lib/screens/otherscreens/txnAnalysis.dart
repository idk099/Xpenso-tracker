import 'package:flutter/material.dart';
import 'package:xpenso/screens/otherscreens/addtxnscreen.dart';
import 'package:xpenso/widgets/customTabbar.dart';
import 'package:xpenso/widgets/custombargraph.dart';

class Analysis extends StatefulWidget {
  const Analysis({super.key});

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis>   {

  

 

  @override
  Widget build(BuildContext context) {
  


    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Analysis",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 30),
        ),
      ),
      
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            
            children: [
              
             
            SizedBox(height: 10),
              Bargraph(),
              SizedBox(height: 30,),
              Text("  Category Wise",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
            SizedBox(height: 10),
             CustomTabBar(),
             
            ],
          ),
        ),
      ),
    );
  }


}
