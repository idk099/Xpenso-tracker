import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xpenso/screens/authentication/signin.dart';
import 'package:xpenso/screens/authentication/welcomescreen.dart';
import 'package:xpenso/screens/home.dart';

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
                return const MyHomePage();
              } else {
                return const Welcome();
              }
            }));
  }
}
