import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Bill> salesData = [];
  DateTime selectedDate = DateTime.now(); // Initialize with the current date
  String filterType = "All"; // Default filter type

  Future<List<Bill>> getSalesList(String filterType, DateTime? selectedDate) async {
    salesData.clear();

    const url = "http://dev.workspace.cbs.lk/getSales.php";
    String formattedDate = '';

    if (selectedDate != null) {
      formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    }

    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application.json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName("utf-8"),
      body: {
        "selectedDate": formattedDate,
        "filterType": filterType, // Pass the filter type to the API
      },
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
      length: 4, // Number of tabs (Today, This Month, All, Filter)
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sales"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Today"),
              Tab(text: "Month"),
              Tab(text: "All"),
              Tab( icon: Icon(Icons.filter_list),
              ), // New tab for filtering
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildSalesList("Today", selectedDate),
            buildSalesList("This Month", selectedDate),
            buildSalesList("All", selectedDate),
            buildFilterTab(), // Use a separate method for the Filter tab
          ],
        ),
      ),
    );
  }

  // A helper method to build the sales list based on the selected tab
  Widget buildSalesList(String tabName, DateTime? selectedDate) {
    return FutureBuilder<List<Bill>>(
      future: getSalesList(tabName, selectedDate),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Bill>? data = snapshot.data;
          data = filterSalesData(data, tabName, selectedDate);

          // Calculate the total sales for today and this month
          double totalSales = 0;
          if (tabName == "Today" || tabName == "This Month") {
            for (var bill in data) {
              totalSales += double.parse(bill.subTotal);
            }
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
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
                                          '${data![index].customer} | ${data[index].billDate} ${data[index].dateTime} ',
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
                                      mainAxisSize: MainAxisSize.min,
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
                ),
              ),
              // Section to display the total sales
              if (tabName == "Today" || tabName == "This Month")
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Total Sales for $tabName: Rs. ${totalSales.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          );
        } else if (snapshot.hasError) {
          return const Text("-Empty-");
        }
        return const Text("Loading...");
      },
    );
  }

  // A helper method to filter data based on the selected tab and date
  List<Bill> filterSalesData(List<Bill>? data, String tabName, DateTime? selectedDate) {
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
        if (tabName == "Filter" && selectedDate != null) {
          final selectedDateStr = formatter.format(selectedDate);
          return data?.where((bill) => bill.billDate == selectedDateStr).toList() ?? [];
        } else {
          return data ?? [];
        }
    }
  }

  // A helper method to build the Filter tab with a date picker button
  Widget buildFilterTab() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _selectDate(context);
              },
              child: Text("Select Date"),
            ),
          ],
        ),
        Expanded(
          child: buildSalesList("Filter", selectedDate),
        ),
      ],
    );
  }

  // A helper method to open a date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
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