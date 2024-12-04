import 'package:flutter/material.dart';
import 'package:foodie/screens/cart.dart';
import 'package:foodie/screens/favourite.dart';
import 'package:foodie/screens/home_page.dart';
import 'package:foodie/constants/constants.dart';
import 'package:foodie/screens/orders.dart';
import 'package:foodie/screens/profile.dart';

class NavbarScreen extends StatefulWidget {
  const NavbarScreen({super.key});

  @override
  State<NavbarScreen> createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  int _selectedIndex = 0;

  // List of screens corresponding to each tab
  final List<Widget> _screens = [
    HomePage(),
    OrdersScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => CartScreen()));
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        backgroundColor: primaryButtonColor,
        child: Icon(
          Icons.shopping_cart_outlined,
          color: Colors.black45,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: primaryButtonColor,
          selectedLabelStyle:
              TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.black45,
          unselectedLabelStyle:
              TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.food_bank),
              label: "Orders",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Favourite",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ]),
    );
  }
}
