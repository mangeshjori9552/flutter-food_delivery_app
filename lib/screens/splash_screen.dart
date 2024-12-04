import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodie/constants/constants.dart';
import 'package:foodie/controller/sessiondata.dart';
import 'package:foodie/screens/navbar_screen.dart';
import 'package:foodie/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> checkLoginStatus() async {
    log("${await Sessiondata.isLogin}");

    if (Sessiondata.isLogin) {
      // User is logged in, navigate to HomePage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => NavbarScreen()),
      );
    } else {
      // User is not logged in, navigate to LoginScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Sessiondata.getSessionData();
    Timer(Duration(seconds: 3), () {
      // SplashScreen'den sonra gitmek istediğin sayfa
      checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Image.asset('assets/images/logo_1.png'),
      ),
    );
  }
}
