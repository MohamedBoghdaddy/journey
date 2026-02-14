import '../../domain/entities/space.dart';

class SpaceModel {
  const SpaceModel({
    required this.id,
    required this.name,
    this.description,
    this.city,
    this.createdAt,
    this.ownerId,
    this.isVerified,
  });

  final String id;
  final String name;
  final String? description;
  final String? city;
  final DateTime? createdAt;
  final String? ownerId;
  final bool? isVerified;

  factory SpaceModel.fromMap(Map<String, dynamic> map) {
    return SpaceModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      description: map['description']?.toString(),
      city: map['city']?.toString() ?? map['governorate']?.toString(),
      ownerId: map['owner_id']?.toString(),
      isVerified: map['is_verified'] == true || map['verified'] == true,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'city': city,
    'owner_id': ownerId,
    'is_verified': isVerified,
  };

  Space toEntity() => Space(
    id: id,
    name: name,
    description: description,
    city: city,
    createdAt: createdAt,
    ownerId: ownerId,
    isVerified: isVerified,
  );
}
