import 'dart:math';

class RandomGen {
  static const String _chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  String generateRandomString(int n) {
    Random secureRandom = Random.secure();
    String result = '';
    for (int i = 0; i < n; i++) {
      result += _chars[secureRandom.nextInt(_chars.length)];
    }
    return result;
  }
}