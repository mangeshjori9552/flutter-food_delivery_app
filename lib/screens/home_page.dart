import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodie/constants/constants.dart';
import 'package:foodie/controller/sessiondata.dart';
import 'package:foodie/models/food_model.dart';
import 'package:foodie/screens/food_detail_screen.dart';
import 'package:foodie/widgets/custom_text_field.dart';
import 'package:foodie/widgets/delayed_container.dart';
import 'package:foodie/widgets/info_text.dart';
import 'package:foodie/widgets/title_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _colaController;
  late AnimationController _hamburgerController;
  bool _showGrid = false;

  late Animation<Offset> _cardAnimation;
  late Animation<Offset> _colaAnimation;
  late Animation<Offset> _hamburgerAnimation;

  TextEditingController _searchFoodController = TextEditingController();

  List<FoodModel> foodList = [];

  void getFoodData() async {
    foodList.clear();
    QuerySnapshot response = await FirebaseFirestore.instance
        .collection('Users')
        .doc(Sessiondata.email)
        .collection('food')
        .get();

    for (var element in response.docs) {
      foodList.add(FoodModel(
        imagePath: element['imagePath'],
        isAddToCart: false,
        isFev: false,
        name: element['name'],
        price: "0",
        description: element['description'],
        id: element.id,
      ));
    }

    setState(() {});
    print(foodList);
  }

  @override
  void initState() {
    super.initState();
    getFoodData();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _colaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _colaAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _colaController, curve: Curves.easeOut));

    _hamburgerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _hamburgerAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _hamburgerController, curve: Curves.easeOut));

    _startAnimations();
  }

  void _startAnimations() async {
    _cardController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    _colaController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    _hamburgerController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _showGrid = true;
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _colaController.dispose();
    _hamburgerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(72), child: customAppBar()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              CustomTextField(
                  controller: _searchFoodController,
                  hintText: "Search your interesting foods...",
                  icon: Icons.search),
              const SizedBox(height: 20),
              // SizedBox(
              //   height: 120,
              //   child: FoodAvatars(),
              // ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TitleText(
                      text: "Special Offers",
                      fontSize: 20,
                      color: primaryTextColor),
                  TitleText(
                      text: "See more",
                      fontSize: 16,
                      color: secondaryTextColor),
                ],
              ),
              advertCard(),
              const SizedBox(height: 50),
              TitleText(
                  text: "Weekly Special",
                  fontSize: 20,
                  color: primaryTextColor),

              const SizedBox(height: 20),
              if (_showGrid) buildGridView(),
            ],
          ),
        ),
      ),
    );
  }

  Stack advertCard() {
    return Stack(
      children: [
        Container(height: 250, width: double.infinity),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: _cardAnimation,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: primaryTextColor,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        primaryTextColor,
                        primaryButtonColor,
                        primaryButtonColor,
                        primaryTextColor,
                        primaryButtonColor,
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Expanded(
                        flex: 16,
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleText(
                                text: "30%",
                                color: darkTextColor,
                                fontSize: 60,
                              ),
                              TitleText(
                                text: "off from\nchicken menu",
                                color: darkTextColor,
                                fontSize: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -10,
          top: -40,
          child: SlideTransition(
            position: _colaAnimation,
            child: Transform.rotate(
              angle: (-17 * 3.14) / 180,
              child: Image.asset(
                height: 250,
                width: 250,
                'assets/images/cola.png',
              ),
            ),
          ),
        ),
        Positioned(
          right: -50,
          bottom: -50,
          child: SlideTransition(
            position: _hamburgerAnimation,
            child: Image.asset(
              height: 250,
              width: 250,
              'assets/images/burger/hamburger.png',
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGridView() {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: foodList.length,
      primary: false,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => FoodDetailScreen(
                      foodName: foodList[index].name,
                      description: foodList[index].description,
                      imageUrl: foodList[index].imagePath,
                    )));
          },
          child: DelayedContainer(
            index: index,
            obj: foodList[index],
          ),
        );
      },
    );
  }

  Column customAppBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Sessiondata.profilePhoto == ""
                      ? Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: primaryButtonColor,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 30,
                          ),
                        )
                      : Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image:
                                      NetworkImage(Sessiondata.profilePhoto))),
                        ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleText(
                          text: "Customer",
                          fontSize: 19,
                          color: primaryTextColor),
                      Row(
                        children: [
                          InfoText(
                              text: Sessiondata.name,
                              color: lightButtonColor,
                              fontSize: 15),
                          const SizedBox(width: 3),
                          Icon(Icons.arrow_drop_down, color: lightButtonColor),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_none_outlined,
                      size: 30,
                      color: lightButtonColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
