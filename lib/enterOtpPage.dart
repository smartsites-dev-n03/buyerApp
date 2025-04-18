import 'dart:convert';
import 'package:buyerApp/ui/homepage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class EnterOtpPage extends StatefulWidget {
  const EnterOtpPage({super.key});

  @override
  State<EnterOtpPage> createState() => _EnterOtpPageState();
}

class _EnterOtpPageState extends State<EnterOtpPage> {
  final TextEditingController _emailController = TextEditingController();

  void _enterOtp() {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter registered email address"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    //postLogin();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Email: $email"),
        backgroundColor: Colors.green,
      ),
    );
  }


  Future postEnterOtp() async {
    final response = await http.post(
        Uri.parse('https://api.sarbamfoods.com/accounts/login/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          "email":_emailController.text.toString(),
        }));

    if(response.statusCode==200){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
    }else{
      Fluttertoast.showToast(
          msg: "Invalid Email!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 80),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                Center(
                    child: Icon(Icons.all_inclusive, size: 72, color: Colors.blue[500])
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "OPT Verify",
                    style: TextStyle(fontSize: 40, color: Colors.blue,fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                    controller: _emailController,
                    cursorColor: Colors.red,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(
                      fontFamily: "poppins",
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: TextStyle(fontFamily: "poppins",color: Colors.grey,fontSize: 14),
                      label: Text("Enter OPT"),
                      hintStyle: TextStyle(fontFamily: "poppins",color: Colors.grey,fontSize: 14),
                      hintText: 'Enter OPT from email',
                      contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff56c7fc), width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      prefixIcon: Icon(Icons.key),
                    )
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    height: 50,
                    width: 300,
                    child: ElevatedButton(
                      onPressed: _enterOtp,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: const Text("Verify", style: TextStyle(fontSize: 18, color: Colors.white)),
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