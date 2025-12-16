import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/task_provider.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    
    final int todoCount = taskProvider.getTasksByStatus('pending').length;
    final int inProgressCount = taskProvider.getTasksByStatus('in_progress').length;
    final int doneCount = taskProvider.getTasksByStatus('completed').length;
    final int total = todoCount + inProgressCount + doneCount;
    
    // Prevent division by zero
    final safeTotal = total == 0 ? 1 : total;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productivity',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              
              // 1. Main Pie Chart Card
              Container(
                height: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF181C26),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 70,
                        sections: [
                          PieChartSectionData(
                            color: const Color(0xFF246BFD),
                            value: todoCount.toDouble(),
                            title: '${((todoCount/safeTotal)*100).toInt()}%',
                            radius: 25,
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: const Color(0xFFFF9F43), // Orange
                            value: inProgressCount.toDouble(),
                            title: '${((inProgressCount/safeTotal)*100).toInt()}%',
                            radius: 25,
                             titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: const Color(0xFF00D2D3), // Cyan
                            value: doneCount.toDouble(),
                            title: '${((doneCount/safeTotal)*100).toInt()}%',
                            radius: 25,
                             titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          // Empty state
                          if (total == 0)
                             PieChartSectionData(
                            color: Colors.grey.shade800,
                            value: 1,
                            title: '',
                            radius: 20,
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           Text(
                            '$total',
                            style: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Tasks',
                            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 2. Legend / Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard('To Do', todoCount, const Color(0xFF246BFD)),
                  _buildStatCard('Doing', inProgressCount, const Color(0xFFFF9F43)),
                  _buildStatCard('Done', doneCount, const Color(0xFF00D2D3)),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 3. Weekly Activity (Mock Bar Chart)
              Text(
                'Weekly Activity',
                style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF181C26),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 10,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const titles = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            if (value.toInt() < titles.length) {
                               return Text(titles[value.toInt()], style: TextStyle(color: Colors.grey.shade600, fontSize: 12));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _makeBarGroup(0, 5),
                      _makeBarGroup(1, 3),
                      _makeBarGroup(2, 8, isHigh: true),
                      _makeBarGroup(3, 4),
                      _makeBarGroup(4, 6),
                      _makeBarGroup(5, 2),
                      _makeBarGroup(6, 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF181C26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
             Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, {bool isHigh = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isHigh ? const Color(0xFF246BFD) : const Color(0xFF246BFD).withOpacity(0.3),
          width: 16,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10, // Max height background
            color: const Color(0xFF0B0E14),
          ),
        ),
      ],
    );
  }
}
