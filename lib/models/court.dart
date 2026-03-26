/// Корт/площадка — отдельная бронируемая единица внутри [Venue].
/// Например: «Поле №1» на арене «СПОРТКОМ».
class Court {
  final String id;
  final String venueId;
  final String name;
  final String sport;
  final double pricePerHour;
  final String surface; // напр. «искусственный газон», «паркет», «бетон»
  final bool isAvailable;
  final List<String> photos;

  Court({
    required this.id,
    required this.venueId,
    required this.name,
    required this.sport,
    required this.pricePerHour,
    required this.surface,
    required this.isAvailable,
    this.photos = const [],
  });

  factory Court.fromJson(Map<String, dynamic> json) => Court(
        id: json['id'] as String,
        venueId: json['venue_id'] as String,
        name: json['name'] as String,
        sport: json['sport'] as String,
        pricePerHour: (json['price_per_hour'] as num).toDouble(),
        surface: json['surface'] as String,
        isAvailable: json['is_available'] as bool? ?? true,
        photos: List<String>.from(json['photos'] as List? ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'venue_id': venueId,
        'name': name,
        'sport': sport,
        'price_per_hour': pricePerHour,
        'surface': surface,
        'is_available': isAvailable,
        'photos': photos,
      };
}
