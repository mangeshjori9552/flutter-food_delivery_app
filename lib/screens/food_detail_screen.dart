import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodie/constants/constants.dart';
import 'package:foodie/controller/sessiondata.dart';
import 'package:foodie/models/food_model.dart';
import 'package:foodie/widgets/item_container.dart';
import 'package:foodie/widgets/title_text.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodName;
  final String description;

  final String imageUrl;

  FoodDetailScreen({
    super.key,
    required this.foodName,
    required this.description,
    required this.imageUrl,
  });

  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int quantity = 1;

  List<FoodModel> foodTypeList = [];

  void getFoodData() async {
    foodTypeList.clear();
    QuerySnapshot response = await FirebaseFirestore.instance
        .collection('Users')
        .doc(Sessiondata.email)
        .collection('food')
        .doc(widget.foodName)
        .collection("types")
        .get();

    for (var element in response.docs) {
      foodTypeList.add(FoodModel(
        imagePath: element['imagePath'],
        isAddToCart: element['isAddToCart'],
        isFev: element['isFev'],
        name: element['name'],
        price: element['price'],
        description: element['description'],
        id: element.id,
      ));
    }

    setState(() {});
    print(foodTypeList);
  }

  @override
  void initState() {
    super.initState();
    getFoodData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryButtonColor,
        title: Text(widget.foodName),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    widget.imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TitleText(
                text: widget.foodName,
                fontSize: 24,
                color: primaryTextColor,
              ),
              const SizedBox(height: 10),
              Text(
                widget.description,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: foodTypeList.length,
                primary: false,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {},
                    child: ItemContainer(
                      index: index,
                      id: widget.foodName,
                      obj: foodTypeList[index],
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
