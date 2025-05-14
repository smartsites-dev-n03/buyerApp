class BarrelDropdownItemsResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<BarrelDropdownStock> results;

  BarrelDropdownItemsResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory BarrelDropdownItemsResponse.fromJson(Map<String, dynamic> json) {
    return BarrelDropdownItemsResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: List<BarrelDropdownStock>.from(
        json['results'].map((x) => BarrelDropdownStock.fromJson(x)),
      ),
    );
  }
}

class BarrelDropdownStock {
  final int id;
  final String code;
  final String currentVolume;
  final Descriptions barrelDetail;

  BarrelDropdownStock({
    required this.id,
    required this.currentVolume,
    required this.code,
    required this.barrelDetail,
  });

  factory BarrelDropdownStock.fromJson(Map<String, dynamic> json) {
    return BarrelDropdownStock(
      id: json['id'],
      currentVolume: json['currentVolume'],
      code: json['code'],
      barrelDetail: Descriptions.fromJson(json['barrelDetail']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarrelDropdownStock &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Descriptions {
  final int id;
  final String capacity;

  Descriptions({required this.id, required this.capacity});

  factory Descriptions.fromJson(Map<String, dynamic> json) {
    return Descriptions(id: json['id'], capacity: json['capacity']);
  }
}
