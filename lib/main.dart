import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/products_repository.dart';
import 'repositories/order_repository.dart';
import 'notifiers/products_notifier.dart';
import 'notifiers/cart_notifier.dart';
import 'notifiers/favorites_notifier.dart';
import 'pages/catalog_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final productsRepo = ProductsRepository();
  await productsRepo.init();

  final ordersRepo = OrdersRepository();
  await ordersRepo.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<ProductsRepository>.value(value: productsRepo),
        Provider<OrdersRepository>.value(value: ordersRepo),
        ChangeNotifierProvider(
          create: (_) => ProductsNotifier(repo: productsRepo, favRepo: FavoritesNotifier()),
        ),
        ChangeNotifierProvider(
          create: (_) => CartNotifier(ordersRepo: ordersRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesNotifier(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;

  void _toggleTheme() => setState(() => _isDark = !_isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catálogo',
      theme: _isDark ? ThemeData.dark() : ThemeData.light(),
      home: CatalogPage(onToggleTheme: _toggleTheme),
    );
  }
}
