import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:foodie/constants/constants.dart';
import 'package:foodie/controller/sessiondata.dart';
import 'package:foodie/models/food_model.dart';
import 'package:foodie/widgets/title_text.dart';

class ItemContainer extends StatefulWidget {
  final int index;
  final String id;
  final FoodModel obj;
  ItemContainer(
      {Key? key, required this.index, required this.obj, required this.id})
      : super(key: key);

  @override
  _ItemContainerState createState() => _ItemContainerState();
}

class _ItemContainerState extends State<ItemContainer> {
  void updateFirebaseData(bool isFev, bool isAddToCart) async {
    if (isFev || isAddToCart) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(Sessiondata.email)
          .collection('food')
          .doc(widget.id)
          .collection("types")
          .doc(widget.obj.id)
          .update({"isFev": isFev, "isAddToCart": isAddToCart});
    } else {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(Sessiondata.email)
          .collection('food')
          .doc(widget.id)
          .collection("types")
          .doc(widget.obj.id)
          .update({"isFev": isFev, "isAddToCart": isAddToCart});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryTextColor,
              primaryButtonColor,
              primaryTextColor,
              primaryButtonColor,
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              widget.obj.imagePath,
              height: 90,
              width: 90,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                TitleText(
                  text: widget.obj.name,
                  fontSize: 20,
                  color: darkTextColor,
                ),
                const SizedBox(height: 5),
                TitleText(
                  text: "${widget.obj.description}",
                  fontSize: 16,
                  color: darkTextColor,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.currency_rupee),
                    TitleText(
                      text: "${widget.obj.price}",
                      fontSize: 18,
                      color: darkTextColor,
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          widget.obj.isFev = !widget.obj.isFev;
                        });

                        updateFirebaseData(
                            widget.obj.isFev, widget.obj.isAddToCart);
                      },
                      child: widget.obj.isFev
                          ? Icon(
                              Icons.favorite_rounded,
                              size: 25,
                              color: Colors.red,
                            )
                          : Icon(
                              Icons.favorite_border_outlined,
                              size: 25,
                            ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          widget.obj.isAddToCart = !widget.obj.isAddToCart;
                        });

                        updateFirebaseData(
                            widget.obj.isFev, widget.obj.isAddToCart);
                      },
                      child: widget.obj.isAddToCart
                          ? Icon(
                              Icons.shopping_cart_rounded,
                              size: 25,
                              color: Colors.lightGreen,
                            )
                          : Icon(
                              Icons.shopping_cart_outlined,
                              size: 25,
                            ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
