// lib/screens/analytics_screen.dart

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
    return Scaffold(
      body: SafeArea(
        child: Consumer<HiveDatabase>(
          builder: (context, db, child) {
            final categoryData = db.categoryExpenseDistribution;
            final monthlyData = db.monthlyExpenseSummary;

            bool hasExpenseData =
                categoryData.isNotEmpty &&
                categoryData.values.any((v) => v > 0);
            bool hasMonthlyData =
                monthlyData.isNotEmpty && monthlyData.values.any((v) => v > 0);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A148C), // Dark Purple
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- Pie Chart Card ---
                    _buildChartCard(
                      // Now you pass the fully styled Text widget, and it will work.
                      titleWidget: const Text(
                        'Expense Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple,
                        ),
                      ),
                      hasData: hasExpenseData,
                      chart: Column(
                        children: [
                          const SizedBox(height: 20),
                          CategoryPieChart(distribution: categoryData),
                        ],
                      ),
                      emptyMessage: 'No expense data for this chart.',
                    ),
                    const SizedBox(height: 24),

                    // --- Bar Chart Card ---
                    _buildChartCard(
                      // The second title remains white, as in the previous design.
                      titleWidget: const Text(
                        'Monthly Expenses (Last 12M)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple,
                        ),
                      ),
                      hasData: hasMonthlyData,
                      chart: SizedBox(
                        height: 250,
                        child: MonthlyBarChart(monthlySummary: monthlyData),
                      ),
                      emptyMessage: 'No spending data for this chart.',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- THIS METHOD IS NOW FIXED ---
  Widget _buildChartCard({
    required Widget titleWidget, // Changed from String to Widget
    required bool hasData,
    required Widget chart,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleWidget, // Use the widget directly
        const SizedBox(height: 12),
        Card(
          color: Colors.deepPurple.shade400,
          elevation: 2,
          shadowColor: Colors.deepPurple.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: hasData ? chart : _buildEmptyState(emptyMessage),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 250,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.chart_pie, size: 40, color: Colors.white54),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
