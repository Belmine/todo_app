import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/shopping_item.dart';
import '../services/shopping_service.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final ShoppingService _shoppingService = ShoppingService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  final NumberFormat _wholeAmountFormat = NumberFormat('#,##0', 'fr_FR');
  final NumberFormat _decimalAmountFormat = NumberFormat('#,##0.00', 'fr_FR');
  List<ShoppingItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await _shoppingService.loadItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _saveItems() async {
    await _shoppingService.saveItems(_items);
  }

  // Aucune devise affichée : selon l'utilisateur ce sont des euros, des FCFA...
  // Les décimales n'apparaissent que si le montant en a.
  String _formatAmount(double amount) {
    final format = amount == amount.roundToDouble()
        ? _wholeAmountFormat
        : _decimalAmountFormat;
    return format.format(amount);
  }

  void _addItem() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    // Accepter la virgule comme séparateur décimal, un montant vide vaut 0
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    final amount = amountText.isEmpty ? 0.0 : double.tryParse(amountText);
    if (amount == null) return;

    setState(() {
      _items.add(ShoppingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        estimatedAmount: amount,
        createdAt: DateTime.now(),
      ));
    });
    _nameController.clear();
    _amountController.clear();
    _nameFocusNode.requestFocus();
    _saveItems();
  }

  void _toggleItem(int index) {
    setState(() {
      _items[index].isBought = !_items[index].isBought;
    });
    _saveItems();
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _saveItems();
  }

  // Vider la liste des articles déjà achetés au retour du marché
  void _removeBoughtItems() {
    setState(() {
      _items.removeWhere((item) => item.isBought);
    });
    _saveItems();
  }

  // Champs sans fond ni bordure : c'est la barre qui les contient qui est stylée
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey[600],
        fontSize: 15,
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _nameFocusNode.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _items.fold<double>(0, (sum, item) => sum + item.estimatedAmount);
    final hasBoughtItems = _items.any((item) => item.isBought);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liste de courses',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[300],
            fontSize: 15,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          if (hasBoughtItems)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              color: Colors.grey[400],
              iconSize: 20,
              tooltip: 'Retirer les articles achetés',
              onPressed: _removeBoughtItems,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Total ${_formatAmount(total)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 12),

                // Formulaire d'ajout : article et montant dans une seule barre
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  focusNode: _nameFocusNode,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration('Ajouter un article...'),
                                  onSubmitted: (_) => _amountFocusNode.requestFocus(),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 24,
                                color: Colors.grey[700],
                              ),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: _amountController,
                                  focusNode: _amountFocusNode,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.right,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                                  ],
                                  textInputAction: TextInputAction.done,
                                  decoration: _inputDecoration('Montant'),
                                  onSubmitted: (_) => _addItem(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 236, 158, 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add),
                          color: Colors.white,
                          iconSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Liste des articles
                Expanded(
                  child: _items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun article dans la liste',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ajoutez ce qu\'il vous faut pour vos courses.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[800]!,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: item.isBought,
                                    onChanged: (_) => _toggleItem(index),
                                    activeColor: const Color(0xFFFFB800),
                                    side: BorderSide(
                                      color: Colors.grey[600]!,
                                      width: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        decoration: item.isBought
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: item.isBought
                                            ? Colors.grey[600]
                                            : Colors.grey[200],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatAmount(item.estimatedAmount),
                                    style: TextStyle(
                                      fontSize: 14,
                                      decoration: item.isBought
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: item.isBought
                                          ? Colors.grey[600]
                                          : Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    color: Colors.grey[600],
                                    iconSize: 18,
                                    onPressed: () => _deleteItem(index),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
