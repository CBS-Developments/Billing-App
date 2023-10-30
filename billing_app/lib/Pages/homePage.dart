import 'package:billing_app/Pages/printerPage.dart';
import 'package:flutter/material.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {



  List<Item> items = [
    Item("Sudu Kakulu", 200.00, 0, 0.00),
    Item("Supuri Nadu", 170.00, 0, 0.00),
    Item("Rathu Kakulu", 230.00, 0, 0.00),
    Item("Kiiri Samba", 270.00, 0, 0.00),
    Item("Basmathi", 400.00, 0, 0.00),
    Item("Rathu Nadu", 190.00, 0, 0.00),
    Item("Kakulu Samba", 220.00, 0, 0.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mega Mart'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ItemTile(
            item: items[index],
            onQuantityChanged: (int value) {
              setState(() {
                items[index].quantity = value;
                if (items[index].isSelected) {
                  items[index].total = value * items[index].price; // Update the total if selected
                }
              });
            },
            onSelectedChanged: (bool value) {
              setState(() {
                items[index].isSelected = value;
                if (value) {
                  items[index].total = items[index].quantity * items[index].price; // Update the total when selecting
                } else {
                  items[index].total = 0; // Set the total to 0 when deselecting
                }
              });
            },
          );
        },
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          // Filter selected items
          List<Item> selectedItems = items.where((item) => item.isSelected).toList();

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
              builder: (context) => PrinterPage(selectedItems: selectedItems, subTotal: stSubtotal,),
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
      print('Name: ${item.name}, Price: ${item.price.toStringAsFixed(2)}, Quantity: ${item.quantity}, Total: ${item.total.toStringAsFixed(2)}');
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
  final String name;
  final double price;
  int quantity;
  double total;
  bool isSelected;

  Item(this.name, this.price, this.quantity, this.total, {this.isSelected = false});
}
