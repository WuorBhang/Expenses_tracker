import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../storage/storage_adapter.dart';

class TransactionManager extends ChangeNotifier {
  final StorageAdapter storageAdapter;
  List<Transaction> _transactions = [];

  TransactionManager({required this.storageAdapter}) {
    loadTransactions();
  }

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  Future<void> loadTransactions() async {
    _transactions = await storageAdapter.loadTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await storageAdapter.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((tx) => tx.id == id);
    await storageAdapter.saveTransactions(_transactions);
    notifyListeners();
  }

  double get totalIncome => _transactions
      .where((tx) => tx.type == TransactionType.income)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.type == TransactionType.expense)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get balance => totalIncome - totalExpense;

  List<Transaction> filterTransactions(TransactionType? type) {
    if (type == null) return transactions;
    return _transactions.where((tx) => tx.type == type).toList();
  }
}
