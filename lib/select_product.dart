import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectProduct extends StatefulWidget {
  final Function(String) onProductAdded; // Функция обратного вызова

  const SelectProduct({Key? key, required this.onProductAdded}) : super(key: key);

  @override
  _SelectProductState createState() => _SelectProductState();
}

class _SelectProductState extends State<SelectProduct> {
  List<dynamic> filtered = [];
  String query = '';

  Future<void> fetchData(String query) async {
    final response = await http.get(
      Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&json=true'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        filtered = data['products']?.where((product) =>
          product['product_name'] != null && 
          _isCyrillic(product['product_name']))?.toList() ?? []; 
      });
    } else {
      throw Exception('Не удалось загрузить продукты');
    }
  }

  bool _isCyrillic(String text) {
    // Проверка, содержит ли строка кириллические символы
    final regex = RegExp(r'[\u0400-\u04FF]');
    return regex.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск Продуктов'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (text) {
                  query = text;
                  if (text.isNotEmpty) {
                    fetchData(query);
                  } else {
                    setState(() {
                      filtered.clear(); 
                    });
                  }
                },
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Введите название продукта',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.teal),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        filtered[index]['product_name'] ?? 'Неизвестный продукт',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Калорийность: ${filtered[index]['nutriments']?['energy-kcal'] ?? 'N/A'} Ккал',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add, color: Colors.teal),
                        onPressed: () {
                          String productName = filtered[index]['product_name'] ?? 'Неизвестный продукт';
                          widget.onProductAdded(productName);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$productName добавлен в избранное!')),
                          );
                        },
                      ),
                      onTap: () {
                        _showProductDetail(filtered[index]); 
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetail(dynamic product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product['product_name'] ?? 'Неизвестный продукт'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Калорийность: ${product['nutriments']?['energy-kcal'] ?? 'N/A'} Ккал'),
                Text('Углеводы: ${product['nutriments']?['carbohydrates_100g'] ?? 'N/A'} г'),
                Text('Белки: ${product['nutriments']?['proteins_100g'] ?? 'N/A'} г'),
                Text('Жиры: ${product['nutriments']?['fat_100g'] ?? 'N/A'} г'),
                const SizedBox(height: 10),
                Text('Описание: ${product['description'] ?? 'Нет описания'}'),
                
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Закрыть'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
