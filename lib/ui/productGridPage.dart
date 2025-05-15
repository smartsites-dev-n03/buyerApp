import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:buyerApp/sellerApp/ui/createProduct.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:buyerApp/sellerApp/model/allItemsModel.dart';

import '../sellerApp/model/barrelFilterItemsModel.dart';
import '../sellerApp/model/barrelDropdownItemsModel.dart';

class ProductGridPage extends StatefulWidget {
  const ProductGridPage({super.key});

  @override
  State<ProductGridPage> createState() => _ProductGridPageState();
}

class _ProductGridPageState extends State<ProductGridPage> {
  List<Map<String, dynamic>> products = [];

  BarrelStock? selectedStock;
  BarrelDropdownStock? selectedDropdownStock;
  BarrelFilterStock? selectedFilterStock;

  //List<BarrelFilterStock> tableData = [];

  @override
  void initState() {
    super.initState();
    fetchBarrelFilterItems();
  }

  Future<List<BarrelFilterStock>> fetchBarrelFilterItems() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String url =
        'https://api-barrel.sooritechnology.com.np/api/v1/barrel-app/barrel-inbound-code';
    /*if (code != null && code.isNotEmpty) {
      url += '?code=$code';
    }*/

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
          "API Products - Grid Layout",
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

      body: FutureBuilder<List<BarrelFilterStock>>(
        future: fetchBarrelFilterItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text("No data found");
          }

          final filterStockList = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: filterStockList.length,
            itemBuilder: (context, index) {
              final data = filterStockList[index];

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Image.asset('assets/emptyBarrel.png'),
                          ClipRect(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              heightFactor: data.currentPercentageVolume / 10,
                              child: Image.asset('assets/filledBarrel.png'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        "Location: " + data.location.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data.barrelDetail.capacity,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      Row(
                        children: [
                          Container(
                            child: Text(
                              data.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
