import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpenso/screens/authentication/signup.dart';
import 'package:xpenso/screens/authentication/forgotpassword.dart';
import 'package:xpenso/services/authenticate.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _formkey = GlobalKey<FormState>();
  bool _isObscured = true;
  bool _loading = false;

  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final Authenticate _auth = Authenticate();
  @override
  void dispose() {
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [

              Colors.red,
              Colors.blue
            ])

          ),
          child: Column(
            children: [
              Image.asset(
                'assets/images/Xpensologo.png',
                height: 220,
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          const Text(
                            "LOGIN",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 20, bottom: 10),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Forgot(),
                                      ));
                                },
                                child: const Text(
                                  "forgot password?",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              onPressed: _submit
                                
                              ,
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
                          const SizedBox(height: 20),
                        
                          
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
        await _auth.SigninwithEmail(
          context: context,
          email: _emailcontroller.text.toLowerCase(),
          password: _passwordcontroller.text,
          
        );
         _emailcontroller.clear();
      _passwordcontroller.clear();
      } on FirebaseAuthException catch (e) {
         setState(() {
          _loading = false;
        });
      if (e.code == 'user-not-found') {
        Get.snackbar(
          'USER NOT FOUND',
          'Register to continue',
          colorText: Colors.white,
          duration: const Duration(seconds: 2)
        );
        
      } else if (e.code == 'wrong-password') {
        Get.snackbar('Password incorrect', "You can reset your password",
            colorText: Colors.white, duration: const Duration(seconds: 2));
        
      } else {
        Get.snackbar('SOMETHING WENT WRONG', 'Try again',
            colorText: Colors.white, duration: const Duration(seconds: 2));
        
      }
    } 
    }
  }
}
