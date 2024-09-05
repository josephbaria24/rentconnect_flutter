class Property {
  final String id;
  final String userId;
  final String description;
  final String photo;
  final String address;
  final double price;
  final int numberOfRooms;
  final List<String> amenities;
  final DateTime availableFrom;
  final String status;

  Property({
    required this.id,
    required this.userId,
    required this.description,
    required this.photo,
    required this.address,
    required this.price,
    required this.numberOfRooms,
    required this.amenities,
    required this.availableFrom,
    required this.status,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      description: json['description'] as String,
      photo: json['photo'] as String,
      address: json['address'] as String,
      price: (json['price'] as num).toDouble(),
      numberOfRooms: json['numberOfRooms'] as int,
      amenities: List<String>.from(json['amenities'] as List),
      availableFrom: DateTime.parse(json['availableFrom'] as String),
      status: json['status'] as String,
    );
  }
}
