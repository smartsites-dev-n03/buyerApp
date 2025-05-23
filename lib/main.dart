import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:buyerApp/enterOtpPage.dart';
import 'package:buyerApp/ui/splash.dart';
import 'package:buyerApp/ui/staticHomepage.dart';
import 'loginPage.dart';
import 'forgotPasswordPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KhaltiScope(
      publicKey: 'test_public_key_5c5fa086bb704a54b1efd924a2acb036',
      builder: (context, e) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.red,
          ),
          home:  LoginPage(),
          navigatorKey: e,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ne', 'NP'),
          ],
          localizationsDelegates: const [
            KhaltiLocalizations.delegate,
          ],
        );
      },
    );
  }
}