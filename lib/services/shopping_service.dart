import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';

// Contrairement aux tâches, la liste de courses n'est jamais remise à zéro
// automatiquement : elle reste telle quelle jusqu'au passage au marché.
class ShoppingService {
  static const String _itemsKey = 'shopping_items';

  // Charger les articles
  Future<List<ShoppingItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(_itemsKey);

    if (itemsJson == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(itemsJson);
    return decoded.map((json) => ShoppingItem.fromJson(json)).toList();
  }

  // Sauvegarder les articles
  Future<void> saveItems(List<ShoppingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_itemsKey, itemsJson);
  }
}
