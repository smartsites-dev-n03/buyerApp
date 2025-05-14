class BarrelStockAnalysisResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<BarrelStock> results;

  BarrelStockAnalysisResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory BarrelStockAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return BarrelStockAnalysisResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: List<BarrelStock>.from(
        json['results'].map((x) => BarrelStock.fromJson(x)),
      ),
    );
  }
}

class BarrelStock {
  final int id;
  final Item item;
  final String batchNo;
  final String quantity;

  BarrelStock({
    required this.id,
    required this.item,
    required this.batchNo,
    required this.quantity,
  });

  factory BarrelStock.fromJson(Map<String, dynamic> json) {
    return BarrelStock(
      id: json['id'],
      item: Item.fromJson(json['item']),
      batchNo: json['batchNo'],
      quantity: json['quantity'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarrelStock &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Item {
  final int id;
  final String name;

  Item({required this.id, required this.name});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(id: json['id'], name: json['name']);
  }
}
