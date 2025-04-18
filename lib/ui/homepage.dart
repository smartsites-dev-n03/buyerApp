import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:buyerApp/models/categories.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/productModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedCategory = "";
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  bool _isLoadingCategories = true;
  bool _isLoadingProducts = true;
  List<String> _imageUrls = [];


  @override
  void initState() {
    super.initState();
    fetchCarouselImages();
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchCarouselImages() async {
    try {
      final url = Uri.parse("https://api.sarbamfoods.com/api/v1/utilities/carousel/");
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty && responseData.first is Map<String, dynamic>) {
          Map<String, dynamic> images = responseData.first;
          setState(() {
            _imageUrls = images.values.map((url) => url.toString()).toList();
          });
        }
      } else {
        throw Exception("Failed to fetch images: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching images: $e");
    }
  }


  Future<void> fetchCategories() async {
    try {
      final url = Uri.parse("https://api.sarbamfoods.com/api/v1/categories/");
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Response body :"+response.body.toString());
        log(response.body.toString());
        final List<dynamic> data = jsonDecode(response.body);
        final List<CategoryModel> categoryList = data
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();

        setState(() {
          _categories = categoryList;
          _isLoadingCategories = false;
        });
      } else {
        throw Exception("Failed to fetch categories: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      throw Exception("Error fetching categories: $e");
    }
  }




  Future<void> fetchProducts() async {
    try {
      final url = Uri.parse("https://api.sarbamfoods.com/api/v1/products/");
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<ProductModel> productList = data
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();

        setState(() {
          _products = productList;
          _isLoadingProducts = false;
        });
      } else {
        throw Exception("Failed to fetch products: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
      throw Exception("Error fetching products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          /// Carousel Slider
          CarouselSlider.builder(
            itemCount: _imageUrls.length,
            itemBuilder: (context, index, realIndex) {
              log("Image URL: ${_imageUrls[index]}");
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: _imageUrls[index],
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) {
                      log("Error loading image: $error");
                      return Center(
                        child: Text(
                          "Failed to load image",
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 150,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              enlargeCenterPage: false,
              viewportFraction: 1.0,
              aspectRatio: 16 / 9,
              initialPage: 0,
            ),
          ),

          /// Categories List
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: _isLoadingCategories
                  ? Center(child: CircularProgressIndicator())
                  : _categories.isEmpty
                  ? Center(child: Text('No categories available'))
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedCategory == _categories[index].categoryName;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = _categories[index].categoryName;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.grey.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _categories[index].categoryName ?? "Unknown",
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ourFont',
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: _isLoadingProducts
                ? Center(child: CircularProgressIndicator())
                : _products.isEmpty
                ? Center(child: Text("No products available"))
                : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      /// Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: product.photo,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),

                      /// Product Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Price: Rs. ${product.price}",
                                style: TextStyle(fontSize: 16, color: Colors.green),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Weight: ${product.weight} Kg",
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// Add to Cart Button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {

                          },
                          child: Text("Add"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),


        ],
      ),
    );
  }
}