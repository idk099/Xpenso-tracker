import "package:firebase_auth/firebase_auth.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

import "package:flutter/material.dart";
import 'package:google_sign_in/google_sign_in.dart';

class Authenticate {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final CollectionReference usercollect =
      FirebaseFirestore.instance.collection("User");

  // ignore: non_constant_identifier_names
  Future SigninwithEmail(
      {required context,
      required String email,
      required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("signed in");
       Navigator.pop(context);

    } catch (e) {
      rethrow;
    }
  }

  Future signupwithEmail(
      {required context,
      required String email,
      required String password,
      required String name}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Navigator.pop(context);
      try {
        final uid = _auth.currentUser!.uid;
        await usercollect.doc(uid).set({'Name': name,'Email':email
        });
      } catch (e) {
        print(e);
      }

      print("signed up");
    } catch (e) {
      rethrow;
    }
  }

  Future siginOut() async {
    await _auth.signOut();
    await googleSignIn.signOut();
  }

  Future passwordReset({required context, required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
  Future gsignin() async {
     
    
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

      if (user != null && authResult.additionalUserInfo!.isNewUser) {
        await usercollect.doc(user.uid).set({
          'Name': user.displayName,
          'Email': user.email,
        });
      }
      

      print('User signed up: ${user?.displayName}');
    } catch (error) {
      rethrow;
    }
  }
}
