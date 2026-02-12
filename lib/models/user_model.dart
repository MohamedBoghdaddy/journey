/// Represents a user of the Masr Spaces platform.
class UserModel {
  final String id;
  final String email;
  final String name;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.isAdmin = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as String,
      email: data['email'] as String,
      name: data['name'] as String? ?? '',
      isAdmin: data['is_admin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'name': name,
        'is_admin': isAdmin,
      };
}