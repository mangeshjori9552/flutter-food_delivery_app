import 'package:flutter/material.dart';
import 'package:foodie/constants/constants.dart';
import 'package:foodie/models/food_model.dart';
import 'package:foodie/widgets/title_text.dart';

class DelayedContainer extends StatefulWidget {
  final int index;
  final FoodModel obj;
  DelayedContainer({
    Key? key,
    required this.index,
    required this.obj,
  }) : super(key: key);

  @override
  _DelayedContainerState createState() => _DelayedContainerState();
}

class _DelayedContainerState extends State<DelayedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    Future.delayed(Duration(milliseconds: widget.index * 300), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Stack(
        children: [
          Container(
              // height: 350,
              // width: double.infinity,
              ),
          Container(
            height: 250,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 80),
            padding: const EdgeInsets.all(5),
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                )),
            child: Column(
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: TitleText(
                    text: widget.obj.name,
                    fontSize: 18,
                    color: darkTextColor,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                widget.obj.imagePath,
                height: 140,
                // fit: BoxFit.cover,
                width: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
