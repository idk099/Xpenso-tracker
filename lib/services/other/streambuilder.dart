import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xpenso/Data/defaulttxnaccountdata.dart';

import 'package:xpenso/screens/authentication/welcomescreen.dart';
import 'package:xpenso/screens/otherscreens/categoryadd.dart';
import 'package:xpenso/services/new.dart';
import 'package:xpenso/widgets/layout/mainscreenlayout.dart';
import 'package:xpenso/widgets/layout/mainscreenpageslayout.dart';




class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
          // User is logged in
          
          Syncservices syncservices = Syncservices();
          syncservices.activate();
             addTxnAccount();
          
          return MainScreenLayout();

        } else {
          // User is not logged in
          return Welcome();
        }
            }));
  }
}
