import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ItemsPage extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    fetchItems().then((fetchedItems) {
      setState(() {
        items = fetchedItems;
      });
    });
  }

  Future<List<Item>> fetchItems() async {
    const url = "http://dev.workspace.cbs.lk/getItems.php";
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        return jsonResponse.map((item) => Item.fromJson(item)).toList();
      }

      return [];
    } else {
      throw Exception('Failed to load data from the API. Status Code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index].name),
            subtitle: Text('Rs:${items[index].price.toStringAsFixed(2)}'),
            // Add more details if needed
          );
        },
      ),
    );
  }
}

class Item {
  final String itemCode;
  final String name;
  final double price;

  Item({
    required this.itemCode,
    required this.name,
    required this.price,
  });

  // Factory constructor to convert JSON to an Item object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemCode: json['item_code'],
      name: json['item_name'],
      price: double.parse(json['price'].toString()),
    );
  }
}
