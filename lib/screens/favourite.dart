import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodie/constants/constants.dart';
import 'package:foodie/controller/sessiondata.dart';
import 'package:foodie/models/food_model.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // Initialize the list of favorite items by filtering foodList

  void getFirebaseData() async {
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
        if (element['isFev'] == true) {
          favoriteItems.add(FoodModel(
              imagePath: element['imagePath'],
              isAddToCart: element['isAddToCart'],
              isFev: element['isFev'],
              name: element['name'],
              price: element['price'],
              foodNameId: value['name'],
              id: element.id,
              description: ""));
        }
      }
    }
    setState(() {});
  }

  List<FoodModel> favoriteItems = [];

  @override
  void initState() {
    super.initState();
    getFirebaseData();
  }

  void addToCart(Map<String, dynamic> food) {
    // Logic for adding the item to the cart
    print('${food['name']} added to cart!');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food['name']} added to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: const Text(
          'Favorite Foods',
          style: TextStyle(
              color: primaryTextColor,
              fontSize: 24,
              fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: favoriteItems.isEmpty
            ? Center(
                child: Text(
                  'No favorite items added yet.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : GridView.builder(
                itemCount: favoriteItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (context, index) {
                  final food = favoriteItems[index];

                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(Sessiondata.email)
                                      .collection("food")
                                      .doc(food.foodNameId)
                                      .collection("types")
                                      .doc(food.id)
                                      .update({"isFev": false});
                                  setState(() {
                                    favoriteItems.removeAt(index);
                                  });
                                },
                                child: Icon(
                                  Icons.highlight_remove_outlined,
                                  size: 25,
                                ),
                              ),
                            )
                          ],
                        ),
                        Expanded(
                          child: Image.asset(
                            food.imagePath,
                            fit: BoxFit.cover,
                            height: 100,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "\$${food.price.toString()}",
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(primaryButtonColor),
                              foregroundColor:
                                  WidgetStatePropertyAll(secondaryButtonColor)),
                          onPressed: () => addToCart(food.foodMap()),
                          child: const Text('Add to Cart'),
                        ),
                        SizedBox(height: 5)
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
