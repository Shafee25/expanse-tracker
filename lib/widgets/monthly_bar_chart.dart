import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyBarChart extends StatelessWidget {
  final Map<int, double> monthlySummary; // Key: 1-12, Value: Amount

  const MonthlyBarChart({super.key, required this.monthlySummary});

  // Helper to get month abbreviation
  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1]; // month is 1-based
  }

  @override
  Widget build(BuildContext context) {
    // Find the max value for scaling the Y-axis
    final maxAmount = monthlySummary.values.isEmpty
        ? 1.0
        : monthlySummary.values
            .reduce((max, current) => current > max ? current : max);

    // Create bar groups
    final List<BarChartGroupData> barGroups = [];
    for (int month = 1; month <= 12; month++) {
      final amount = monthlySummary[month] ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: amount,
              color: Colors.deepPurple.shade300,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        maxY: maxAmount * 1.2, // Give 20% breathing room
        barGroups: barGroups,
        titlesData: FlTitlesData(
          // Bottom Titles (Months)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _getMonthAbbreviation(value.toInt()),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          // Left Titles (Amount)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return Container();
                // Show amounts in 'K' for thousands
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(fontSize: 9),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
          // Hide top and right titles
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final month = _getMonthAbbreviation(group.x);
              final amount = rod.toY;
              return BarTooltipItem(
                '$month\nRs. ${amount.toStringAsFixed(2)}', // <-- CURRENCY CHANGED
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}