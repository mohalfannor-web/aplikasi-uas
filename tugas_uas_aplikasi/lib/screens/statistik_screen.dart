import 'package:flutter/material.dart';
import '../models/task.dart';

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text('Minggu Ini', style: TextStyle(color: Colors.black, fontSize: 12)),
                    Icon(Icons.arrow_drop_down, color: Colors.black, size: 16),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: ValueListenableBuilder<List<Task>>(
        valueListenable: globalTasks,
        builder: (context, tasks, child) {
          int total = tasks.length;
          int selesai = tasks.where((t) => t.isDone).length;
          int belumSelesai = total - selesai;
          double percent = total == 0 ? 0 : selesai / total;

          Map<String, int> courseCount = {};
          for (var task in tasks) {
            courseCount[task.course] = (courseCount[task.course] ?? 0) + 1;
          }
          
          int maxCourseCount = courseCount.isEmpty ? 1 : courseCount.values.reduce((a, b) => a > b ? a : b);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  _buildStatCard('Total Tugas', total.toString(), const Color(0xFFE0E7FF), const Color(0xFF2563EB)),
                  const SizedBox(width: 12),
                  _buildStatCard('Selesai', selesai.toString(), const Color(0xFFD1FAE5), const Color(0xFF10B981)),
                  const SizedBox(width: 12),
                  _buildStatCard('Belum Selesai', belumSelesai.toString(), const Color(0xFFFFEDD5), const Color(0xFFF59E0B)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Persentase Penyelesaian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: percent,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFF10B981),
                          strokeWidth: 16,
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${(percent * 100).toInt()}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              const Text('Selesai', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Selesai ($selesai)', const Color(0xFF10B981)),
                      const SizedBox(height: 8),
                      _buildLegendItem('Belum Selesai ($belumSelesai)', const Color(0xFFF59E0B)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 32),
              const Text('Tugas per Mata Kuliah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (courseCount.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('Belum ada data mata kuliah.', style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ...courseCount.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildBarChartItem(e.key, e.value, maxCourseCount, const Color(0xFF10B981)),
                )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildBarChartItem(String label, int value, int maxValue, Color barColor) {
    double percent = value / maxValue;
    return Row(
      children: [
        Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          flex: 5,
          child: Row(
            children: [
              Expanded(
                flex: (percent * 100).toInt(),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Expanded(
                flex: ((1 - percent) * 100).toInt(),
                child: Container(),
              )
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(value.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
