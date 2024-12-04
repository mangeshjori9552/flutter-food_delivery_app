import 'package:flutter/material.dart';

class CustomSnackbar {
  static showCustomSnackBar({required String message , required BuildContext context}){

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
        message,
        style: TextStyle(
          color: Colors.black54,
          fontSize: 18,
        ),
        ),
        backgroundColor: Colors.white60,
        )
      );

  }
}