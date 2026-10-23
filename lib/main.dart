import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ads.dart';
import 'units.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdService.instance.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF16A34A);
    return MaterialApp(
      title: 'Convertidor de Unidades',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: seed, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

const _catIcons = <IconData>[
  Icons.straighten,
  Icons.scale,
  Icons.thermostat,
  Icons.local_drink,
  Icons.crop_square,
  Icons.speed,
  Icons.schedule,
  Icons.sd_storage,
];

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.showAds = true});

  final bool showAds;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _cat = 0;
  int _from = 0;
  int _to = 1;
  final _input = TextEditingController(text: '1');
  int _uses = 0;

  Category get cat => categories[_cat];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _setCat(int i) => setState(() {
        _cat = i;
        _from = 0;
        _to = 1;
        _input.text = categories[i].temperature ? '25' : '1';
      });

  void _swap() => setState(() {
        final t = _from;
        _from = _to;
        _to = t;
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = parseNumber(_input.text);
    final from = cat.units[_from];
    final to = cat.units[_to];
    final result = convert(cat, from, to, value);

    Widget picker(int selected, ValueChanged<int> onChanged) =>
        DropdownButtonFormField<int>(
          initialValue: selected,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          items: [
            for (var i = 0; i < cat.units.length; i++)
              DropdownMenuItem(
                value: i,
                child: Text('${cat.units[i].name} (${cat.units[i].symbol})',
                    overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) => onChanged(v ?? selected),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Convertidor de Unidades')),
      bottomNavigationBar:
          widget.showAds ? const BannerAdWidget() : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var i = 0; i < categories.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(_catIcons[i], size: 18),
                      label: Text(categories[i].name),
                      selected: _cat == i,
                      onSelected: (_) => _setCat(i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _input,
                  onChanged: (_) => setState(() {
                    if (++_uses % 8 == 0) {
                      AdService.instance.maybeShowInterstitial(every: 1);
                    }
                  }),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800),
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                picker(_from, (v) => setState(() => _from = v)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: IconButton.filledTonal(
                    onPressed: _swap,
                    icon: const Icon(Icons.swap_vert),
                    tooltip: 'Intercambiar',
                  ),
                ),
                picker(_to, (v) => setState(() => _to = v)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: theme.colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${formatNumber(value)} ${from.symbol} equivale a',
                    style: theme.textTheme.labelLarge),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${formatNumber(result)} ${to.symbol}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                        text:
                            '${formatNumber(value)} ${from.symbol} = ${formatNumber(result)} ${to.symbol}'));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Resultado copiado')));
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copiar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Todas las unidades',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                for (final u in cat.units)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(u.name)),
                        Text(
                          '${formatNumber(convert(cat, from, u, value))} ${u.symbol}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
