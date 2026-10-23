import 'package:convertidor_unidades/units.dart';
import 'package:flutter_test/flutter_test.dart';

Category cat(String n) => categories.firstWhere((c) => c.name == n);
Unit unit(Category c, String s) => c.units.firstWhere((u) => u.symbol == s);

void main() {
  test('longitud', () {
    final c = cat('Longitud');
    expect(convert(c, unit(c, 'km'), unit(c, 'm'), 2), 2000);
    expect(convert(c, unit(c, 'mi'), unit(c, 'km'), 1), closeTo(1.609344, 1e-9));
    expect(convert(c, unit(c, 'in'), unit(c, 'cm'), 10), closeTo(25.4, 1e-9));
  });

  test('masa', () {
    final c = cat('Masa');
    expect(convert(c, unit(c, 'lb'), unit(c, 'kg'), 1), closeTo(0.45359237, 1e-9));
    expect(convert(c, unit(c, 'kg'), unit(c, 'g'), 1.5), closeTo(1500, 1e-9));
  });

  test('temperatura', () {
    final c = cat('Temperatura');
    expect(convert(c, unit(c, '°C'), unit(c, '°F'), 100), closeTo(212, 1e-9));
    expect(convert(c, unit(c, '°F'), unit(c, '°C'), 32), closeTo(0, 1e-9));
    expect(convert(c, unit(c, 'K'), unit(c, '°C'), 0), closeTo(-273.15, 1e-9));
    expect(convert(c, unit(c, '°C'), unit(c, 'K'), 0), closeTo(273.15, 1e-9));
  });

  test('velocidad y datos', () {
    final v = cat('Velocidad');
    expect(convert(v, unit(v, 'km/h'), unit(v, 'm/s'), 36), closeTo(10, 1e-9));
    final d = cat('Datos');
    expect(convert(d, unit(d, 'GB'), unit(d, 'MB'), 1), 1024);
  });

  test('ida y vuelta conserva el valor', () {
    for (final c in categories) {
      for (final a in c.units) {
        for (final b in c.units) {
          final there = convert(c, a, b, 7.5);
          final back = convert(c, b, a, there);
          expect(back, closeTo(7.5, 1e-6), reason: '${c.name} ${a.symbol}->${b.symbol}');
        }
      }
    }
  });

  test('formato', () {
    expect(formatNumber(1234.5), '1,234.5');
    expect(formatNumber(0.5), '0.5');
    expect(formatNumber(100), '100');
    expect(formatNumber(0), '0');
    expect(formatNumber(double.nan), '—');
    expect(parseNumber('1,000.5'), 1000.5);
  });
}
