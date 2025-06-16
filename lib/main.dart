import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/transaction_manager.dart';
import 'storage/storage_adapter.dart';
import 'ui/ui_controller.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionManager(storageAdapter: StorageAdapter()),
      child: MaterialApp(
        title: 'Ghibli-Style Expense Tracker',
        theme: ThemeData(
          primaryColor: Color(0xFF7fc2f4), // Ghibli blue
          accentColor: Color(0xFF8bd0ab), // Ghibli green
          scaffoldBackgroundColor: Color(0xFFf9f7e8), // Ghibli cream
          fontFamily: 'Roboto',
          textTheme: TextTheme(
            headline6: TextStyle(color: Color(0xFF8f6f5c)), // Ghibli brown
            bodyText2: TextStyle(color: Colors.black87),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF7fc2f4),
            foregroundColor: Colors.white,
          ),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Ghibli-Style Expense Tracker'),
          ),
          body: UIController(),
        ),
      ),
    );
  }
}
