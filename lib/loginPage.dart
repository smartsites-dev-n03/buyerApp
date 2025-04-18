import 'dart:convert';
import 'dart:developer';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/forgotPasswordPage.dart';
import 'package:untitled1/signUpPage.dart';
import 'package:untitled1/ui/staticHomepage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obsecure = true;
  bool _isChecked = false;
  bool _isLoading = false;

  void _login() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both email and password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    postLogin();
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
    );
  }

  void _signUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  Future postLogin() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences userPefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse('https://api.sarbamfoods.com/accounts/login/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        "email": _emailController.text.toString(),
        "password": _passwordController.text.toString(),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });
      if (_isChecked == true) {
        userPefs.setString('token', jsonDecode(response.body)['access_token']);
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      _emailController.clear();
      _passwordController.clear();

      Fluttertoast.showToast(
        msg: "Invalid Logins!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: SingleChildScrollView(
            child: _isLoading==true?Center(
              child: SpinKitDancingSquare(
                color: Colors.blue,
                size: 200,
              ),
            ):Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    Icons.all_inclusive,
                    size: 70,
                    color: Colors.blue[500],
                  ),
                ),
                Center(
                  child: Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                    label: Text("Username or Email"),
                    hintStyle: TextStyle(
                      fontFamily: "poppins",
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    hintText: 'Email of user',
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
                const SizedBox(height: 20),
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

                SizedBox(
                  height: 50,
                  width: 300,
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Color(0xff00C8E8),
                        value: _isChecked,
                        onChanged: (bool? value) {
                          // log(value.toString());
                          setState(() {
                            _isChecked = value!;
                          });
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isChecked == true
                                ? _isChecked = false
                                : _isChecked = true;
                          });
                        },
                        child: Text(
                          "Remember Me",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    height: 50,
                    width: 300,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: const Text(
                        "SIGN IN",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    height: 25,
                    width: 300,
                    child: ElevatedButton(
                      onPressed: _forgotPassword,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(fontSize: 18, color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Text(
                        "Don\'t have an account? Sign Up",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
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
