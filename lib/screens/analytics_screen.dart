import 'package:my_expanse_tracker/database/hive_database.dart';
import 'package:my_expanse_tracker/widgets/category_pie_chart.dart';
import 'package:my_expanse_tracker/widgets/monthly_bar_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HiveDatabase>(
      builder: (context, db, child) {
        final categoryData = db.categoryExpenseDistribution;
        final monthlyData = db.monthlyExpenseSummary;

        bool hasExpenseData =
            categoryData.isNotEmpty && categoryData.values.any((v) => v > 0);
        bool hasMonthlyData =
            monthlyData.isNotEmpty && monthlyData.values.any((v) => v > 0);

        return Scaffold(
          appBar: AppBar(title: const Text('Analytics')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Pie Chart Card ---
                const Text(
                  'Expense Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Container(
                    height: 250,
                    padding: const EdgeInsets.all(16.0),
                    child: hasExpenseData
                        ? CategoryPieChart(distribution: categoryData)
                        : _buildEmptyState('No expense data for this chart'),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Bar Chart Card ---
                const Text(
                  'Monthly Expenses (Last 12M)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Container(
                    height: 250,
                    padding: const EdgeInsets.all(16.0),
                    child: hasMonthlyData
                        ? MonthlyBarChart(monthlySummary: monthlyData)
                        : _buildEmptyState('No spending data for this chart'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.chart_pie, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
