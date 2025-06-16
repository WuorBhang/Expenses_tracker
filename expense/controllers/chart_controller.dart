import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartController extends StatelessWidget {
  final double income;
  final double expense;

  ChartController({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final total = income + expense;
    final incomePercent = total == 0 ? 0 : (income / total) * 100;
    final expensePercent = total == 0 ? 0 : (expense / total) * 100;

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.greenAccent,
            value: income,
            title: '${incomePercent.toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          PieChartSectionData(
            color: Colors.redAccent,
            value: expense,
            title: '${expensePercent.toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 30,
      ),
    );
  }
}
