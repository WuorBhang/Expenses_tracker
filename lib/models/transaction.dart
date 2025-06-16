import 'package:flutter/foundation.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? receiptImagePath;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    this.receiptImagePath,
  });

  // For serialization/deserialization if needed
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': describeEnum(type),
      'date': date.toIso8601String(),
      'receiptImagePath': receiptImagePath,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      date: DateTime.parse(map['date']),
      receiptImagePath: map['receiptImagePath'],
    );
  }
}
