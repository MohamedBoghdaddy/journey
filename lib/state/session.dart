
import 'package:flutter/foundation.dart';

class UserSession {
  final int trust; // 0-100
  final bool isVerified;

  const UserSession({
    required this.trust,
    required this.isVerified,
  });

  UserSession copyWith({int? trust, bool? isVerified}) {
    return UserSession(
      trust: trust ?? this.trust,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class SessionStore {
  static final ValueNotifier<UserSession> session =
      ValueNotifier(const UserSession(trust: 72, isVerified: false));

  static UserSession get value => session.value;

  static void setVerified(bool v) {
    session.value = session.value.copyWith(isVerified: v);
  }

  static void setTrust(int v) {
    session.value = session.value.copyWith(trust: v.clamp(0, 100));
  }
}
