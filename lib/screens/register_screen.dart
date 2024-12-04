import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodie/constants/constants.dart';
import 'package:foodie/data/data.dart';
import 'package:foodie/widgets/custom_snackbar.dart';
import 'package:foodie/widgets/custom_text_field.dart';
import 'package:foodie/widgets/info_text.dart';
import 'package:foodie/widgets/primary_button.dart';
import 'package:foodie/widgets/title_text.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

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
            padding: EdgeInsets.only(
              //bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 25,
              right: 25,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(),
                const SizedBox(),
                SvgPicture.asset(
                  'assets/images/register.svg',
                  height: 250,
                  width: 250,
                ),
                const TitleText(
                    text: "Sign up", fontSize: 25, color: primaryTextColor),
                Column(
                  children: [
                    CustomTextField(
                        controller: _mobileController,
                        hintText: "Enter your phone",
                        icon: Icons.phone),
                    const SizedBox(height: 20),
                    CustomTextField(
                        controller: _nameController,
                        hintText: "Enter your name",
                        icon: Icons.person),
                    const SizedBox(height: 20),
                    CustomTextField(
                        controller: _emailController,
                        hintText: "Enter your email",
                        icon: Icons.mail),
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
                    const SizedBox(height: 20),
                  ],
                ),
                PrimaryButton(
                  buttonText: "Register",
                  onTap: () async {
                    if (_emailController.text.trim().isNotEmpty &&
                        _nameController.text.trim().isNotEmpty &&
                        _mobileController.text.trim().isNotEmpty &&
                        _passwordController.text.trim().isNotEmpty) {
                      try {
                        UserCredential userCredential =
                            await _firebaseAuth.createUserWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );

                        await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(userCredential.user!.email!)
                            .set({
                          'name': _nameController.text.trim(),
                          'email': _emailController.text.trim(),
                          'mobile': _mobileController.text.trim(),
                          'password': _passwordController.text.trim(),
                          'profilePhoto': '',
                          'address': ""
                        });

                        ///Nested Collection
                        for (var element in foodList) {
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(userCredential.user!.email!)
                              .collection('food')
                              .doc(element['name'])
                              .set({
                            'imagePath': element['imagePath'],
                            'name': element['name'],
                            'description': element['description'],
                          });

                          ///tripple
                          for (var data in element['types'])
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(userCredential.user!.email!)
                                .collection('food')
                                .doc(element['name'])
                                .collection("types")
                                .add({
                              'imagePath': data['imagePath'],
                              'name': data['name'],
                              'isAddToCart': data['isAddToCart'],
                              'description': data['description'],
                              'isFev': data['isFev'],
                              'price': data['price'],
                            });
                        }
                        // await FirebaseFirestore.instance
                        //     .collection('Users')
                        //     .doc(uid)
                        //     .set({
                        //   'name': _nameController.text.trim(),
                        //   'email': _emailController.text.trim(),
                        //   'mobile': _mobileController.text.trim(),
                        //   'password': _passwordController.text.trim(),
                        //   'profilePhoto': ''
                        // });
                        CustomSnackbar.showCustomSnackBar(
                            message: "User Registered Successfully",
                            context: context);
                        Navigator.of(context).pop();
                      } on FirebaseAuthException catch (error) {
                        CustomSnackbar.showCustomSnackBar(
                            message: error.message!, context: context);
                      }
                    } else {
                      CustomSnackbar.showCustomSnackBar(
                          message: "Please enter valid fields",
                          context: context);
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
                        text: "Already having an account? > ",
                        color: primaryTextColor,
                        fontSize: 15),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: InfoText(
                          text: "Log in",
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
