/// Represents a Space (neighbourhood or business) in Masr Spaces.
/// Unified model for frontend + backend maps.
class SpaceModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;

  const SpaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
  });

  factory SpaceModel.fromMap(Map<String, dynamic> data) {
    return SpaceModel(
      id: (data['id'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      ownerId: (data['owner_id'] ?? data['ownerId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'owner_id': ownerId,
      };

  SpaceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
  }) {
    return SpaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
