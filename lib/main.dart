import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodie/screens/navbar_screen.dart';
//import 'package:foodie/data/data.dart';
import 'package:foodie/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAKQvWaE_vPJMRuHMBdcXQa2Lvp0UY94kk",
          appId: "1:328733462006:android:9906ab1248c81b9dc3cbd7",
          messagingSenderId: "328733462006",
          projectId: "foodie-89a08",
          storageBucket: "foodie-89a08.appspot.com"));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Poppins'),
      debugShowCheckedModeBanner: false,
      title: 'Foodie',
      home: SplashScreen(),
    );
  }
}
