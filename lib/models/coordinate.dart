class Coordinate {
  final int? lon;
  final int? lat;

  const Coordinate({
    required this.lon,
    required this.lat,
  });

  factory Coordinate.fromJson(Map<String, dynamic>? json) {
    return Coordinate(
      lon: json?['lon'],
      lat: json?['lat'],
    );
  }
}
