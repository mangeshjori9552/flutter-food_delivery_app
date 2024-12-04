import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodie/constants/constants.dart';
import 'package:foodie/controller/sessiondata.dart';
import 'package:foodie/models/cart_food_model.dart';
import 'package:foodie/screens/checkout_screen.dart';
import 'package:foodie/widgets/title_text.dart';
import 'package:foodie/widgets/info_text.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void getFirebaseCartData() async {
    QuerySnapshot response = await FirebaseFirestore.instance
        .collection('Users')
        .doc(Sessiondata.email)
        .collection("food")
        .get();

    for (var value in response.docs) {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection('Users')
          .doc(Sessiondata.email)
          .collection("food")
          .doc(value['name'])
          .collection("types")
          .get();
      for (var element in data.docs) {
        if (element['isAddToCart'] == true) {
          cartItems.add(CartFoodModel(
            imagePath: element['imagePath'],
            foodNameId: value['name'],
            name: element['name'],
            price: double.parse(element['price']),
            id: element.id,
            quantity: 1,
          ));
        }
      }
    }

    setState(() {});
  }

  List<CartFoodModel> cartItems = [];

  @override
  void initState() {
    super.initState();
    getFirebaseCartData();
  }

  void addToCart(Map<String, dynamic> food) {
    // Logic for adding the item to the cart
    print('${food['name']} added to Cart!');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food['name']} added to Cart!')),
    );
  }

  double get totalPrice {
    double total = 0;
    cartItems.forEach((item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: primaryButtonColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return CartItemCard(
                    name: cartItems[index].name,
                    price: cartItems[index].price,
                    quantity: cartItems[index].quantity,
                    image: cartItems[index].imagePath,
                    onQuantityChanged: (newQuantity) {
                      setState(() {
                        cartItems[index].quantity = newQuantity;
                      });
                    },
                    onRemove: () async {
                      log("${cartItems[index].id}");

                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(Sessiondata.email)
                          .collection("food")
                          .doc(cartItems[index].foodNameId)
                          .collection("types")
                          .doc(cartItems[index].id)
                          .update({"isAddToCart": false});
                      setState(() {
                        cartItems.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            CartSummary(totalPrice: totalPrice),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                            totalAmount: (totalPrice - 10 + 5),
                            cartItems: cartItems,
                          )));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: primaryButtonColor,
                ),
                child: const Text(
                  "Proceed to Checkout",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final String name;
  final String image;
  final double price;
  final int quantity;
  final Function(int) onQuantityChanged;
  final Function onRemove;

  const CartItemCard({
    Key? key,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black26,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Image.asset(image, height: 70, width: 70),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 170,
                  child: TitleText(
                    text: name,
                    fontSize: 16,
                    color: primaryTextColor,
                  ),
                ),
                InfoText(
                  text: "${price.toStringAsFixed(2)}",
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          onQuantityChanged(quantity - 1);
                        }
                      },
                      icon: const Icon(Icons.remove, color: primaryTextColor),
                    ),
                    Text(
                      quantity.toString(),
                      style: TextStyle(fontSize: 16, color: primaryTextColor),
                    ),
                    IconButton(
                      onPressed: () {
                        onQuantityChanged(quantity + 1);
                      },
                      icon: const Icon(Icons.add, color: primaryTextColor),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () => onRemove(),
              icon: const Icon(Icons.remove_circle, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  final double totalPrice;

  const CartSummary({Key? key, required this.totalPrice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black26,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoText(
                  text: "Subtotal",
                  color: primaryTextColor,
                  fontSize: 20,
                ),
                InfoText(
                  text: "${totalPrice.toStringAsFixed(2)}",
                  color: primaryTextColor,
                  fontSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoText(
                  text: "Discount",
                  color: primaryTextColor,
                  fontSize: 20,
                ),
                totalPrice != 0
                    ? InfoText(
                        text: "-50.00",
                        color: Colors.green,
                        fontSize: 20,
                      )
                    : InfoText(
                        text: "0.00",
                        color: Colors.green,
                        fontSize: 20,
                      ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoText(
                  text: "Shipping",
                  color: primaryTextColor,
                  fontSize: 20,
                ),
                totalPrice != 0
                    ? InfoText(
                        text: "75.00",
                        color: primaryTextColor,
                        fontSize: 20,
                      )
                    : InfoText(
                        text: "\$0.00",
                        color: primaryTextColor,
                        fontSize: 20,
                      ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(thickness: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleText(text: "Total", fontSize: 18, color: primaryTextColor),
                totalPrice != 0
                    ? TitleText(
                        text: "${(totalPrice - 10 + 5).toStringAsFixed(2)}",
                        fontSize: 18,
                        color: primaryTextColor,
                      )
                    : TitleText(
                        text: "0.00",
                        fontSize: 18,
                        color: primaryTextColor,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
