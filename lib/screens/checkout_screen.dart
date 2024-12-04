import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodie/constants/constants.dart';
import 'package:foodie/controller/sessiondata.dart';
import 'package:foodie/screens/order_placed_screen.dart';
import 'package:foodie/widgets/title_text.dart';
import 'package:foodie/models/cart_food_model.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;
  final List<CartFoodModel> cartItems;

  const CheckoutScreen(
      {super.key, required this.totalAmount, required this.cartItems});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Cash on Delivery'; // Default payment method
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addressController.text = Sessiondata.address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: primaryButtonColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleText(
              text: "Billing Information",
              fontSize: 20,
              color: primaryTextColor,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = widget.cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: Image.asset(item.imagePath,
                                  width: 50, height: 50),
                              title: Text(item.name,
                                  style: const TextStyle(fontSize: 16)),
                              subtitle: Text("Quantity: ${item.quantity}"),
                              trailing: Text(
                                  "\$${(item.price * item.quantity).toStringAsFixed(2)}"),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Total Bill: ${widget.totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TitleText(
                        text: "Payment Method",
                        fontSize: 18,
                        color: primaryTextColor,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildPaymentOption("Cash on Delivery", Icons.money),
                          const SizedBox(width: 20),
                          _buildPaymentOption("Credit Card", Icons.credit_card),
                          const SizedBox(width: 20),
                          _buildPaymentOption("UPI", Icons.payment),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TitleText(
                        text: "Delivery Address",
                        fontSize: 18,
                        color: primaryTextColor,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _addressController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: "Enter your delivery address",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10),
                        ),
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            ),
            // Displaying cart items with name, photo, quantity
            // ListView.builder(
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   itemCount: widget.cartItems.length,
            //   itemBuilder: (context, index) {
            //     final item = widget.cartItems[index];
            //     return Card(
            //       margin: const EdgeInsets.symmetric(vertical: 5),
            //       child: ListTile(
            //         leading:
            //             Image.asset(item.imagePath, width: 50, height: 50),
            //         title:
            //             Text(item.name, style: const TextStyle(fontSize: 16)),
            //         subtitle: Text("Quantity: ${item.quantity}"),
            //         trailing: Text(
            //             "\$${(item.price * item.quantity).toStringAsFixed(2)}"),
            //       ),
            //     );
            //   },
            // ),
            // const SizedBox(height: 10),
            // Text(
            //   "Total Bill: \$${widget.totalAmount.toStringAsFixed(2)}",
            //   style:
            //       const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 20),
            // TitleText(
            //   text: "Payment Method",
            //   fontSize: 18,
            //   color: primaryTextColor,
            // ),
            // const SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     _buildPaymentOption("Cash on Delivery", Icons.money),
            //     const SizedBox(width: 20),
            //     _buildPaymentOption("Credit Card", Icons.credit_card),
            //     const SizedBox(width: 20),
            //     _buildPaymentOption("UPI", Icons.payment),
            //   ],
            // ),
            // const SizedBox(height: 20),
            // TitleText(
            //   text: "Delivery Address",
            //   fontSize: 18,
            //   color: primaryTextColor,
            // ),
            // const SizedBox(height: 10),
            // TextField(
            //   controller: _addressController,
            //   maxLines: 3,
            //   decoration: const InputDecoration(
            //     hintText: "Enter your delivery address",
            //     border: InputBorder.none,
            //     contentPadding: EdgeInsets.all(10),
            //   ),
            //   style: const TextStyle(fontSize: 16, color: Colors.white),
            // ),
            // const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      _proceedToPlaceOrder(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      "Confirm Order",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: backgroundColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color:
                _selectedPaymentMethod == method ? Colors.green : Colors.grey,
          ),
          Text(
            method,
            style: TextStyle(
              fontSize: 14,
              color:
                  _selectedPaymentMethod == method ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _proceedToPlaceOrder(BuildContext context) async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a delivery address")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(Sessiondata.email)
          .update({'address': _addressController.text});
      log(Sessiondata.address);
      await Sessiondata.storeAddress(_addressController.text);
      for (var element in widget.cartItems) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(Sessiondata.email)
            .collection("food")
            .doc(element.foodNameId)
            .collection("types")
            .doc(element.id)
            .update({"isAddToCart": false});
      }

      // Generate a unique order ID using Firestore's ID generation

      final orderDetails = {
        'items': widget.cartItems
            .map((item) => {
                  'name': item.name,
                  'imagePath': item.imagePath,
                  'quantity': item.quantity,
                  'price': item.price,
                })
            .toList(),
        'totalAmount': widget.totalAmount,
        'address': _addressController.text,
        'paymentMethod': _selectedPaymentMethod,
        'status': 'active', // Initial status
        'timestamp': Timestamp.now(),
      };

      // Add the order under the specific user's 'orders' nested collection
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(Sessiondata.email)
          .collection('orders')
          .add(orderDetails);

      // Navigate to the order placed screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const OrderPlacedSplashScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place order: $e")),
      );
    }
  }
}
