import 'package:flutter_test/flutter_test.dart';

bool isValidEmail(String email) {
  final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  return re.hasMatch(email.trim());
}

void main() {
  group('Email validator', () {
    test('accepts valid email', () {
      expect(isValidEmail('test@example.com'), true);
    });

    test('rejects invalid email', () {
      expect(isValidEmail('not-an-email'), false);
    });
  });
}
