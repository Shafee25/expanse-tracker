// lib/screens/analytics_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_expanse_tracker/database/hive_database.dart';
import 'package:my_expanse_tracker/widgets/category_pie_chart.dart';
import 'package:my_expanse_tracker/widgets/monthly_bar_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Consumer<HiveDatabase>(
          builder: (context, db, child) {
            final categoryData = db.categoryExpenseDistribution;
            final monthlyData = db.monthlyExpenseSummary;

            final hasExpenseData =
                categoryData.values.any((v) => v > 0);

            final hasMonthlyData =
                monthlyData.values.any((v) => v > 0);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A148C),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // -------- PIE CHART CARD ----------
                    _card(
                      title: "Expense Categories",
                      child: hasExpenseData
                          ? SizedBox(
                              height: 260,
                              child: CategoryPieChart(
                                distribution: categoryData,
                              ),
                            )
                          : _emptyChart("No expense data available"),
                    ),

                    const SizedBox(height: 28),

                    // -------- BAR CHART CARD ----------
                    _card(
                      title: "Monthly Expenses (Last 12M)",
                      child: hasMonthlyData
                          ? SizedBox(
                              height: 260,
                              child: MonthlyBarChart(
                                monthlySummary: monthlyData,
                              ),
                            )
                          : _emptyChart("No monthly data available"),
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

  // ---------- CARD STYLE ----------
  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // -------- EMPTY STATE ----------
  Widget _emptyChart(String text) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.chart_pie, size: 36, color: Colors.grey.shade500),
            const SizedBox(height: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
