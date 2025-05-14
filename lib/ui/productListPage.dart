import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:buyerApp/sellerApp/ui/createProduct.dart';
import 'package:buyerApp/ui/galleryPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ui/productDetailPage.dart';
import '../../ui/profilePage.dart';
import '../../ui/splash.dart';
import 'package:http/http.dart' as http;
import 'package:buyerApp/sellerApp/model/allItemsModel.dart';

import '../sellerApp/model/barrelFilterItemsModel.dart';
import '../sellerApp/model/barrelDropdownItemsModel.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Map<String, dynamic>> products = [];
  List<BarrelFilterStock> tableData = [];

  BarrelStock? selectedStock;
  BarrelDropdownStock? selectedDropdownStock;
  BarrelFilterStock? selectedFilterStock;

  @override
  void initState() {
    super.initState();

    fetchStockItems();
    //fetchBarrelDropdownItems();

    fetchAndSetTableData();
  }

  void fetchAndSetTableData({String? code}) async {
    try {
      final data = await fetchBarrelFilterItems(code: code);
      setState(() {
        tableData = data;
      });
    } catch (e) {
      print("Error fetching filtered data: $e");
    }
  }

  Future<List<BarrelStock>> fetchStockItems() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final response = await http.get(
      Uri.parse(
        'https://api-barrel.sooritechnology.com.np/api/v1/barrel-app/barrel-item',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${preferences.getString("accessToken")}',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final parsed = BarrelStockAnalysisItemsResponse.fromJson(jsonData);
      return parsed.results;
    } else {
      throw Exception("Failed to fetch data");
    }
  }

  Future<List<BarrelDropdownStock>> fetchBarrelDropdownItems() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final response = await http.get(
      Uri.parse(
        'https://api-barrel.sooritechnology.com.np/api/v1/barrel-app/barrel-inbound-code',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${preferences.getString("accessToken")}',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final parsed = BarrelDropdownItemsResponse.fromJson(jsonData);
      return parsed.results;
    } else {
      throw Exception("Failed to fetch data");
    }
  }

  Future<List<BarrelFilterStock>> fetchBarrelFilterItems({String? code}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    // Build the URL with optional query parameter
    String url =
        'https://api-barrel.sooritechnology.com.np/api/v1/barrel-app/barrel-inbound-code';
    if (code != null && code.isNotEmpty) {
      url += '?code=$code';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${preferences.getString("accessToken")}',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final parsed = BarrelFilterItemsResponse.fromJson(jsonData);
      return parsed.results;
    } else {
      throw Exception("Failed to fetch data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "API Products",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Createproduct()),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<List<BarrelStock>>(
                future: fetchStockItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("No data found");
                  }

                  final stockList = snapshot.data!;

                  return DropdownButtonFormField<BarrelStock>(
                    value: selectedStock,
                    hint: Text("Select Item"),
                    items:
                        stockList.map((stock) {
                          return DropdownMenuItem(
                            value: stock,
                            child: Text(stock.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStock = value;
                      });
                      /*print(
                        "Selected: ${value!.item.name}, Batch: ${value.batchNo}, Qty: ${value.quantity}",
                      );*/

                      log("Selected: " + selectedStock.toString());
                    },
                  );
                },
              ),
            ),

            /*Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<List<BarrelStock>>(
                future: fetchStockItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("No data found");
                  }

                  final stockList = snapshot.data!;
                  return DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Code')),
                      DataColumn(label: Text('Description')),
                    ],
                    rows:
                        stockList.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(Text(item.id.toString())),
                              DataCell(Text(item.name)),
                              DataCell(Text(item.code)),
                              DataCell(Text(item.description.name)),
                            ],
                          );
                        }).toList(),
                  );
                },
              ),
            ),*/
            Divider(),
            Text(
              "Filter your data:",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<List<BarrelDropdownStock>>(
                future: fetchBarrelDropdownItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("No data found");
                  }

                  final filterStockList = snapshot.data!;

                  return DropdownButtonFormField<BarrelDropdownStock>(
                    value: selectedDropdownStock,
                    //value: null,
                    hint: Text("Select Code to Filter"),
                    items:
                        filterStockList.map((stock) {
                          return DropdownMenuItem(
                            value: stock,
                            child: Text(stock.code),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDropdownStock = value;
                      });

                      final selectedCode = value?.code;

                      log(selectedCode.toString());
                      /*if (selectedCode != null && selectedCode.isNotEmpty) {
                        fetchBarrelFilterItems({code: selectedCode});
                      }*/

                      if (selectedCode != null && selectedCode.isNotEmpty) {
                        fetchAndSetTableData(
                          code: selectedCode,
                        ); // Pass to your data-fetching function
                      }
                    },
                  );
                },
              ),
            ),
            DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Code')),
                DataColumn(label: Text('B. Capacity')),
                DataColumn(label: Text('Location')),
              ],
              rows:
                  tableData.map((stock) {
                    return DataRow(
                      cells: [
                        DataCell(Text(stock.id.toString())),
                        DataCell(Text(stock.code ?? '')),
                        DataCell(Text(stock.barrelDetail.capacity)),
                        DataCell(Text(stock.location.name)),
                      ],
                    );
                  }).toList(),
            ),
            /*Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<List<BarrelFilterStock>>(
                future: fetchBarrelFilterItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("No data found");
                  }

                  final stockList = snapshot.data!;
                  return DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Code')),
                      DataColumn(label: Text('B. Capacity')),
                      DataColumn(label: Text('Location')),
                    ],
                    rows:
                        stockList.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(Text(item.id.toString())),
                              DataCell(Text(item.code)),
                              DataCell(Text(item.barrelDetail.capacity)),
                              DataCell(Text(item.location.name)),
                            ],
                          );
                        }).toList(),
                  );
                },
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
