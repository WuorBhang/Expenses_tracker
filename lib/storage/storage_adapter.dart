import 'package:hive/hive.dart';
import '../models/transaction.dart';

class StorageAdapter {
  static const String boxName = 'transactionsBox';

  Future<void> saveTransactions(List<Transaction> transactions) async {
    var box = await Hive.openBox(boxName);
    List<Map<String, dynamic>> mappedTransactions =
        transactions.map((tx) => tx.toMap()).toList();
    await box.put('transactions', mappedTransactions);
    await box.close();
  }

  Future<List<Transaction>> loadTransactions() async {
    var box = await Hive.openBox(boxName);
    List<dynamic>? stored = box.get('transactions');
    await box.close();
    if (stored == null) return [];
    return stored.map((item) => Transaction.fromMap(Map<String, dynamic>.from(item))).toList();
  }

  Future<void> clearTransactions() async {
    var box = await Hive.openBox(boxName);
    await box.delete('transactions');
    await box.close();
  }
}
