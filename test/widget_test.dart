import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_market/main.dart';

void main() {
  testWidgets('Counter smoke test', (WidgetTester tester) async {
    // Atualizado para o nome correto da sua classe
    await tester.pumpWidget(const LocalMarketApp());

    expect(find.text('Mercado Local Açores'), findsNothing); // Teste básico
  });
}
