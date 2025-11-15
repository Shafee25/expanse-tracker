// lib/widgets/monthly_bar_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyBarChart extends StatelessWidget {
  final Map<int, double> monthlySummary;

  const MonthlyBarChart({super.key, required this.monthlySummary});

  String _getMonthAbbreviation(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final maxAmount = monthlySummary.values.isEmpty ? 1000.0 : monthlySummary.values.reduce((max, current) => current > max ? current : max);
    final double interval = (maxAmount / 4).ceilToDouble();

    return BarChart(
      BarChartData(
        maxY: maxAmount * 1.2,
        barGroups: List.generate(12, (index) {
          final month = index + 1;
          final amount = monthlySummary[month] ?? 0.0;
          return BarChartGroupData(x: month, barRods: [
            BarChartRodData(
              toY: amount,
              color: Colors.white.withOpacity(0.8), // Made bars a soft white
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ]);
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              // --- FIX: CHANGING BOTTOM AXIS TEXT TO WHITE ---
              getTitlesWidget: (value, meta) => SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(_getMonthAbbreviation(value.toInt()), style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: interval > 0 ? interval : 1,
              // --- FIX: CHANGING LEFT AXIS TEXT TO WHITE ---
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(fontSize: 9, color: Colors.white),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true, drawVerticalLine: false,
          // Made grid lines a soft, transparent white
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.15), strokeWidth: 1),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black, // Darker tooltip for contrast
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              '${_getMonthAbbreviation(group.x)}\n',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: 'Rs. ${rod.toY.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}