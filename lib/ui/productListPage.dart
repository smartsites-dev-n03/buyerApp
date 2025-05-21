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
  TextEditingController searchTxtController = TextEditingController();

  List<Map<String, dynamic>> products = [];

  BarrelStock? selectedStock;
  BarrelDropdownStock? selectedDropdownStock;
  BarrelFilterStock? selectedFilterStock;
  List<BarrelFilterStock> tableData = [];

  @override
  void initState() {
    super.initState();
    fetchStockItems();
    //fetchBarrelDropdownItems();
    fetchAndSetTableData();
  }

  void fetchAndSetTableData({String? code, String? search}) async {
    try {
      final data = await fetchBarrelFilterItems(code: code, search: search);
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

  Future<List<BarrelFilterStock>> fetchBarrelFilterItems({
    String? code,
    String? search,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String url =
        'https://api-barrel.sooritechnology.com.np/api/v1/barrel-app/barrel-inbound-code';
    if (code != null && code.isNotEmpty) {
      url += '?code=$code';
    }

    if (search != null && search.isNotEmpty) {
      url += '?search=$search';
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
            Divider(),
            Text(
              "Filter your data:",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: searchTxtController,
                    decoration: const InputDecoration(
                      labelText: "Search Product",
                    ),
                    onChanged: (value) {
                      fetchAndSetTableData(search: value);
                    },
                  ),
                ),
                /*IconButton(
                  onPressed: () {
                    fetchAndSetTableData(search: searchTxtController.text);
                  },
                  icon: Icon(Icons.search),
                  iconSize: 30,
                ),*/
                ElevatedButton.icon(
                  onPressed: () {
                    fetchAndSetTableData(search: searchTxtController.text);
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Search"),
                ),
              ],
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
                    hint: Text("Select Code to Filter"),
                    dropdownColor: Colors.grey,
                    decoration: InputDecoration(fillColor: Colors.blueGrey),

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
