/// Represents a space (neighbourhood or business) within Masr Spaces.
class SpaceModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;

  SpaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
  });

  factory SpaceModel.fromMap(Map<String, dynamic> data) {
    return SpaceModel(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      ownerId: data['owner_id'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'owner_id': ownerId,
      };
}