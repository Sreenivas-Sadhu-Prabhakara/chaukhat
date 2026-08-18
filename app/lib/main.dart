import 'package:flutter/material.dart';

void main() => runApp(const ChaukhatApp());

/// Chaukhat — photo/mirror frame quote. Combines perimeter-rate molding with
/// area-rate glass and mount, plus labour. Mirrors the Go engine.
class ChaukhatApp extends StatelessWidget {
  const ChaukhatApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Chaukhat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF7E5B34), useMaterial3: true),
        home: const HomePage(),
      );
}

class Quote {
  final double perimeter, area, molding, glass, mount, total;
  const Quote(this.perimeter, this.area, this.molding, this.glass, this.mount, this.total);
}

/// quote mirrors backend/cost.go.
Quote quote({
  required double h, required double w, required double moldingRate,
  required double glassRate, required double mountRate, required double labour,
}) {
  final perimeter = 2 * (h + w) / 100;
  final area = (h * w) / 10000;
  final molding = perimeter * moldingRate;
  final glass = area * glassRate;
  final mount = area * mountRate;
  return Quote(perimeter, area, molding, glass, mount, molding + glass + mount + labour);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _h = TextEditingController(text: '40');
  final _w = TextEditingController(text: '50');
  final _mold = TextEditingController(text: '120');
  final _glass = TextEditingController(text: '800');
  final _mount = TextEditingController(text: '300');
  final _labour = TextEditingController(text: '150');

  double _n(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final q = quote(h: _n(_h), w: _n(_w), moldingRate: _n(_mold),
        glassRate: _n(_glass), mountRate: _n(_mount), labour: _n(_labour));
    String m(double v) => '₹${v.toStringAsFixed(2)}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chaukhat · frame quote'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [Expanded(child: _f(_h, 'Height cm')), const SizedBox(width: 12), Expanded(child: _f(_w, 'Width cm'))]),
        Row(children: [Expanded(child: _f(_mold, 'Molding ₹/m')), const SizedBox(width: 12), Expanded(child: _f(_labour, 'Labour ₹'))]),
        Row(children: [Expanded(child: _f(_glass, 'Glass ₹/sqm')), const SizedBox(width: 12), Expanded(child: _f(_mount, 'Mount ₹/sqm'))]),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Itemised quote', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${q.perimeter.toStringAsFixed(2)} m perimeter · ${q.area.toStringAsFixed(3)} sqm', style: const TextStyle(fontSize: 12)),
              const Divider(),
              _row('Molding', m(q.molding)),
              _row('Glass', m(q.glass)),
              _row('Mount', m(q.mount)),
              _row('Labour', m(_n(_labour))),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(m(q.total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ]),
            ])),
        ),
      ]),
    );
  }

  Widget _f(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          onChanged: (_) => setState(() {})),
      );

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k), Text(v)]),
      );
}
