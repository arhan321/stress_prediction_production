import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final String chartType;

  const ChartCard({
    super.key,
    required this.title,
    required this.chartType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: _buildMockChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockChart(BuildContext context) {
    if (chartType == 'pie') {
      return _buildMockPieChart(context);
    } else if (chartType == 'line') {
      return _buildMockLineChart(context);
    } else {
      return _buildMockBarChart(context);
    }
  }

  Widget _buildMockPieChart(BuildContext context) {
    const data = [
      {'label': 'IT', 'value': 30, 'color': Colors.blue},
      {'label': 'HR', 'value': 25, 'color': Colors.green},
      {'label': 'Marketing', 'value': 20, 'color': Colors.orange},
      {'label': 'Finance', 'value': 15, 'color': Colors.purple},
      {'label': 'Operations', 'value': 10, 'color': Colors.red},
    ];

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: data.map((d) => d['color'] as Color).toList(),
                  stops: const [0.0, 0.3, 0.55, 0.7, 0.85, 1.0],
                ),
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item['label']} (${item['value']}%)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMockLineChart(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 120),
      painter: LineChartPainter(
        points: const [20, 35, 28, 42, 38, 45, 33, 40],
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildMockBarChart(BuildContext context) {
    const data = [40, 65, 30, 80, 55, 75, 45];
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((value) {
        return Container(
          width: 20,
          height: (value / maxValue) * 100,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        );
      }).toList(),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> points;
  final Color color;

  LineChartPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (points.length - 1);
    final maxValue = points.reduce((a, b) => a > b ? a : b);
    final minValue = points.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - ((points[i] - minValue) / range) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - ((points[i] - minValue) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 