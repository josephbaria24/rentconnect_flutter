class Property {
  final String id;
  final String userId;
  final String description;
  final String photo;
  final String? photo2;
  final String? photo3;
  final String address;
  final List<String> amenities;
  final DateTime availableFrom;
  final String status;
  final Map<String, dynamic>? location; // Add location field
  final String? typeOfProperty; // Add typeOfProperty field

  Property({
    required this.id,
    required this.userId,
    required this.description,
    required this.photo,
    this.photo2,
    this.photo3,
    required this.address,
    required this.amenities,
    required this.availableFrom,
    required this.status,
    this.location, 
    this.typeOfProperty, 
  
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      description: json['description'] as String,
      photo: json['photo'] as String,
      photo2: json['photo2'] as String?,
      photo3: json['photo3'] as String?,
      address: json['address'] as String,
      amenities: List<String>.from(json['amenities'] as List),
      availableFrom: DateTime.parse(json['availableFrom'] as String),
      status: json['status'] as String,
      location: json['location'] as Map<String, dynamic>?, // Parse location field
      typeOfProperty: json['typeOfProperty'] as String?, // Parse typeOfProperty field
    );
  }
}
