import 'package:billing_app/Pages/printerPage.dart';
import 'package:billing_app/Pages/salesPage.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _customerNameController = TextEditingController();

  List<Item> items = [
    Item("#001", "Samba 25Kg", 7250.00, 0, 0.00),
    Item("#002", "Naadu 25Kg", 4875.00, 0, 0.00),
    Item("#003", "Sudu Kakulu 25Kg", 5250.00, 0, 0.00),
    Item("#004", "Keeri Samba 25Kg", 8500.00, 0, 0.00),
    Item("#005", "Rosa Kakulu 25Kg", 5375.00, 0, 0.00),
    Item("#006", "Rathu Nadu 25Kg", 4250.00, 0, 0.00),
    Item("#007", "Rathu Samba 25Kg", 5500.00, 0, 0.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gunasewana Mills'),
      ),

      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            // UserAccountsDrawerHeader(
            //   accountName: Text('Your Name'),
            //   accountEmail: Text('youremail@example.com'),
            // ),
            ListTile(
              leading: Icon(Icons.business_center),
              title: Text('Sales'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalesPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: 'Customer Name',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ItemTile(
                  item: items[index],
                  onQuantityChanged: (int value) {
                    setState(() {
                      items[index].quantity = value;
                      if (items[index].isSelected) {
                        items[index].total = value * items[index].price;
                      }
                    });
                  },
                  onSelectedChanged: (bool value) {
                    setState(() {
                      items[index].isSelected = value;
                      if (value) {
                        items[index].total =
                            items[index].quantity * items[index].price;
                      } else {
                        items[index].total = 0;
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          // Filter selected items
          List<Item> selectedItems =
              items.where((item) => item.isSelected).toList();

          // Calculate subtotal for selected items
          double subtotal = 0;
          for (var item in selectedItems) {
            subtotal += item.total;
          }
          String stSubtotal = subtotal.toStringAsFixed(2);

          // Print the selected items
          printSelectedItems(selectedItems);

          // Print the subtotal
          print('Subtotal: ${stSubtotal}');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrinterPage(
                selectedItems: selectedItems,
                subTotal: stSubtotal,
                customerName: _customerNameController.text,
              ),
            ),
          );
        },
        child: Text('Print'),
      ),
    );
  }

  void printSelectedItems(List<Item> selectedItems) {
    print('Selected Items:');
    for (var item in selectedItems) {
      print(
          'Name: ${item.name}, Price: ${item.price.toStringAsFixed(2)}, Quantity: ${item.quantity}, Total: ${item.total.toStringAsFixed(2)}');
    }
  }
}

class ItemTile extends StatefulWidget {
  final Item item;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<bool> onSelectedChanged;

  ItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onSelectedChanged,
  });

  @override
  _ItemTileState createState() => _ItemTileState();
}

class _ItemTileState extends State<ItemTile> {
  int quantity = 0;
  bool selected = false;

  @override
  void initState() {
    super.initState();
    quantity = widget.item.quantity;
    selected = widget.item.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selected = !selected;
          widget.onSelectedChanged(selected);
        });
      },
      child: ListTile(
        title: Text(widget.item.name),
        subtitle: Text('Rs:${widget.item.price.toStringAsFixed(2)}'),
        leading: Checkbox(
          value: selected,
          onChanged: (newValue) {
            setState(() {
              selected = newValue ?? false;
              widget.onSelectedChanged(selected);
            });
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                if (quantity > 0) {
                  setState(() {
                    quantity--;
                    widget.onQuantityChanged(quantity);
                  });
                }
              },
            ),
            Text(quantity.toString()),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  quantity++;
                  widget.onQuantityChanged(quantity);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  final String itemCode; // Add item code property
  final String name;
  final double price;
  int quantity;
  double total;
  bool isSelected;

  Item(this.itemCode, this.name, this.price, this.quantity, this.total,
      {this.isSelected = false});
}
