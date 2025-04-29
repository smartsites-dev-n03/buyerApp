import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../ui/splash.dart';
import 'addProductPage.dart';
import 'editProductPage.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<SellerHomePage> {
  List<Map<String, dynamic>> products = [];
  List<String> videoIds = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
    fetchYtbVideos();
  }

  Future<void> fetchYtbVideos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('youtube_videos').get();
    List<String> ids = [];
    for (var doc in snapshot.docs) {
      final List<dynamic> videoList = doc['videoId'];
      ids.addAll(videoList.map((e) => e.toString()));
    }

    setState(() {
      videoIds = ids;
      log(videoIds.toString());

      if (videoIds.isNotEmpty) {}
    });
  }

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productStrings = prefs.getStringList("user_products") ?? [];

    setState(() {
      products =
          productStrings
              .map((e) => jsonDecode(e) as Map<String, dynamic>)
              .toList();
    });
  }

  Future<void> approveProduct(int index) async {
    setState(() {
      products[index]['isApproved'] = true;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      "user_products",
      products.map((e) => jsonEncode(e)).toList(),
    );
  }

  Future<void> cancelApproveProduct(int index) async {
    setState(() {
      products[index]['isApproved'] = false;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      "user_products",
      products.map((e) => jsonEncode(e)).toList(),
    );
  }

  final _controller = YoutubePlayerController.fromVideoId(
    videoId: 'sivn5BX3Lic',
    autoPlay: false,
    params: const YoutubePlayerParams(showFullscreenButton: true),
  );

  @override
  Widget build(BuildContext context) {
    // You can filter approved products like this:
    final approvedProducts =
        products.where((p) => p['isApproved'] == true).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lukut Store Seller",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductPage()),
              );
              loadProducts();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Column(
                children: [
                  Text(
                    "Lukut Store",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Image(
                    image: AssetImage("assets/drawer-image.png"),
                    width: MediaQuery.of(context).size.width / 2,
                    height: 110,
                  ),
                ],
              ),
              Divider(endIndent: 20, indent: 20),
              ListTile(
                title: const Text('Home'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SellerHomePage()),
                  );
                },
              ),
              ListTile(
                title: const Text('Categories'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: const Text('All Products'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: const Text('Close'),
                leading: Icon(Icons.close),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Logout'),
                leading: Icon(Icons.logout),
                onTap: () async {
                  SharedPreferences logoutPref =
                      await SharedPreferences.getInstance();
                  logoutPref.clear();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SplashPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          products.isEmpty
              ? const Center(child: Text("No products added yet."))
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final isApproved = product['isApproved'] == true;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: isApproved ? Colors.white : Colors.yellow[100],
                    child: ListTile(
                      leading:
                          product['image'] != null
                              ? Image.file(
                                File(product['image']),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                              : const Icon(Icons.image),
                      title: Text(product['name']),
                      subtitle: Text("Rs. ${product['price']}"),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isApproved)
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              tooltip: "Approve",
                              onPressed: () => approveProduct(index),
                            ),
                          if (isApproved)
                            IconButton(
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.green,
                              ),
                              tooltip: "Approve",
                              onPressed: () => cancelApproveProduct(index),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              products.removeAt(index);
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setStringList(
                                "user_products",
                                products.map((e) => jsonEncode(e)).toList(),
                              );
                              loadProducts();
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final updatedProduct = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EditProductPage(
                                        product: products[index],
                                        index: index,
                                      ),
                                ),
                              );

                              if (updatedProduct != null) {
                                setState(() {
                                  products[index] = updatedProduct;
                                });
                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setStringList(
                                  "user_products",
                                  products.map((e) => jsonEncode(e)).toList(),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

          YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
          SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: videoIds.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _controller.loadVideoById(videoId: videoIds[index]);
                  },
                  child: Container(
                    child: Image.network(
                      "https://img.youtube.com/vi/${videoIds[index]}/hqdefault.jpg",
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 5),
          Text("Product using String"),
        ],
      ),
    );
  }
}
