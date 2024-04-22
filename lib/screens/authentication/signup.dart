import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xpenso/services/authenticate.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

final Authenticate _auth = Authenticate();
final TextEditingController _emailcontroller = TextEditingController();
final TextEditingController _passwordcontroller = TextEditingController();
final TextEditingController _namecontroller = TextEditingController();
String? val;

class _SignupState extends State<Signup> {
  final _formkey = GlobalKey<FormState>();
  bool _isObscured = true;
  bool _isObscured2 = true;
  bool _loading = false;
  Image? background;


 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.green,
            Colors.yellow,


          ])
        ),
          child: Column(
            children: [
              Image.asset(
                'assets/images/X.png',
                width: 200,
                height: 100,
                fit: BoxFit.fitWidth,
              ),
              Expanded(
                child: Container(
                  decoration:  BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(90),
                        topRight: Radius.circular(90)
                      )),
                  child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          const Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                                controller: _namecontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a name';
                                  }

                                  return null;
                                },
                                decoration: InputDecoration(
                                    suffixIcon: const Icon(Icons.person),
                                    labelText: 'Name',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)))),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                                controller: _emailcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email';
                                  }
                                  final emailRegx = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegx.hasMatch(value)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    suffixIcon: const Icon(Icons.email),
                                    labelText: 'Email',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)))),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                                controller: _passwordcontroller,
                                validator: (value) {
                                  val = value;
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  if (value.length < 4) {
                                    return 'Password must contain more than 4 characters';
                                  }

                                  return null;
                                },
                                obscureText: _isObscured,
                                decoration: InputDecoration(
                                    labelText: 'Password',
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isObscured = !_isObscured;
                                          });
                                        },
                                        icon: Icon(_isObscured
                                            ? Icons.visibility
                                            : Icons.visibility_off)),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)))),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                                validator: (value) {
                                  if (val!.isNotEmpty && value!.isEmpty) {
                                    return 'Please confirm password';
                                  }
                                  if (val != value) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                obscureText: _isObscured2,
                                decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isObscured2 = !_isObscured2;
                                          });
                                        },
                                        icon: Icon(_isObscured2
                                            ? Icons.visibility
                                            : Icons.visibility_off)),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)))),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: 250,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 235, 16, 1),
                              ),
                              onPressed: _submit,
                              child: _loading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white),
                                    )
                                  : Text(
                                      "SUBMIT",
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      )),
                ),
              )
            ],
          ),
        ));
  }

  void _submit() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      try {
        await _auth.signupwithEmail(
            context: context,
            email: _emailcontroller.text.toLowerCase(),
            password: _passwordcontroller.text,
            name: _namecontroller.text);
        _emailcontroller.clear();
        _passwordcontroller.clear();
        _namecontroller.clear();
      } on FirebaseAuthException catch (e) {
        setState(() {
          _loading = false;
        });
        if (e.code == 'email-already-in-use') {
          Get.snackbar('EMAIL ALREADY IN USE', "Try again using new email id",
              colorText: Colors.white, duration: const Duration(seconds: 2));
          return;
        } else if (e.code == 'invalid-email') {
          Get.snackbar('INVALID EMAIL', "Check your email",
              colorText: Colors.white, duration: const Duration(seconds: 2));
          return;
        } else if (e.code == 'weak-password') {
          Get.snackbar('WEAK PASSWORD', "Choose Another password",
              colorText: Colors.white, duration: const Duration(seconds: 2));
          return;
        } else {
          Get.snackbar('SOMETHING WENT WRONG', 'Try again',
              colorText: Colors.white, duration: const Duration(seconds: 2));
          return;
        }
      }
    }
  }
}
