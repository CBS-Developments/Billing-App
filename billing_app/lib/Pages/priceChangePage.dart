import 'package:billing_app/Pages/itemsPage.dart';
import 'package:flutter/material.dart';



class PriceChangePage extends StatefulWidget {
  final Item item; // Assuming Item is your data model

  const PriceChangePage({Key? key, required this.item}) : super(key: key);

  @override
  State<PriceChangePage> createState() => _PriceChangePageState();
}

class _PriceChangePageState extends State<PriceChangePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Item Price'),
      ),
      body: Center(
        child: Text('Item Details: ${widget.item.name}'), // Adjust this based on your data model
      ),
    );
  }
}
