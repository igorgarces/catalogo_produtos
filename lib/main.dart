import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/products_repository.dart';
import 'notifiers/cart_notifier.dart';
import 'notifiers/favorites_notifier.dart';
import 'notifiers/products_notifier.dart';
import 'pages/catalog_page.dart';

class MyApp extends StatefulWidget {
  final ProductsRepository productsRepo;
  final FavoritesNotifier favRepo;

  const MyApp({
    super.key,
    required this.productsRepo,
    required this.favRepo,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;

  void _toggleTheme() => setState(() => _isDark = !_isDark);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartNotifier()),
        ChangeNotifierProvider(create: (_) => widget.favRepo),
        ChangeNotifierProvider(
            create: (_) =>
                ProductsNotifier(repo: widget.productsRepo, favRepo: widget.favRepo)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Catalog App',
        theme: _isDark ? ThemeData.dark() : ThemeData.light(),
        home: CatalogPage(onToggleTheme: _toggleTheme),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final productsRepo = ProductsRepository();
  await productsRepo.init();

  final favRepo = FavoritesNotifier();

  runApp(MyApp(productsRepo: productsRepo, favRepo: favRepo));
}
