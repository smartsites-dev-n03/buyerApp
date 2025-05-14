class BarrelFilterItemsResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<BarrelFilterStock> results;

  BarrelFilterItemsResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory BarrelFilterItemsResponse.fromJson(Map<String, dynamic> json) {
    return BarrelFilterItemsResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: List<BarrelFilterStock>.from(
        json['results'].map((x) => BarrelFilterStock.fromJson(x)),
      ),
    );
  }
}

class BarrelFilterStock {
  final int id;
  final String code;
  final String currentVolume;
  final Descriptions barrelDetail;
  final Location location;

  BarrelFilterStock({
    required this.id,
    required this.currentVolume,
    required this.code,
    required this.barrelDetail,
    required this.location,
  });

  factory BarrelFilterStock.fromJson(Map<String, dynamic> json) {
    return BarrelFilterStock(
      id: json['id'],
      currentVolume: json['currentVolume'],
      code: json['code'],
      barrelDetail: Descriptions.fromJson(json['barrelDetail']),
      location: Location.fromJson(json['location']),
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

class Descriptions {
  final int id;
  final String capacity;

  Descriptions({required this.id, required this.capacity});

  factory Descriptions.fromJson(Map<String, dynamic> json) {
    return Descriptions(id: json['id'], capacity: json['capacity']);
  }
}

class Location {
  final int id;
  final String name;

  Location({required this.id, required this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(id: json['id'], name: json['name']);
  }
}
