import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Second extends StatefulWidget {
  const Second({Key? key}) : super(key: key);

  @override
  State<Second> createState() => _SecondState();
}

class _SecondState extends State<Second> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  late DocumentReference dataRef;

  @override
  void initState() {
    super.initState();

    dataRef = FirebaseFirestore.instance.collection('User').doc(uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: dataRef.snapshots(),
      builder: (context, dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (dataSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${dataSnapshot.error}'),
            ),
          );
        } else {
          if (dataSnapshot.data!.exists) {
            // Check if the 'name' field exists in the document
            final data = dataSnapshot.data!.data()
                as Map<String, dynamic>?; // Cast to Map<String, dynamic>?
            final nameExists = data?['Name'] != null;

            if (nameExists) {
              // 'name' field exists
              return Scaffold(
                body: Center(
                  child: Text("Has data"),
                ),
              );
            } else {
              // 'name' field does not exist
              return Scaffold(
                body: Center(
                  child: Text("No data"),
                ),
              );
            }
          } else {
            // Document does not exist
            return Scaffold(
              body: Center(
                child: Text("No data"),
              ),
            );
          }
        }
      },
    );
  }
}
