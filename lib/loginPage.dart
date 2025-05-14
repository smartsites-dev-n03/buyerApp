import 'dart:convert';
import 'dart:developer';
import 'package:buyerApp/sellerApp/ui/homePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buyerApp/forgotPasswordPage.dart';
import 'package:buyerApp/signUpPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'integration/googleLogin.dart';
import 'package:buyerApp/mainPage.dart';
import 'sellerApp/sellerMainPage.dart';
import 'package:buyerApp/ui/staticHomepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obsecure = true;
  bool _isChecked = false;
  bool _isLoading = false;
  int _tabTextIndexSelected = 1;

  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];

  List<DataTab> get _listTextTabToggle => [
    DataTab(title: "Buyer"),
    DataTab(title: "Seller"),
  ];

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController(text: "ss.dev.no3@gmail.com");
    _passwordController = TextEditingController(text: "Flutter@1");

    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      _canCheckBiometrics = await auth.canCheckBiometrics;
      _availableBiometrics = await auth.getAvailableBiometrics();
      log("Available Biometrics: $_availableBiometrics");
    } on PlatformException catch (e) {
      debugPrint("Biometric error: $e");
    }
    setState(() {});
  }

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

    setState(() {
      _isLoading = true;
    });

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

      setState(() => _isLoading = false);
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
      _passwordController.clear();
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: "Invalid credentials",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        textColor: Colors.white,
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
            child:
                _isLoading == true
                    ? Center(child: SpinKitWave(color: Colors.blue, size: 100))
                    : Column(
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

                        Center(
                          child: FlutterToggleTab(
                            width: 80,
                            borderRadius: 30,
                            height: 30,
                            selectedIndex: _tabTextIndexSelected,
                            selectedBackgroundColors: [
                              const Color(0xffBF1E2E),
                              const Color(0xffBF1E2E),
                            ],
                            selectedTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            unSelectedTextStyle: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            unSelectedBackgroundColors: [
                              Colors.white,
                              Colors.white,
                            ],
                            dataTabs: _listTextTabToggle,
                            selectedLabelIndex: (index) {
                              setState(() {
                                _tabTextIndexSelected = index;
                              });
                            },
                            isScroll: false,
                          ),
                        ),

                        const SizedBox(height: 20),

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
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xff56c7fc),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
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
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            label: Text("Password"),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            hintText: 'Password',
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 18.0,
                              horizontal: 18.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xff56c7fc),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
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
                                activeColor: Color(0xff2196f3),
                                checkColor: Color(0xffffffff),
                                value: _isChecked,
                                onChanged: (bool? value) {
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

                        Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 50,
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
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 50,
                                width: 80,
                                child: ElevatedButton(
                                  onPressed: _authenticateWithBiometrics,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.fingerprint,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Center(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });

                              UserCredential? userCredential =
                                  await _authService.signInWithGoogle();

                              setState(() {
                                _isLoading = false;
                              });

                              if (userCredential != null) {
                                if (_tabTextIndexSelected == 1) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => sellerMainPage(),
                                    ),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Mainpage(),
                                    ),
                                  );
                                }
                              } else {
                                Fluttertoast.showToast(
                                  msg:
                                      "Google Sign-In failed. Please try again.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                              }
                            },

                            icon: Image.asset(
                              'assets/google_icon.png',
                              height: 24,
                            ),
                            label: const Text("Sign in with Google"),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
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
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                ),
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

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (didAuthenticate) {
        log("logged in");
        setState(() {
          _isLoading = true;
        });
        postLogin();
      }
    } on PlatformException catch (e) {
      if (e.code == 'LockedOut') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Too many failed attempts. Please try again in 30 seconds.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint(e.toString());
      }
    }
  }
}
