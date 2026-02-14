/// Represents a user group in Masr Spaces.
/// Unified model (frontend + backend compatible) with small safety enhancements.
class GroupModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;

  const GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
  });

  /// Create from Supabase row / backend response.
  ///
  /// Supports alternative keys:
  /// - owner_id OR ownerId
  factory GroupModel.fromMap(Map<String, dynamic> data) {
    return GroupModel(
      id: (data['id'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      ownerId: (data['owner_id'] ?? data['ownerId'] ?? '').toString(),
    );
  }

  /// Convert to map for storage/network.
  ///
  /// By default uses snake_case keys to match typical DB columns.
  Map<String, dynamic> toMap({bool snakeCase = true}) {
    if (snakeCase) {
      return {
        'id': id,
        'name': name,
        'description': description,
        'owner_id': ownerId,
      };
    }
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
    };
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
