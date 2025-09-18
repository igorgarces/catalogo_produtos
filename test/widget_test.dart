// widget_test.dart
import 'package:catalogo_produtos/repositories/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catalogo_produtos/main.dart';
import 'package:catalogo_produtos/repositories/products_repository.dart';

import 'package:catalogo_produtos/notifiers/favorites_notifier.dart';

void main() {
  testWidgets('Smoke test: MyApp builds correctly', (WidgetTester tester) async {
    // Inicializa os repositórios
    final productsRepo = ProductsRepository();
    await productsRepo.init();

    final ordersRepo = OrdersRepository();
    await ordersRepo.init();

    final favRepo = FavoritesNotifier();

    // Build do app
    await tester.pumpWidget(MyApp(
      productsRepo: productsRepo,
      favRepo: favRepo,
      ordersRepo: ordersRepo,
    ));

    // Garante que o MaterialApp e Scaffold estão presentes
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // Verifica se o título do App aparece na tela
    expect(find.text('Catálogo'), findsOneWidget);

    // Verifica se o ícone do carrinho aparece
    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);

    // Teste de pull-to-refresh (RefreshIndicator)
    final listFinder = find.byType(ListView);
    expect(listFinder, findsOneWidget);

    await tester.drag(listFinder, const Offset(0.0, 300.0));
    await tester.pumpAndSettle();

    // Testa botão de adicionar produto (FAB ou AppBar)
    final addButton = find.byIcon(Icons.add_box_outlined);
    expect(addButton, findsOneWidget);

    // Testa botão de histórico de compras
    final historyButton = find.byIcon(Icons.history);
    expect(historyButton, findsOneWidget);

    // Testa ícone de alternar tema
    final themeButton = find.byIcon(Icons.brightness_6);
    expect(themeButton, findsOneWidget);
  });
}
