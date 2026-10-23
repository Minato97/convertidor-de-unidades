class Unit {
  const Unit(this.name, this.symbol, this.factor);

  final String name;
  final String symbol;

  /// Cuántas unidades base equivale 1 de esta unidad.
  final double factor;
}

class Category {
  const Category(this.name, this.units, {this.temperature = false});

  final String name;
  final List<Unit> units;
  final bool temperature;
}

const categories = <Category>[
  Category('Longitud', [
    Unit('Metro', 'm', 1),
    Unit('Kilómetro', 'km', 1000),
    Unit('Centímetro', 'cm', 0.01),
    Unit('Milímetro', 'mm', 0.001),
    Unit('Milla', 'mi', 1609.344),
    Unit('Yarda', 'yd', 0.9144),
    Unit('Pie', 'ft', 0.3048),
    Unit('Pulgada', 'in', 0.0254),
  ]),
  Category('Masa', [
    Unit('Kilogramo', 'kg', 1),
    Unit('Gramo', 'g', 0.001),
    Unit('Miligramo', 'mg', 0.000001),
    Unit('Tonelada', 't', 1000),
    Unit('Libra', 'lb', 0.45359237),
    Unit('Onza', 'oz', 0.028349523125),
  ]),
  Category('Temperatura', [
    Unit('Celsius', '°C', 1),
    Unit('Fahrenheit', '°F', 1),
    Unit('Kelvin', 'K', 1),
  ], temperature: true),
  Category('Volumen', [
    Unit('Litro', 'L', 1),
    Unit('Mililitro', 'mL', 0.001),
    Unit('Metro cúbico', 'm³', 1000),
    Unit('Galón (EE. UU.)', 'gal', 3.785411784),
    Unit('Cuarto (EE. UU.)', 'qt', 0.946352946),
    Unit('Taza (EE. UU.)', 'cup', 0.2365882365),
    Unit('Onza líquida (EE. UU.)', 'fl oz', 0.0295735295625),
  ]),
  Category('Área', [
    Unit('Metro cuadrado', 'm²', 1),
    Unit('Kilómetro cuadrado', 'km²', 1000000),
    Unit('Hectárea', 'ha', 10000),
    Unit('Pie cuadrado', 'ft²', 0.09290304),
    Unit('Yarda cuadrada', 'yd²', 0.83612736),
    Unit('Acre', 'ac', 4046.8564224),
  ]),
  Category('Velocidad', [
    Unit('Metro por segundo', 'm/s', 1),
    Unit('Kilómetro por hora', 'km/h', 0.2777777777778),
    Unit('Milla por hora', 'mph', 0.44704),
    Unit('Nudo', 'kn', 0.5144444444444),
  ]),
  Category('Tiempo', [
    Unit('Segundo', 's', 1),
    Unit('Minuto', 'min', 60),
    Unit('Hora', 'h', 3600),
    Unit('Día', 'd', 86400),
    Unit('Semana', 'sem', 604800),
  ]),
  Category('Datos', [
    Unit('Byte', 'B', 1),
    Unit('Kilobyte', 'KB', 1024),
    Unit('Megabyte', 'MB', 1048576),
    Unit('Gigabyte', 'GB', 1073741824),
    Unit('Terabyte', 'TB', 1099511627776),
  ]),
];

double _toCelsius(double v, String symbol) => switch (symbol) {
      '°F' => (v - 32) * 5 / 9,
      'K' => v - 273.15,
      _ => v,
    };

double _fromCelsius(double c, String symbol) => switch (symbol) {
      '°F' => c * 9 / 5 + 32,
      'K' => c + 273.15,
      _ => c,
    };

double convert(Category cat, Unit from, Unit to, double value) {
  if (cat.temperature) {
    return _fromCelsius(_toCelsius(value, from.symbol), to.symbol);
  }
  return value * from.factor / to.factor;
}

/// Formato legible: sin ceros sobrantes y notación científica para extremos.
String formatNumber(double v) {
  if (v.isNaN || v.isInfinite) return '—';
  if (v == 0) return '0';
  final a = v.abs();
  if (a >= 1e12 || a < 1e-6) return v.toStringAsExponential(4);
  var s = a >= 1000 ? v.toStringAsFixed(2) : v.toStringAsPrecision(8);
  if (s.contains('.') && !s.contains('e')) {
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  if (s.contains('e')) return v.toStringAsExponential(4);
  final parts = s.split('.');
  final neg = parts[0].startsWith('-');
  final intPart = parts[0].replaceFirst('-', '').replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
  return '${neg ? '-' : ''}$intPart${parts.length > 1 ? '.${parts[1]}' : ''}';
}

double parseNumber(String s) =>
    double.tryParse(s.replaceAll(',', '').trim()) ?? 0;
