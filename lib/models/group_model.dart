/// Represents a user group.
class GroupModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
  });

  factory GroupModel.fromMap(Map<String, dynamic> data) {
    return GroupModel(
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