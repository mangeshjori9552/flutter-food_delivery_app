import 'package:shared_preferences/shared_preferences.dart';

class Sessiondata {
  static bool isLogin = false;
  static String uid = "";

  static String name = "";
  static String email = "";
  static String mobile = "";
  static String profilePhoto = "";
  static String password = "";
  static String address = "";

  static Future<void> storeSessionData(
      {required bool isLogin,
      required String uid,
      required String name,
      required String email,
      required String mobile,
      required String profilePhoto,
      required String password,
      required String address}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool('isLogin', isLogin);
    prefs.setString('uid', uid);
    prefs.setString('name', name);
    prefs.setString('email', email);
    prefs.setString('mobile', mobile);
    prefs.setString('profilePhoto', profilePhoto);
    prefs.setString('password', password);
    prefs.setString('address',address);

    getSessionData();
  }

  static Future<void> getSessionData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isLogin = prefs.getBool('isLogin') ?? false;
    uid = prefs.getString('uid') ?? "";
    name = prefs.getString('name') ?? "";
    email = prefs.getString('email') ?? "";
    mobile = prefs.getString('mobile') ?? "";
    profilePhoto = prefs.getString('profilePhoto') ?? "";
    password = prefs.getString('password') ?? "";
    address = prefs.getString('address') ?? "";
  }

  static Future<void> storeAddress(String address) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('address', address);
    getAddress();
  }

  static Future<void> getAddress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    address = prefs.getString('address') ?? "";
  }
}
