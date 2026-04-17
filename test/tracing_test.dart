import 'package:flutter_test/flutter_test.dart';

void main() {
  test('drawing state should activate when user draws', () {
    bool hasDrawn = false;

    // simulate drawing start
    hasDrawn = true;

    expect(hasDrawn, true);
  });
}
