import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notifiers/cart_notifier.dart';
import 'notifiers/favorites_notifier.dart';
import 'repositories/products_repository.dart';
import 'pages/catalog_page.dart';

void main() {
  runApp(const MyApp());
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartNotifier()),
        ChangeNotifierProvider(create: (_) => FavoritesNotifier()),
        Provider(create: (_) => ProductsRepository()),
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
