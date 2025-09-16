import 'dart:convert';
import 'product.dart';

class Purchase {
  final String id;
  final DateTime date;
  final List<Product> items; // snapshot dos produtos no momento da compra
  final double total;

  Purchase({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        id: json['id'].toString(),
        date: DateTime.parse(json['date']),
        items: (json['items'] as List)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
      };

  String toJsonString() => jsonEncode(toJson());
}
