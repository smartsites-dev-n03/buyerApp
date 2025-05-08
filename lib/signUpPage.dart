import 'dart:convert';
import 'dart:developer';
import 'package:buyerApp/forgotPasswordPage.dart';
import 'package:buyerApp/loginPage.dart';
import 'package:buyerApp/ui/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obsecure = true;
  bool _obsecure1 = true;

  void _signUp() async {
    String email = _emailController.text.trim();
    String name = _nameController.text.trim();
    String phone_number = _phoneNumberController.text.trim();
    String address = _addressController.text.trim();
    String password = _passwordController.text.trim();
    String confirm_paddword = _confirmPasswordController.text.trim();

    if (email.isEmpty ||
        name.isEmpty ||
        phone_number.isEmpty ||
        address.isEmpty ||
        password.isEmpty ||
        confirm_paddword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter all required fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'phone': phone_number,
          'address': address,
          'email': email,
          'uid': userCredential.user!.uid,
        });
        print("User registered and added to Firebase");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e, stacktrace) {
      print(e);
    }
  }

  void _login() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future postLogin() async {
    String email = _emailController.text.trim();
    String name = _nameController.text.trim();
    String phone_number = _phoneNumberController.text.trim();
    String address = _addressController.text.trim();
    String password = _passwordController.text.trim();
    String confirm_password = _confirmPasswordController.text.trim();

    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
    } catch (e, stacktrace) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Icon(
                    Icons.all_inclusive,
                    size: 72,
                    color: Colors.blue[500],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "SIGN UP",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  cursorColor: Colors.red,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    fontFamily: "poppins",
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(
                      fontFamily: "poppins",
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    label: Text("Email Address"),
                    hintStyle: TextStyle(
                      fontFamily: "poppins",
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    hintText: 'Email Address',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 18.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff56c7fc),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  cursorColor: Colors.red,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    fontFamily: "poppins",
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    label: Text("Full Name"),
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    hintText: 'Full Name',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 18.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff56c7fc),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneNumberController,
                  cursorColor: Colors.red,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontFamily: "poppins",
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(
                      fontFamily: "poppins",
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    label: Text("Phone Number"),
                    hintStyle: TextStyle(
                      fontFamily: "poppins",
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    hintText: 'Phone Number',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 18.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff56c7fc),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressController,
                  cursorColor: Colors.red,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    fontFamily: "poppins",
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(
                      fontFamily: "poppins",
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    label: Text("Address"),
                    hintStyle: TextStyle(
                      fontFamily: "poppins",
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    hintText: 'Address',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 18.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff56c7fc),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  obscureText: _obsecure,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    label: Text("Password"),
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    hintText: 'Password',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 18.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff56c7fc),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    prefixIcon: Icon(Icons.key),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        if (_obsecure == true) {
                          setState(() {
                            _obsecure = false;
                          });
                        } else {
                          setState(() {
                            _obsecure = true;
                          });
                        }
                      },
                      child: Icon(
                        _obsecure
                            ? Icons.remove_red_eye
                            : Icons.remove_red_eye_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  obscureText: _obsecure1,
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    label: Text("Confirm Password"),
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    hintText: 'Confirm Password',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 18.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff56c7fc),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    prefixIcon: Icon(Icons.password),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        if (_obsecure1 == true) {
                          setState(() {
                            _obsecure1 = false;
                          });
                        } else {
                          setState(() {
                            _obsecure1 = true;
                          });
                        }
                      },
                      child: Icon(
                        _obsecure1
                            ? Icons.remove_red_eye
                            : Icons.remove_red_eye_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    height: 50,
                    width: 300,
                    child: ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: const Text(
                        "SIGN UP",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    height: 50,
                    width: 300,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Text(
                        "Already have an account? Sign In",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
