import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mainPage.dart';

import 'package:buyerApp/sellerApp/sellerMainPage.dart';
import 'package:buyerApp/sellerApp/ui/homePage.dart';

class LoginProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<User?> loginUser(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      final DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .get();

      final userData = userSnapshot.data() as Map<String, dynamic>?;
      log("user email:" + userData.toString());
      print("Login successful: ${user?.email}");
      return user;
    } catch (e, stacktrace) {
      print("Login Error: $e");
      print("StackTrace: $stacktrace");
      return null;
    }
  }

  Future postLogin(BuildContext context, int _tabTextIndexSelected) async {
    isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse(
        'https://api-barrel.sooritechnology.com.np/api/v1/user-app/login',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({"userName": "admin123", "password": "123nepal"}),
    );

    if (response.statusCode == 200) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString(
        "accessToken",
        jsonDecode(response.body)['tokens']['access'],
      );

      _tabTextIndexSelected == 1
          ? Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SellerHomePage()),
          )
          : Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Mainpage()),
          );
    } else {
      isLoading = false;

      Fluttertoast.showToast(
        msg: "Invalid credentials",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    return response;
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
