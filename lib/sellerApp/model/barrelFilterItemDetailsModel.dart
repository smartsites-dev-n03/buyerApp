class BarrelFilterItemDetailsResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<BarrelFilterItemsResponse> results;

  BarrelFilterItemDetailsResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory BarrelFilterItemDetailsResponse.fromJson(Map<String, dynamic> json) {
    return BarrelFilterItemDetailsResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: List<BarrelFilterItemsResponse>.from(
        json['results'].map((x) => BarrelFilterItemsResponse.fromJson(x)),
      ),
    );
  }
}

class BarrelFilterItemsResponse {
  final int id;
  final String? inboundNo;
  final String? batchNo;
  final List<BarrelFilterStock> itemInboundDetails;
  final BarrelFilterCreatedBy createdBy;

  BarrelFilterItemsResponse({
    required this.id,
    this.inboundNo,
    this.batchNo,
    required this.itemInboundDetails,
    required this.createdBy,
  });

  factory BarrelFilterItemsResponse.fromJson(Map<String, dynamic> json) {
    return BarrelFilterItemsResponse(
      id: json['id'],
      inboundNo: json['inboundNo'],
      batchNo: json['batchNo'],
      itemInboundDetails: List<BarrelFilterStock>.from(
        json['itemInboundDetails'].map((x) => BarrelFilterStock.fromJson(x)),
      ),
      createdBy: BarrelFilterCreatedBy.fromJson(json['createdBy']),
    );
  }
}

class BarrelFilterStock {
  final int id;
  final String? quantity;
  final Items items;

  BarrelFilterStock({
    required this.id,
    required this.quantity,
    required this.items,
  });

  factory BarrelFilterStock.fromJson(Map<String, dynamic> json) {
    return BarrelFilterStock(
      id: json['id'],
      quantity: json['quantity'],
      items: Items.fromJson(json['item']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarrelFilterStock &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Items {
  final int id;
  final String name;

  Items({required this.id, required this.name});

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(id: json['id'], name: json['name']);
  }
}

class BarrelFilterCreatedBy {
  final int id;
  final String? userName;

  BarrelFilterCreatedBy({required this.id, required this.userName});

  factory BarrelFilterCreatedBy.fromJson(Map<String, dynamic> json) {
    return BarrelFilterCreatedBy(id: json['id'], userName: json['userName']);
  }
}
