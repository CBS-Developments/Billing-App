
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Bill> salesData = [];

  Future<List<Bill>> getSalesList() async {
    salesData.clear(); // Assuming that `comments` is a List<Comment> in your class


    const url = "http://dev.workspace.cbs.lk/getSales.php";
    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName("utf-8"),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        return jsonResponse.map((sec) => Bill.fromJson(sec)).toList();
      }

      return [];
    } else {
      throw Exception(
          'Failed to load data from the API. Status Code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sales"),
      ),
body: FutureBuilder<List<Bill>>(
  future: getSalesList(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      List<Bill>? data = snapshot.data;
      return ListView.builder(
        itemCount: data!.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            data[index].billNo,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors
                                    .blueAccent),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Row(
                            children: [
                              Text(
                                data[index]
                                    .billDate,
                                style: TextStyle(
                                    fontSize: 10,
                                    color:
                                    Colors.grey),
                              ),
                              Text(
                                '    by: ',
                                style: TextStyle(
                                    fontSize: 10,
                                    color:
                                    Colors.grey),
                              ),
                              Text(
                                data[index]
                                    .subTotal,
                                style: TextStyle(
                                    fontSize: 10,
                                    color:
                                    Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // You can add more ListTile properties as needed
                ),
                Divider()
                // Add dividers or spacing as needed between ListTiles
                // Example: Adds a divider between ListTiles
              ],
            ),
          );
        },
      );
    } else if (snapshot.hasError) {
      return const Text("-Empty-");
    }
    return const Text("Loading...");
  },
),

    );
  }
}


class Bill {
  final String billNo;
  final String dateTime;
  final String billDate;
  final String billMonth;
  final String cashier;
  final String billDetails;
  final String subTotal;

  Bill({
    required this.billNo,
    required this.dateTime,
    required this.billDate,
    required this.billMonth,
    required this.cashier,
    required this.billDetails,
    required this.subTotal,
  });

  // Factory constructor to convert JSON to a Bill object
  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      billNo: json['bill_no'],
      dateTime: json['date_time'],
      billDate: json['bill_date'],
      billMonth: json['bill_month'],
      cashier: json['cashier_'],
      billDetails: json['bill_details'],
      subTotal: json['sub_total'],
    );
  }
}
