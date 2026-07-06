import 'package:cinema_app/config/helpers/human_formats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HumanFormats.number', () {
    test('leaves small numbers without a compact suffix', () {
      expect(HumanFormats.number(950), '950');
    });

    test('uses a K suffix for thousands', () {
      expect(HumanFormats.number(1234), '1.23K');
    });

    test('uses an M suffix for millions', () {
      expect(HumanFormats.number(1500000), '1.5M');
    });

    test('rounds to the requested number of decimals', () {
      expect(HumanFormats.number(7.5), '8');
      expect(HumanFormats.number(7.5, 1), '7.5');
    });
  });
}
