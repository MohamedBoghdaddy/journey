import 'dart:math';

class Uuid {
  Uuid._();

  static final Random _rand = Random.secure();

  /// Generates a random ID suitable for UI-only keys.
  /// For database IDs, prefer server-generated UUIDs.
  static String v4() {
    const hex = '0123456789abcdef';
    String chunk(int len) =>
        List.generate(len, (_) => hex[_rand.nextInt(16)]).join();

    // Not a strict RFC4122 implementation, but good enough for client temp IDs.
    return '${chunk(8)}-${chunk(4)}-4${chunk(3)}-${chunk(4)}-${chunk(12)}';
  }
}
