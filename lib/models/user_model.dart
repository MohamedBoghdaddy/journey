/// Represents a user in Masr Spaces (frontend + backend compatible).
///
/// - Supports role variants: superadmin, super_admin, super-admin, superAdmin
/// - Supports reputation coming as:
///   - `community_reputation` (preferred for community features)
///   - `reputation` (fallback / legacy)
/// - Keeps both numeric forms:
///   - `communityReputation` as double (fine-grained score)
///   - `reputation` as int (legacy / badges / simple counters)
enum UserRole {
  user,
  moderator,
  admin,
  superAdmin;

  static UserRole fromString(String? value) {
    final v = (value ?? '').trim().toLowerCase();
    switch (v) {
      case 'moderator':
        return UserRole.moderator;
      case 'admin':
        return UserRole.admin;
      case 'superadmin':
      case 'super_admin':
      case 'super-admin':
      case 'superadmin()': // defensive (rare bad payloads)
        return UserRole.superAdmin;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}

class UserModel {
  final String id;

  /// Nullable to avoid forcing empty strings when backend omits it.
  final String? email;

  /// Nullable because some flows may not have a profile name yet.
  final String? name;

  /// The role assigned to this user. See [UserRole].
  final UserRole role;

  /// Fine-grained community reputation (0.0 by default).
  final double communityReputation;

  /// Legacy/simple reputation (0 by default).
  final int reputation;

  const UserModel({
    required this.id,
    this.email,
    this.name,
    this.role = UserRole.user,
    this.communityReputation = 0,
    this.reputation = 0,
  });

  /// Convenience for UI/permission logic.
  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;

  /// True if the user can moderate content (moderator/admin/superAdmin).
  bool get canModerate =>
      role == UserRole.moderator ||
      role == UserRole.admin ||
      role == UserRole.superAdmin;

  /// Role as a string (useful for backend payloads/logs).
  String get roleString => role.name;

  /// Creates a [UserModel] from a map (Supabase row / backend response).
  ///
  /// Accepts role values like:
  /// - user, moderator, admin
  /// - superadmin, super_admin, superAdmin, super-admin
  ///
  /// Accepts reputation values like:
  /// - community_reputation (double/int/string)
  /// - reputation (int/double/string) as fallback
  factory UserModel.fromMap(Map<String, dynamic> data) {
    final role = UserRole.fromString(data['role']?.toString());

    final communityRep = _asDouble(
      data['community_reputation'] ?? data['reputation'],
    );

    final repInt = _asInt(data['reputation']) ?? communityRep.toInt();

    return UserModel(
      id: (data['id'] ?? '').toString(),
      email: data['email']?.toString(),
      name: data['name']?.toString(),
      role: role,
      communityReputation: communityRep,
      reputation: repInt,
    );
  }

  /// Converts this user into a serializable map.
  ///
  /// Stores role as a string (enum name, e.g. "superAdmin").
  Map<String, dynamic> toMap() => {
        'id': id,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
        'role': role.name,
        'community_reputation': communityReputation,
        'reputation': reputation,
      };

  /// Optional helper if you want a plain backend-style map.
  Map<String, dynamic> toBackendMap() => toMap();

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    double? communityReputation,
    int? reputation,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      communityReputation: communityReputation ?? this.communityReputation,
      reputation: reputation ?? this.reputation,
    );
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}
