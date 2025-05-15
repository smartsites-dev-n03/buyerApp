import 'package:buyerApp/mainPage.dart';
import 'package:buyerApp/sellerApp/sellerMainPage.dart';
import 'package:buyerApp/signUpPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:buyerApp/enterOtpPage.dart';
import 'package:buyerApp/ui/splash.dart';
import 'package:buyerApp/ui/staticHomepage.dart';
import 'loginPage.dart';
import 'forgotPasswordPage.dart';
import 'integration/notificationServices.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationService.initialize();
  getDeviceToken();
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);
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
          theme: ThemeData(primarySwatch: Colors.red),
          //home: sellerMainPage(),
          //home: SignUpPage(),
          //home: Mainpage(),
          home: LoginPage(),
          navigatorKey: e,
          supportedLocales: const [Locale('en', 'US'), Locale('ne', 'NP')],
          localizationsDelegates: const [KhaltiLocalizations.delegate],
        );
      },
    );
  }
}

void getDeviceToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');
}
