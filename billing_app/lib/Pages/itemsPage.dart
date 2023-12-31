import 'package:billing_app/Pages/itemsAddingPage.dart';
import 'package:billing_app/Pages/priceChangePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../colors.dart';
import '../sizes.dart';
import 'addStockPage.dart';
import 'homePage.dart';

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
      throw Exception(
          'Failed to load data from the API. Status Code: ${response.statusCode}');
    }
  }

  void showRemoveConfirmationDialog(BuildContext context, String itemCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Remove'),
          content: const Text('Are you sure you want to remove this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();

              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                removeItem(itemCode);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> removeItem(
      String itemCode,
      ) async {
    // Prepare the data to be sent to the PHP script.
    var data = {
      "item_code": itemCode,
      "status_": '0',
    };

    // URL of your PHP script.
    const url = "http://dev.workspace.cbs.lk/removeItem.php";

    try {
      final res = await http.post(
        Uri.parse(url),
        body: data,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      if (res.statusCode == 200) {
        final responseBody = jsonDecode(res.body);

        // Debugging: Print the response data.
        print("Response from PHP script: $responseBody");

        if (responseBody == "true") {
          print('Remove Successful');
          Navigator.of(context).pop(); // Close the dialog
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ItemsPage()),);

          return true; // PHP code was successful.
        } else {
          print('PHP code returned "false".');
          return false; // PHP code returned "false."
        }
      } else {
        print('HTTP request failed with status code: ${res.statusCode}');
        return false; // HTTP request failed.
      }
    } catch (e) {
      print('Error occurred: $e');
      return false; // An error occurred.
    }
  }


  void showMoreOptions(Item selectedItem) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Row(
                children: [
                  Text('Change Price'),
                  Icon(Icons.price_change_outlined)
                ],
              ),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PriceChangePage(item: selectedItem),
                  ),
                );
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Text('Add Stock'),
                  Icon(Icons.add_box_outlined)
                ],
              ),
              onTap: () {
                // Implement the logic for adding stock
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddStockPage(item: selectedItem),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${items[index].itemCode} | ${items[index].name}'),
                              Text('Rs:${items[index].price.toStringAsFixed(2)}'),
                              Text('Quantity: ${items[index].availableQuantity}'),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  showRemoveConfirmationDialog(context, items[index].itemCode);
                                },
                                icon: Icon(
                                  Icons.remove_circle_outline_rounded,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Remove Item',
                              ),
                              IconButton(
                                onPressed: () {
                                  showMoreOptions(items[index]);
                                },
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.black,
                                ),
                                tooltip: 'More',
                              )
                            ],
                          ),
                        ],
                      ),
                      // Add more details if needed
                    ),
                    Divider(color: AppColor.lightGreen,)
                  ],
                );
              },
            ),
          ),
          Container(
            width: getPageWidth(context),
            height: 70,
            color: Colors.white,
          )
        ],
      ),

      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddingItemsPage()),);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(AppColor.darkGreen),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: BorderSide(color: AppColor.appWhite),
            ),
          ),
        ),
        child: Container(
            height: 45,
            width: 80,

            child: Center(child: Text('Add Items',style: TextStyle(color: Colors.white,fontSize: 16),))),
      ),
    );
  }
}

class Item {
  final String itemCode;
  final String name;
  final double price;
  final int availableQuantity;

  // Use named parameters for the constructor
  Item({
    required this.itemCode,
    required this.name,
    required this.price,
    required this.availableQuantity,
  });

  // Factory constructor to convert JSON to an Item object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemCode: json['item_code'],
      name: json['item_name'],
      price: double.parse(json['price'].toString()),
      availableQuantity: int.parse(json['available_quantity'].toString()),
    );
  }
}
