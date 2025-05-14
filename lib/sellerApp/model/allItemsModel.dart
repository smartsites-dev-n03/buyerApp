class BarrelStockAnalysisItemsResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<BarrelStock> results;

  BarrelStockAnalysisItemsResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory BarrelStockAnalysisItemsResponse.fromJson(Map<String, dynamic> json) {
    return BarrelStockAnalysisItemsResponse(
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
  final String name;
  final String code;
  final Descriptions description;

  BarrelStock({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
  });

  factory BarrelStock.fromJson(Map<String, dynamic> json) {
    return BarrelStock(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: Descriptions.fromJson(json['description']),
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

class Descriptions {
  final int id;
  final String name;

  Descriptions({required this.id, required this.name});

  factory Descriptions.fromJson(Map<String, dynamic> json) {
    return Descriptions(id: json['id'], name: json['name']);
  }
}
