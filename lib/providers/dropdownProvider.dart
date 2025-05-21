import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../sellerApp/model/itemModel.dart';

class StockProvider with ChangeNotifier {
  List<BarrelStock> _stockList = [];
  bool _isLoading = false;
  String? _error;

  List<BarrelStock> get stockList => _stockList;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> fetchStockData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(
        Uri.parse(
          'https://api-barrel.sooritechnology.com.np/api/v1/barrel-app/barrel-stock-analysis?offset=0&limit=20&ordering=-id',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${prefs.getString("accessToken")}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parsed = BarrelStockAnalysisResponse.fromJson(data);
        _stockList = parsed.results;
      } else {
        _error = "Failed to fetch data";
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
