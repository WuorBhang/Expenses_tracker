import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/transaction_manager.dart';
import '../controllers/chart_controller.dart';
import '../models/transaction.dart';

class UIController extends StatefulWidget {
  @override
  _UIControllerState createState() => _UIControllerState();
}

class _UIControllerState extends State<UIController> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  File? _receiptImage;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickReceiptImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  void _submitForm(TransactionManager transactionManager) {
    if (_formKey.currentState!.validate()) {
      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        type: _selectedType,
        date: _selectedDate,
        receiptImagePath: _receiptImage?.path,
      );
      transactionManager.addTransaction(newTransaction);
      _formKey.currentState!.reset();
      setState(() {
        _selectedType = TransactionType.expense;
        _selectedDate = DateTime.now();
        _receiptImage = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionManager>(
      builder: (context, transactionManager, child) {
        final transactions = transactionManager.transactions;
        final totalIncome = transactionManager.totalIncome;
        final totalExpense = transactionManager.totalExpense;
        final balance = transactionManager.balance;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Form
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(labelText: 'Amount'),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField<TransactionType>(
                          value: _selectedType,
                          items: [
                            DropdownMenuItem(
                              child: Text('Expense'),
                              value: TransactionType.expense,
                            ),
                            DropdownMenuItem(
                              child: Text('Income'),
                              value: TransactionType.income,
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Type'),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                              ),
                            ),
                            TextButton(
                              onPressed: () => _selectDate(context),
                              child: Text('Select Date'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _receiptImage == null
                                ? Text('No receipt selected.')
                                : Image.file(
                                    _receiptImage!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                            SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _pickReceiptImage,
                              child: Text('Upload Receipt'),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _submitForm(transactionManager),
                          child: Text('Add Transaction'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Summary Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryCard('Income', totalIncome, Colors.greenAccent),
                  _buildSummaryCard('Expense', totalExpense, Colors.redAccent),
                  _buildSummaryCard('Balance', balance, Colors.blueAccent),
                ],
              ),
              SizedBox(height: 24),
              // Pie Chart
              SizedBox(
                height: 200,
                child: ChartController(
                  income: totalIncome,
                  expense: totalExpense,
                ),
              ),
              SizedBox(height: 24),
              // Transactions List
              Text(
                'Transactions',
                style: Theme.of(context).textTheme.headline6,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return Card(
                    child: ListTile(
                      title: Text(tx.description),
                      subtitle: Text(
                          '${tx.type == TransactionType.income ? 'Income' : 'Expense'} - ${tx.date.toLocal().toString().split(' ')[0]}'),
                      trailing: Text('\$${tx.amount.toStringAsFixed(2)}'),
                      onTap: tx.receiptImagePath != null
                          ? () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  content: Image.file(
                                    File(tx.receiptImagePath!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      color: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 100,
        height: 80,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 8),
            Text('\$${amount.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
