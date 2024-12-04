import 'package:flutter/material.dart';
import 'package:foodie/constants/constants.dart';
import 'package:foodie/screens/navbar_screen.dart';

class OrderPlacedSplashScreen extends StatelessWidget {
  const OrderPlacedSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavbarScreen()),
      );
    });
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              "Order has been placed!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              color: primaryButtonColor,
            ),
          ],
        ),
      ),
    );
  }
}
