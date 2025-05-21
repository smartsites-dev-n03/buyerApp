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

import '../sellerApp/model/barrelFilterItemDetailsModel.dart';
import 'itemInboundDetailsPage.dart';

class productListDetailPage extends StatefulWidget {
  const productListDetailPage({super.key});

  @override
  State<productListDetailPage> createState() => _productListDetailPageState();
}

class _productListDetailPageState extends State<productListDetailPage> {
  TextEditingController searchTxtController = TextEditingController();

  List<Map<String, dynamic>> products = [];

  BarrelStock? selectedStock;
  BarrelFilterStock? selectedFilterStock;
  List<BarrelFilterItemsResponse> tableData = [];

  @override
  void initState() {
    super.initState();
    //fetchStockItems();
    //fetchBarrelDropdownItems();
    fetchAndSetTableData();
  }

  fetchAndSetTableData({String? code, String? search}) async {
    try {
      final data = await fetchBarrelFilterItems(code: code, search: search);
      setState(() {
        tableData = data;
      });
      return tableData;
    } catch (e) {
      print("Error fetching filtered data: $e");
    }
  }

  /*Future<List<BarrelStock>> fetchStockItems() async {
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
  }*/

  Future<List<BarrelFilterItemsResponse>> fetchBarrelFilterItems({
    String? code,
    String? search,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String url =
        'https://api-barrel.sooritechnology.com.np/api/v1/barrel-app/barrel-item-inbound';
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
      final parsed = BarrelFilterItemDetailsResponse.fromJson(jsonData);
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
                ElevatedButton.icon(
                  onPressed: () {
                    fetchAndSetTableData(search: searchTxtController.text);
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Search"),
                ),
              ],
            ),
            SizedBox(height: 20),

            FutureBuilder(
              // Future that needs to be resolved
              // inorder to display something on the Canvas
              future: fetchBarrelFilterItems(),
              builder: (ctx, snapshot) {
                // Checking if future is resolved or not
                if (snapshot.connectionState == ConnectionState.done) {
                  // If we got an error
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '${snapshot.error} occurred',
                        style: TextStyle(fontSize: 18),
                      ),
                    );

                    // if we got our data
                  } else if (snapshot.hasData) {
                    // Extracting data from snapshot object
                    final data = snapshot.data!;
                    return Center(
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(
                                Colors.grey[300],
                              ),
                              showBottomBorder: true,
                              showCheckboxColumn: true,
                              sortColumnIndex: 1,
                              sortAscending: true,
                              columnSpacing: 40,
                              columns: [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Batch')),
                                DataColumn(label: Text('Inbound')),
                                DataColumn(label: Text('By')),
                                DataColumn(label: Text('Action')),
                              ],
                              rows:
                                  data.map((item) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(item.id.toString())),
                                        DataCell(Text(item.batchNo.toString())),
                                        DataCell(
                                          Text(item.inboundNo.toString()),
                                        ),
                                        DataCell(
                                          Text(
                                            item.createdBy.userName.toString(),
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            icon: Icon(Icons.remove_red_eye),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (
                                                  BuildContext context,
                                                ) {
                                                  final details =
                                                      item.itemInboundDetails ??
                                                      [];
                                                  return AlertDialog(
                                                    title: Text(
                                                      "Inbound Details:",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: Expanded(
                                                      child: Column(
                                                        children: [
                                                          Table(
                                                            border:
                                                                TableBorder.all(),
                                                            defaultColumnWidth:
                                                                FlexColumnWidth(
                                                                  2,
                                                                ),
                                                            children: [
                                                              TableRow(
                                                                children: [
                                                                  Text('ID'),
                                                                  Text('Batch'),
                                                                  Text(
                                                                    'Inbound',
                                                                  ),
                                                                  Text('By'),
                                                                ],
                                                              ),
                                                              TableRow(
                                                                children: [
                                                                  Text(
                                                                    item.id
                                                                        .toString(),
                                                                  ),
                                                                  Text(
                                                                    item.batchNo
                                                                        .toString(),
                                                                  ),
                                                                  Text(
                                                                    item.inboundNo
                                                                        .toString(),
                                                                  ),

                                                                  Text(
                                                                    item
                                                                        .createdBy
                                                                        .userName
                                                                        .toString(),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Divider(),
                                                          DataTable(
                                                            columns: [
                                                              DataColumn(
                                                                label: Text(
                                                                  "ID",
                                                                ),
                                                              ),
                                                              DataColumn(
                                                                label: Text(
                                                                  "Name",
                                                                ),
                                                              ),
                                                              DataColumn(
                                                                label: Text(
                                                                  "Quantity",
                                                                ),
                                                              ),
                                                            ],
                                                            rows:
                                                                details.map((
                                                                  detail,
                                                                ) {
                                                                  return DataRow(
                                                                    cells: [
                                                                      DataCell(
                                                                        Text(
                                                                          detail
                                                                              .id
                                                                              .toString(),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Text(
                                                                          detail
                                                                              .items
                                                                              .name
                                                                              .toString(),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Text(
                                                                          detail
                                                                              .quantity
                                                                              .toString(),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                }).toList(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
                // Displaying LoadingSpinner to indicate waiting state
                return Center(child: CircularProgressIndicator());
              },
            ),
            /*DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Batch')),
                DataColumn(label: Text('Inbound')),
                DataColumn(label: Text('Actions')),
              ],
              rows:
                  tableData.map((stock) {
                    return DataRow(
                      cells: [
                        DataCell(Text(stock.id.toString())),
                        DataCell(Text(stock.batchNo ?? '')),
                        DataCell(Text(stock.inboundNo ?? '')),
                        DataCell(
                          GestureDetector(
                            child: Icon(Icons.remove_red_eye),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => itemInboundDetailsPage(
                                        item: stock.inboundNo,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),*/
          ],
        ),
      ),
    );
  }
}
