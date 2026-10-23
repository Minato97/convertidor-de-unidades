// SHOTS=1 flutter test test/shots_test.dart  -> store/screenshot_N.png
import 'dart:io';
import 'dart:ui' as ui;

import 'package:convertidor_unidades/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _font(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

void main() {
  final enabled = Platform.environment['SHOTS'] == '1';
  testWidgets('capturas', skip: !enabled, (tester) async {
    final sdk = Platform.environment['FLUTTER_ROOT'] ??
        File(Platform.resolvedExecutable).parent.parent.parent.parent.path;
    final fonts = '$sdk/bin/cache/artifacts/material_fonts';
    await _font('Roboto', '$fonts/roboto-regular.ttf');
    await _font('Roboto', '$fonts/roboto-bold.ttf');
    await _font('MaterialIcons', '$fonts/materialicons-regular.otf');

    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTouch;
    tester.view.devicePixelRatio = 2.625;
    tester.view.physicalSize = const Size(1080, 2160);
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    Future<void> save(String name) async {
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.625);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        File('store/$name').writeAsBytesSync(data!.buffer.asUint8List());
      });
    }

    await tester.pumpWidget(RepaintBoundary(
      key: key,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF16A34A),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const HomePage(showAds: false),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    Future<void> shot(String chip, String value, int n) async {
      await tester.ensureVisible(find.text(chip));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(chip));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextField), value);
      await tester.pump(const Duration(milliseconds: 300));
      await save('screenshot_$n.png');
    }

    await tester.enterText(find.byType(TextField), '5');
    await tester.pump(const Duration(milliseconds: 300));
    await save('screenshot_1.png');

    await shot('Masa', '70', 2);
    await shot('Temperatura', '36.6', 3);
    await shot('Velocidad', '120', 4);
  });
}
