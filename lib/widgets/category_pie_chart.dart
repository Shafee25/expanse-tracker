// lib/widgets/category_pie_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> distribution;

  const CategoryPieChart({super.key, required this.distribution});

  List<Color> _generateColors(int count) {
    final baseColors = [
      Colors.green.shade300, Colors.blue.shade300, Colors.orange.shade300,
      Colors.red.shade300, Colors.purple.shade300, Colors.teal.shade300,
      Colors.pink.shade200, Colors.amber.shade500,
    ];
    return List.generate(count, (i) => baseColors[i % baseColors.length]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 380) return _buildVerticalLayout();
        else return _buildHorizontalLayout();
      },
    );
  }

  Widget _buildHorizontalLayout() {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildChart()),
          const SizedBox(width: 20),
          Expanded(flex: 2, child: _buildLegend()),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      children: [
        SizedBox(height: 180, child: _buildChart()),
        const SizedBox(height: 24),
        _buildLegend(),
      ],
    );
  }

  Widget _buildChart() {
    final total = distribution.values.fold(0.0, (sum, item) => sum + item);
    final sortedEntries = distribution.entries.toList();
    final colors = _generateColors(sortedEntries.length);

    return PieChart(
      PieChartData(
        sections: List.generate(sortedEntries.length, (index) {
          final entry = sortedEntries[index];
          final percentage = (entry.value / total) * 100;
          return PieChartSectionData(
            color: colors[index],
            value: entry.value,
            title: percentage > 7 ? '${percentage.toStringAsFixed(0)}%' : '',
            radius: 70,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, shadows: [Shadow(color: Colors.white, blurRadius: 2)]),
          );
        }),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildLegend() {
    final total = distribution.values.fold(0.0, (sum, item) => sum + item);
    final sortedEntries = distribution.entries.toList();
    final colors = _generateColors(sortedEntries.length);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(sortedEntries.length, (index) {
        final entry = sortedEntries[index];
        final percentage = (entry.value / total) * 100;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(width: 14, height: 14, color: colors[index]),
              const SizedBox(width: 8),
              // --- FIX: CHANGING LEGEND TEXT TO WHITE ---
              Expanded(child: Text(entry.key, style: const TextStyle(fontSize: 13, color: Colors.white))),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                // Using a slightly transparent white for the percentage
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        );
      }),
    );
  }
}