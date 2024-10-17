import 'package:flutter/material.dart';
import 'shared_preferences_service.dart'; // Импортируем
import 'select_product.dart';
import 'dart:convert';

class Product {
  final String name;
  final int calories;
  final int carbohydrates;
  final int proteins;
  final int fat;
  final String description;

  Product({
    required this.name,
    required this.calories,
    required this.carbohydrates,
    required this.proteins,
    required this.fat,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'carbohydrates': carbohydrates,
      'proteins': proteins,
      'fat': fat,
      'description': description,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      calories: json['calories'],
      carbohydrates: json['carbohydrates'],
      proteins: json['proteins'],
      fat: json['fat'],
      description: json['description'],
    );
  }
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Product> products = []; // Список избранных продуктов
  final SharedPreferencesService prefsService = SharedPreferencesService();

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  // Загрузка избранных продуктов из shared_preferences
  void _loadFavoriteProducts() async {
    List<String>? storedProducts = await prefsService.loadFavorites();
    if (storedProducts != null) {
      setState(() {
        products = storedProducts.map((item) => Product.fromJson(jsonDecode(item))).toList();
      });
    }
  }

  // Обновление избранных продуктов и сохранение их
  void _updateFavorites() {
    List<String> storedProducts = products.map((product) => jsonEncode(product.toJson())).toList();
    prefsService.saveFavorites(storedProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справочник продуктов'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SelectProduct(onProductAdded: _addProduct)),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.teal,
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: products.length,
          itemBuilder: (context, index) {
            Product product = products[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      products.removeAt(index);
                      _updateFavorites();
                    });
                  },
                ),
                onTap: () => _showProductDetail(product),
              ),
            );
          },
        ),
      ),
    );
  }

  void _addProduct(String name) {
    // Здесь создаем новый Product с фиксированными значениями для простоты
    var newProduct = Product(
      name: name,
      calories: 200, // Пример значений, можно заменить на реальные
      carbohydrates: 50,
      proteins: 10,
      fat: 5,
      description: 'Описание для $name',
    );

    setState(() {
      products.add(newProduct);
      _updateFavorites();
    });
  }

  void _showProductDetail(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Калорийность: ${product.calories} Ккал'),
                Text('Углеводы: ${product.carbohydrates} г'),
                Text('Белки: ${product.proteins} г'),
                Text('Жиры: ${product.fat} г'),
                Text('Описание: ${product.description}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Закрыть'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
