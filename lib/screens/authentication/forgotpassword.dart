import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:xpenso/screens/authentication/welcomescreen.dart';
import 'package:xpenso/services/authenticate.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _emailcontroller = TextEditingController();
  final Authenticate _auth = Authenticate();
    bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 8, 186, 199),
          Color.fromARGB(255, 226, 15, 230)
        ], begin: Alignment.bottomLeft)),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  SizedBox(
                    height: 200,
                    width:300,
                    
                    
                    child: Image.asset('assets/images/Xpensologo.png')),
                  
                  
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(30, 20, 30, 200),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30)),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            const Text(
                    "PASSWORD RESET",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                            const SizedBox(
                              height: 50,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
                                              BorderRadius.circular(20),
                                          borderSide: const BorderSide(
                                              color: Colors.black)))),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                            width: 250,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              onPressed: _submit
                                
                              ,
                              child: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white),
                                    )
                                  : const Text(
                                      "SUBMIT",
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                           
                         ) ],
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
        ));
  }
  void _submit() async {
  if (_formkey.currentState!.validate()) {
    setState(() {
      _loading = true;
    });
    try {
      await _auth.passwordReset(
        context: context,
        email: _emailcontroller.text.toLowerCase(),
        
      );
      Get.defaultDialog(
        titleStyle: const TextStyle(fontWeight: FontWeight.bold),
        title: "PASSWORD RESET LINK SENT",
        content: const Text(
          "Check your inbox",
          style: TextStyle(fontSize: 20),
        ),
        titlePadding:
            const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
        cancel: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          child: const Text(
            "SIGN IN",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Welcome()));
          },
        ),
      );
      
      _emailcontroller.clear();

     
    } on FirebaseAuthException catch (e) {
       setState(() {
        _loading = false;
      });
      if (e.code == 'user-not-found') {
        Get.defaultDialog(
          titleStyle: const TextStyle(fontWeight: FontWeight.bold),
          title: "EMAIL ID NOT REGISTERED",
          barrierDismissible: false,
          content: const Icon(
            Icons.close,
            size: 30,
            color: Colors.red,
          ),
          titlePadding:
              const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
          cancel: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      } else {
        Get.defaultDialog(
          titleStyle: const TextStyle(fontWeight: FontWeight.bold),
          barrierDismissible: false,
          title: "SOMETHING WENT WRONG",
          content: const Icon(
            Icons.error,
            size: 30,
            color: Colors.red,
          ),
          titlePadding:
              const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
          cancel: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      }
    }
  }
}

}
