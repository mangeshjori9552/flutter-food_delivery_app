import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodie/constants/constants.dart';
import 'package:foodie/controller/sessiondata.dart';
import 'package:foodie/screens/login_screen.dart';
import 'package:foodie/screens/orders.dart';
import 'package:foodie/widgets/custom_snackbar.dart';
import 'package:foodie/widgets/title_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  XFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    Sessiondata.getSessionData();

    loadUserData();
  }

  Future<void> loadUserData() async {
    _nameController.text = Sessiondata.name;
    _emailController.text = Sessiondata.email;
    _mobileController.text = Sessiondata.mobile;
    _addressController.text = Sessiondata.address;
  }

  Future<void> updateFirestore(String key, String value) async {
    if (Sessiondata.email == "") return;

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(Sessiondata.email)
        .update({
      key: value,
    });
    CustomSnackbar.showCustomSnackBar(
        message: 'Profile updated successfully!', context: context);
    // Update SharedPreferences
  }

  Future<void> uploadImage({required String filename}) async {
    /// ADD image to firebase storage
    await FirebaseStorage.instance.ref().child(filename).putFile(
          File(_selectedFile!.path),
        );
  }

  Future<String> downloadImageURL({required String filename}) async {
    /// GET the url of the uploaded image from firebase storage

    String url =
        await FirebaseStorage.instance.ref().child(filename).getDownloadURL();
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: const TitleText(
          text: "Profile",
          fontSize: 24,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  Container(
                    //color: lightButtonColor,
                    width: 150,
                    height: 150,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: primaryButtonColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: (Sessiondata.profilePhoto != "")
                        ? Image.network(
                            Sessiondata.profilePhoto,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.person, size: 100),
                  ),
                  Positioned(
                    right: 5,
                    bottom: 5,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: primaryButtonColor,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.black)),
                      child: GestureDetector(
                          onTap: () async {
                            _selectedFile = await _imagePicker.pickImage(
                                source: ImageSource.gallery);
                            if (_selectedFile != null) {
                              log(_selectedFile.toString());
                              String filename = await _selectedFile!.name +
                                  DateTime.now().toString();
                              await uploadImage(filename: filename);
                              String url =
                                  await downloadImageURL(filename: filename);
                              await updateFirestore("profilePhoto", url);
                              // Update SharedPreferences
                              await Sessiondata.storeSessionData(
                                  isLogin: true,
                                  uid: Sessiondata.uid,
                                  name: Sessiondata.name,
                                  email: Sessiondata.email,
                                  mobile: Sessiondata.mobile,
                                  profilePhoto: url,
                                  password: Sessiondata.password,
                                  address: Sessiondata.address);

                              // setState(() {
                              //   profilePhoto = url;
                              // });
                            }
                          },
                          child:
                              Icon(Icons.edit, size: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 40,
              width: 300,
              child: TextField(
                controller: _nameController,
                textAlign: TextAlign.center, // Centers the entered text
                textAlignVertical:
                    TextAlignVertical.center, // Centers text vertically
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: "Enter Name",
                  hintStyle: TextStyle(
                      color: primaryTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) async {
                  updateFirestore('name', value);
                  // Update SharedPreferences
                  await Sessiondata.storeSessionData(
                      isLogin: true,
                      uid: Sessiondata.uid,
                      name: value,
                      email: Sessiondata.email,
                      mobile: Sessiondata.mobile,
                      profilePhoto: Sessiondata.profilePhoto,
                      password: Sessiondata.password,
                      address: Sessiondata.address);
                },
              ),
            ),
            SizedBox(
              height: 30,
              width: 300,
              child: TextField(
                controller: _emailController,
                readOnly: true,
                textAlign: TextAlign.center, // Centers the entered text
                textAlignVertical:
                    TextAlignVertical.center, // Centers text vertically
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 100,
              width: 300,
              child: TextField(
                controller: _addressController,
                textAlign: TextAlign.center, 
                maxLines: 3,// Centers the entered text
                textAlignVertical:
                    TextAlignVertical.center, // Centers text vertically
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: "Enter Address",
                  hintStyle: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) async {
                  updateFirestore('address', value);

                  // Update SharedPreferences
                  await Sessiondata.storeSessionData(
                      isLogin: true,
                      uid: Sessiondata.uid,
                      name: Sessiondata.name,
                      email: Sessiondata.email,
                      mobile: Sessiondata.mobile,
                      profilePhoto: Sessiondata.profilePhoto,
                      password: Sessiondata.password,
                      address : value);
                },
              ),
            ),
            const SizedBox(height: 10),

            // Account Options
            ProfileOption(
              icon: Icons.shopping_bag_outlined,
              title: "My Orders",
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => OrdersScreen()));
              },
            ),
            ProfileOption(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              onTap: () {},
            ),
            ProfileOption(
              icon: Icons.settings_outlined,
              title: "Settings",
              onTap: () {},
            ),
            ProfileOption(
              icon: Icons.help_outline,
              title: "Help & Support",
              onTap: () {},
            ),
            ProfileOption(
              icon: Icons.logout,
              title: "Log Out",
              onTap: () async {
                // Handle logout
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.clear(); // Clears all stored data

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOption({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 28, color: primaryButtonColor),
            const SizedBox(width: 20),
            Expanded(
              child: TitleText(
                text: title,
                fontSize: 18,
                color: primaryTextColor,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
