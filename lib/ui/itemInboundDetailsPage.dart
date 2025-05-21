import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
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

class itemInboundDetailsPage extends StatefulWidget {
  String? item;

  itemInboundDetailsPage({super.key, required this.item});

  @override
  State<itemInboundDetailsPage> createState() => _itemInboundDetailsPageState();
}

class _itemInboundDetailsPageState extends State<itemInboundDetailsPage> {
  TextEditingController searchTxtController = TextEditingController();

  String? inboundId;

  List<Map<String, dynamic>> products = [];

  List<BarrelFilterItemsResponse> tableData = [];

  @override
  void initState() {
    super.initState();
    inboundId = widget.item;
    fetchAndSetTableData();
  }

  fetchAndSetTableData({String? code, String? search}) async {
    try {
      final data = await fetchBarrelFilterItems(code: code, search: search);
      setState(() {
        tableData = data;
        log(tableData.toString());
      });
    } catch (e) {
      print("Error fetching filtered data: $e");
    }
  }

  Future<List<BarrelFilterItemsResponse>> fetchBarrelFilterItems({
    String? code,
    String? search,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String url =
        'https://api-barrel.sooritechnology.com.np/api/v1/barrel-app/barrel-item-inbound?inbound_no=$inboundId';
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
              "Details: $inboundId",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
              columns: const [
                DataColumn(label: Text('ID')),
                //DataColumn(label: Text('Batch')),
                DataColumn(label: Text('Inbound')),
                DataColumn(label: Text('Inbound-')),
              ],
              rows:
                  tableData.map((stock) {
                    return DataRow(
                      cells: [
                        DataCell(Text(stock.id.toString())),
                        //DataCell(Text(stock.batchNo ?? '')),
                        DataCell(Text(stock.inboundNo ?? '')),
                        DataCell(
                          Text(stock.itemInboundDetails[0].id.toString()),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
