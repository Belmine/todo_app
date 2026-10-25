class ShoppingItem {
  final String id;
  final String name;
  final double estimatedPrice;
  bool isBought;
  final DateTime createdAt;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.estimatedPrice,
    this.isBought = false,
    required this.createdAt,
  });

  // Convertir en JSON pour le stockage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'estimatedPrice': estimatedPrice,
      'isBought': isBought,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Créer un article depuis JSON
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      estimatedPrice: (json['estimatedPrice'] as num).toDouble(),
      isBought: json['isBought'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
