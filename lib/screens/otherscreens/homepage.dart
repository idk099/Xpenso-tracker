import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:xpenso/screens/otherscreens/addcategory.dart';
import 'package:xpenso/screens/otherscreens/addexpense.dart';
import 'package:xpenso/services/authenticate.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Authenticate _auth = Authenticate();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userRef = FirebaseFirestore.instance.collection('User').doc(uid);
    double screenWidth = MediaQuery.of(context).size.width;
    double responsivePadding = screenWidth * 0.05;
    return Scaffold(
      backgroundColor: Color(0xffcaf0f8),
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
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.exit_to_app_sharp,
                  color: Colors.white,
                ),
                onPressed: () async {
                  signOutDialog();
                })
          ]),
      body: SafeArea(
        child: Stack(children: [
          Positioned(
            bottom: responsivePadding, // Adjust as needed
            right: responsivePadding, // Adjust as needed
            child: SpeedDial(
              backgroundColor: Color.fromARGB(255, 98, 216, 237),
              activeIcon: Icons.close,
              icon: Icons.add,
              overlayOpacity: 0.1,
              direction: SpeedDialDirection.up,
              children: [
                SpeedDialChild(
                  child: Icon(Icons.category),
                  label: 'Add category',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCategoryPage(),
                        ));
                  },
                ),
                SpeedDialChild(
                  child: Icon(Icons.receipt),
                  label: 'Add expense',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddExpensePage(),
                        ));
                  },
                )
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  SizedBox(
                    height: 78,
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: userRef.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                            height: 30,
                          );
                        }

                        if (snapshot.hasError) {
                          return SizedBox(
                            height: 30,
                          );
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return SizedBox(
                            height: 30,
                          );
                        }

                        final userName = snapshot.data!['Name'];

                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(responsivePadding),
                            child: SizedBox(
                              height: 30,
                              child: Text(
                                'Hello, $userName',
                                style: TextStyle(
                                    letterSpacing: 2,
                                    fontSize: 24,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsivePadding),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Future<void> signOutDialog() async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Center(child: Text('CONFIRM')),
        content: Text('Are you sure want to signout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _auth.siginOut();
            },
            child: Text('Signout'),
          ),
        ],
      ),
    );
  }
}
