class FoodModel {
  final String imagePath;
  bool isAddToCart;
  bool isFev;
  final String name;
  final String price;
  final String description;
  String? foodNameId;
  String? id;

  FoodModel(
      {required this.imagePath,
      required this.isAddToCart,
      required this.isFev,
      required this.name,
      required this.price,
      required this.description,
      this.foodNameId,
      this.id});

  Map<String, dynamic> foodMap() {
    return {
      "imagePath": imagePath,
      "description": description,
      "isAddToCart": isAddToCart,
      "isFev": isFev,
      "name": name,
      "price": price,
      "id": id
    };
  }
}
