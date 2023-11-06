import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Bill> salesData = [];

  Future<List<Bill>> getSalesList() async {
    salesData.clear();

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
    return DefaultTabController(
      length: 3, // Number of tabs (All, Today, This Month)
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sales"),
          bottom: TabBar(
            tabs: [
              Tab(text: "All"),
              Tab(text: "Today"),
              Tab(text: "This Month"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildSalesList("All"),
            buildSalesList("Today"),
            buildSalesList("This Month"),
          ],
        ),
      ),
    );
  }

  // A helper method to build the sales list based on the selected tab
  Widget buildSalesList(String tabName) {
    return FutureBuilder<List<Bill>>(
      future: getSalesList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Bill>? data = snapshot.data;
          data = filterSalesData(data, tabName); // Filter data based on tab
          return ListView.builder(
            itemCount: data!.length,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Bill No: ',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                  SelectableText(
                                    data![index].billNo,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.blueAccent),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                   '${data![index].customer} | ${data![index].billDate} ${data![index].dateTime} ',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min, // This ensures the Container only takes the width of its child
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey.shade500,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          children: [
                                            Text(' Rs. ${data![index].subTotal} ', style: TextStyle(fontSize: 15))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                    Divider()
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
    );
  }

  // A helper method to filter data based on the selected tab
  List<Bill> filterSalesData(List<Bill>? data, String tabName) {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final currentMonth = DateFormat('yyyy-MM').format(now);

    switch (tabName) {
      case "Today":
        final todayDate = formatter.format(now);
        return data?.where((bill) => bill.billDate == todayDate).toList() ?? [];
      case "This Month":
        return data?.where((bill) => bill.billMonth == currentMonth).toList() ?? [];
      default:
        return data ?? [];
    }
  }
}



class Bill {
  final String billNo;
  final String customer;
  final String dateTime;
  final String billDate;
  final String billMonth;
  final String cashier;
  final String billDetails;
  final String subTotal;

  Bill({
    required this.billNo,
    required this.customer,
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
      customer: json['customer_'],
      dateTime: json['date_time'],
      billDate: json['bill_date'],
      billMonth: json['bill_month'],
      cashier: json['cashier_'],
      billDetails: json['bill_details'],
      subTotal: json['sub_total'],
    );
  }
}
