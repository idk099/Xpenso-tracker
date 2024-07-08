import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:xpenso/services/other/streambuilder.dart';
import 'package:xpenso/widgets/layout/mainscreenpageslayout.dart';



class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}


class _SplashState extends State<Splash> {
   Image? image1;
  bool _circular = false;
  @override
  void initState() {
    super.initState();
     image1 = Image.asset("assets/images/3.jpg");
    // TODO: implement initState

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreenPagesLayout()
          ));
    });
    Timer(Duration(seconds: 3), () {
      setState(() {
        _circular = true;
      });
    });
  }
   @override
  void didChangeDependencies() {
    // Precache the image
    precacheImage(image1!.image, context);
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Theme.of(context).brightness==Brightness.light? Color(0xFF5CE1E6):Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
               
              SizedBox(
                height: 80,
              )
              ,
              Lottie.asset("assets/images/Xpensolottie.json" ,repeat: false),
               if (_circular) 
              Circular()
            ],
          ),
        ),
      ),
    );
  }

  Widget Circular() {
    
      return CircularProgressIndicator(
        color: Colors.white,
      );
    
   
  }
}
