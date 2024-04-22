import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class SignUpPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> _handleSignUp() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount!.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential authResult = await _auth.signInWithCredential(credential);
      User? user = authResult.user;

      // Check if user is new and then store user's name in Firestore
      if (user != null && authResult.additionalUserInfo!.isNewUser) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
        });
      }

      // Navigate to another page or perform any other action after signup
      print('User signed up: ${user?.displayName}');
    } catch (error) {
      print(error);
      // Handle sign up failure
      print('Sign up failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _handleSignUp();
          },
          child: Text('Sign Up with Google'),
        ),
      ),
    );
  }
}
