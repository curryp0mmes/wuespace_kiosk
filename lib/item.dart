import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wuespace_kiosk/main.dart';

class Item {
  final int id;
  final String name;
  final int price;
  final String image;

  Item({required this.id, required this.name, required this.price, required this.image});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
//      'image': image,
    };
  }
}

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  ItemListScreenState createState() => ItemListScreenState();
}

class ItemListScreenState extends State<ItemListScreen> {
  List<Item> items = [];
  bool isLoading = true;
  int itemsPerRow = 4;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  String renderPrice(int price) {
    int euros = (price / 100).truncate();
    int cents = price % 100;
    
    return "${euros},${cents<10?'0':''}${cents}€";
  }

  Future<void> loadItems() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/wuespace_kiosk/items.json';
      final file = File(filePath);

      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonData = jsonDecode(contents) as List;  

        setState(() {
          items = jsonData.where((item) => item['hidden'] == null || item['hidden'] == false).map((json) => Item.fromJson(json)).toList();
          int len = items.length;
          if(len % 4 != 0) {
            if (len % 3 == 0) {
              itemsPerRow = 3;
            }
          }
          isLoading = false;
        });
      } else {
        print('File not found at: $filePath');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to load items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verfügbare Produkte'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 12,))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: itemsPerRow, // items per row
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.0, // Square items
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () {
                      // Open the user selection screen to apply item price
                      (context.findAncestorStateOfType<MainScreenState>()
                              as MainScreenState)
                          .openUserSelectionScreenForItem(item);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.memory(
                                base64Decode(item.image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Column(
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  renderPrice(item.price),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
