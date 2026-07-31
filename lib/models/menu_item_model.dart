class MenuItemModel {
  final String itemId;
  final String canteenId;
  final String itemName;
  final double price;
  final String description;
  final String imageUrl;
  final String category;
  bool isAvailable;

  MenuItemModel({
    required this.itemId,
    this.canteenId = '',
    required this.itemName,
    required this.price,
    this.description = '',
    required this.imageUrl,
    this.category = 'Meals',
    this.isAvailable = true,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MenuItemModel(
      itemId: documentId,
      canteenId: map['canteenId'] ?? '',
      itemName: map['itemName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'Meals',
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canteenId': canteenId,
      'itemName': itemName,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
    };
  }
}
