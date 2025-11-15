import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> distribution;

  const CategoryPieChart({super.key, required this.distribution});

  // Simple function to generate colors for the chart
  List<Color> _generateColors(int count) {
    final baseColors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.purple.shade400,
      Colors.yellow.shade600,
      Colors.teal.shade400,
    ];
    List<Color> colors = [];
    for (int i = 0; i < count; i++) {
      colors.add(baseColors[i % baseColors.length]);
    }
    return colors;
  }

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0.0, (sum, item) => sum + item);
    final colors = _generateColors(distribution.length);
    int colorIndex = 0;

    final List<PieChartSectionData> sections = distribution.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = colors[colorIndex++];
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 70, // Kept the smaller radius to fit better
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 1)],
        ),
      );
    }).toList();

    return Row(
      children: [
        // The Pie Chart
        // flex: 2 means it takes up 40% of the width
        Expanded(
          flex: 3, 
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        // Add some space
        const SizedBox(width: 16),
        // The Legend
        // flex: 3 means it takes up 60% of the width (More space for text!)
        Expanded(
          flex: 1, 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(distribution.length, (index) {
              return _buildLegendItem(
                colors[index],
                distribution.keys.elementAt(index),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}