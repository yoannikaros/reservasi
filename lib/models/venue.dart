class Venue {
  final int? id;
  final String name;
  final String? description;
  final String? location;
  final int? capacity;
  final double pricePerHour;
  final String? createdAt;

  Venue({
    this.id,
    required this.name,
    this.description,
    this.location,
    this.capacity,
    required this.pricePerHour,
    this.createdAt,
  });

  factory Venue.fromMap(Map<String, dynamic> map) {
    return Venue(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      location: map['location'],
      capacity: map['capacity'],
      pricePerHour: map['price_per_hour'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'capacity': capacity,
      'price_per_hour': pricePerHour,
      'created_at': createdAt,
    };
  }

  Venue copyWith({
    int? id,
    String? name,
    String? description,
    String? location,
    int? capacity,
    double? pricePerHour,
    String? createdAt,
  }) {
    return Venue(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
