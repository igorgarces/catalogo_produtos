import 'package:flutter/foundation.dart';
import '../models/purchase.dart';
import '../storage/purchase_storage.dart';

class PurchaseNotifier extends ChangeNotifier {
  List<Purchase> _purchases = [];

  List<Purchase> get purchases => List.unmodifiable(_purchases);

  PurchaseNotifier() {
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    _purchases = await PurchaseStorage.loadPurchases();
    notifyListeners();
  }

  Future<void> addPurchase(Purchase purchase) async {
    await PurchaseStorage.savePurchase(purchase);
    _purchases.add(purchase);
    notifyListeners();
  }
}
