import 'dart:convert';
import 'dart:math';

/// Generates short, collision-resistant ids for locally-created entities.
class IdGenerator {
  const IdGenerator._();

  static String generate() {
    final rng = Random.secure();
    final bytes = List<int>.generate(12, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }
}
