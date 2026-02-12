class Group {
  final String id;
  final String name;
  final String description;
  final String ownerId;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
  });

  factory Group.fromMap(Map<String, dynamic> data) {
    return Group(
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