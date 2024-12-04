class CartFoodModel {
  final String imagePath;
  final String name;
  int quantity;
  final double price;
  final String foodNameId;
  String? id;

  CartFoodModel({
    required this.imagePath,
    required this.name,
    required this.quantity,
    required this.price,
    required this.foodNameId,
    this.id,
  });

  Map<String, dynamic> cardFoodMap() {
    return {
      "imagePath": imagePath,
      "name": name,
      "quantity": quantity,
      "price": price
    };
  }
}
