import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodie/constants/constants.dart';
import 'package:foodie/controller/sessiondata.dart';
import 'package:foodie/screens/navbar_screen.dart';
import 'package:foodie/screens/register_screen.dart';
import 'package:foodie/widgets/custom_text_field.dart';
import 'package:foodie/widgets/info_text.dart';
import 'package:foodie/widgets/primary_button.dart';
import 'package:foodie/widgets/title_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodie/widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _showPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(),
                const SizedBox(),
                SvgPicture.asset(
                  'assets/images/login.svg',
                  height: 250,
                  width: 250,
                ),
                const TitleText(
                    text: "Log in", fontSize: 25, color: primaryTextColor),
                Column(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      hintText: "Enter your email",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: _showPassword,
                      style: TextStyle(color: primaryTextColor),
                      decoration: InputDecoration(
                        filled: true,
                        hintText: "Enter your password",
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: lightButtonColor,
                        ),
                        hintStyle: const TextStyle(
                          color: lightButtonColor,
                        ),
                        fillColor: textFieldBackColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: lightButtonColor,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _showPassword = !_showPassword;
                            setState(() {});
                          },
                          child: Icon((_showPassword)
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                      ),
                    ),
                  ],
                ),
                PrimaryButton(
                  buttonText: "Sign in",
                  onTap: () async {
                    if (_emailController.text.trim().isNotEmpty &&
                        _passwordController.text.trim().isNotEmpty) {
                      try {
                        UserCredential userCredential =
                            await _firebaseAuth.signInWithEmailAndPassword(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim());

                        /// RETRIEVE DATA FROM FIRESTORE 'USERS' COLLECTION
                        // DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
                        DocumentSnapshot userDoc = await FirebaseFirestore
                            .instance
                            .collection('Users')
                            .doc(userCredential.user!.email!)
                            .get();

                        // if (userDoc.exists) {
                        Map<String, dynamic> userData =
                            userDoc.data() as Map<String, dynamic>;

                        /// SAVE USER DETAILS TO SHAREDPREFERENCE
                        await Sessiondata.storeSessionData(
                            isLogin: true,
                            uid: userCredential.user!.uid,
                            name: userData['name'],
                            email: userData['email'],
                            mobile: userData['mobile'],
                            profilePhoto: userData['profilePhoto'],
                            password: userData['password'],
                            address: '');

                        // }

                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const NavbarScreen()));
                      } on FirebaseAuthException catch (error) {
                        CustomSnackbar.showCustomSnackBar(
                            context: context, message: error.code);
                      }
                    }
                  },
                ),
                seperator(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    authButton(
                      imagePath: "assets/images/facebook.png",
                    ),
                    authButton(
                      imagePath: "assets/images/google.png",
                    ),
                    authButton(
                      imagePath: "assets/images/apple.png",
                    ),
                  ],
                ),
                const SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InfoText(
                        text: "Create a new account > ",
                        color: primaryTextColor,
                        fontSize: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()));
                      },
                      child: InfoText(
                          text: "Sign Up",
                          color: secondaryTextColor,
                          fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container authButton({required String imagePath}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: textFieldBackColor,
      ),
      child: Image.asset(
        height: 40,
        width: 40,
        fit: BoxFit.contain,
        imagePath,
      ),
    );
  }

  Row seperator() {
    return Row(
      children: [
        Expanded(child: divider()),
        const SizedBox(width: 15),
        const TitleText(text: "or", fontSize: 15, color: lightButtonColor),
        const SizedBox(width: 15),
        Expanded(child: divider()),
      ],
    );
  }

  Container divider() {
    return Container(
      height: 0.6,
      decoration: BoxDecoration(
        color: lightButtonColor,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
