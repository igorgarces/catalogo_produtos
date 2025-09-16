// widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catalogo_produtos/main.dart';
import 'package:catalogo_produtos/repositories/products_repository.dart';
import 'package:catalogo_produtos/notifiers/favorites_notifier.dart';

void main() {
  testWidgets('Smoke test: MyApp builds correctly', (WidgetTester tester) async {
    // Criar instâncias necessárias
    final productsRepo = ProductsRepository();
    final favRepo = FavoritesNotifier();

    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp(
      productsRepo: productsRepo,
      favRepo: favRepo,
    ));

    // Verifica se o título do App aparece na tela
    expect(find.text('Catalog App'), findsOneWidget);

    // Você pode adicionar interações simples, por exemplo:
    // Verifica se o carrinho está presente
    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);

    // Interação de teste (opcional)
    // await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
    // await tester.pump();
    // expect(find.text('1'), findsNothing); // ajuste conforme lógica do app
  });
}
