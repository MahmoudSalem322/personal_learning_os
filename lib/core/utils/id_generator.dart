import 'dart:math';

/// Creates unique ids for new records.
///
/// Ids combine a millisecond timestamp with random bits, so they are unique
/// without coordination and roughly sortable by creation time. Injected into
/// services so tests can use deterministic ids.
class IdGenerator {
  IdGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  String next() {
    final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final buffer = StringBuffer(time);
    for (var i = 0; i < 10; i++) {
      buffer.write(_alphabet[_random.nextInt(_alphabet.length)]);
    }
    return buffer.toString();
  }

  static const String _alphabet = '0123456789abcdefghijklmnopqrstuvwxyz';
}
