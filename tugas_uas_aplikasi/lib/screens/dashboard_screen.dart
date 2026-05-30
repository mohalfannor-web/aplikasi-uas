import 'package:flutter/material.dart';
import '../models/task.dart';
import 'detail_tugas_screen.dart';
import 'profile_screen.dart' show globalProfileName;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getIndonesianToday() {
    const days = {
      DateTime.monday: 'Senin',
      DateTime.tuesday: 'Selasa',
      DateTime.wednesday: 'Rabu',
      DateTime.thursday: 'Kamis',
      DateTime.friday: 'Jumat',
      DateTime.saturday: 'Sabtu',
      DateTime.sunday: 'Minggu',
    };
    return days[DateTime.now().weekday] ?? 'Senin';
  }

  void _showNotifications(BuildContext context, List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Filter tasks that are not done and deadline is <= 2 days or overdue
    List<Task> urgentTasks = tasks.where((t) {
      if (t.isDone) return false;
      final taskDate = DateTime(t.deadline.year, t.deadline.month, t.deadline.day);
      return taskDate.difference(today).inDays <= 2;
    }).toList();
    
    // Sort urgent tasks by deadline (earliest/overdue first)
    urgentTasks.sort((a, b) => a.deadline.compareTo(b.deadline));

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifikasi Deadline',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              if (urgentTasks.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                        SizedBox(height: 12),
                        Text(
                          'Semua aman! Tidak ada deadline mendesak.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Text(
                  'Ada ${urgentTasks.length} tugas mendekati deadline:',
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: urgentTasks.length,
                    itemBuilder: (context, index) {
                      final task = urgentTasks[index];
                      final taskDate = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
                      final daysLeft = taskDate.difference(today).inDays;
                      
                      String timeText;
                      Color textColor;
                      if (daysLeft < 0) {
                        timeText = 'Terlewat ${-daysLeft} hari';
                        textColor = Colors.red;
                      } else if (daysLeft == 0) {
                        timeText = 'Hari ini';
                        textColor = Colors.red;
                      } else if (daysLeft == 1) {
                        timeText = 'Besok';
                        textColor = Colors.orange;
                      } else {
                        timeText = '$daysLeft hari lagi';
                        textColor = Colors.orange;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 40,
                              decoration: BoxDecoration(
                                color: task.priority == 'Tinggi' ? Colors.red : (task.priority == 'Sedang' ? Colors.orange : Colors.green),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    task.course,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              timeText,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationBell(BuildContext context, List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int urgentCount = tasks.where((t) {
      if (t.isDone) return false;
      final taskDate = DateTime(t.deadline.year, t.deadline.month, t.deadline.day);
      return taskDate.difference(today).inDays <= 2;
    }).length;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () => _showNotifications(context, tasks),
        ),
        if (urgentCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  '$urgentCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Task>>(
      valueListenable: globalTasks,
      builder: (context, tasks, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              _buildNotificationBell(context, tasks),
              const SizedBox(width: 8),
            ],
          ),
          body: ValueListenableBuilder<List<Jadwal>>(
            valueListenable: globalSchedules,
            builder: (context, schedules, child) {
              int total = tasks.length;
              int selesai = tasks.where((t) => t.isDone).length;
              int belumSelesai = total - selesai;

              List<Task> upcoming = tasks.where((t) => !t.isDone).toList();
              upcoming.sort((a, b) => a.deadline.compareTo(b.deadline));
              List<Task> nearestDeadlines = upcoming.take(3).toList();

              // Filter schedules for today
              String todayStr = _getIndonesianToday();
              List<Jadwal> todaySchedules = schedules.where((s) => s.day == todayStr).toList();
              todaySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: ValueListenableBuilder<String>(
                      valueListenable: globalProfileName,
                      builder: (ctx, name, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Halo, $name!', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Semangat hari ini! 💪', style: TextStyle(color: Colors.white70)),
                          const Text('Jangan lupa selesaikan tugasmu.', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Ringkasan Tugas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildSummaryCard('Total Tugas', total.toString(), const Color(0xFFE0E7FF), const Color(0xFF2563EB)),
                      const SizedBox(width: 12),
                      _buildSummaryCard('Selesai', selesai.toString(), const Color(0xFFD1FAE5), const Color(0xFF10B981)),
                      const SizedBox(width: 12),
                      _buildSummaryCard('Belum Selesai', belumSelesai.toString(), const Color(0xFFFFEDD5), const Color(0xFFF59E0B)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Deadline Terdekat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () {}, child: const Text('Lihat semua')),
                    ],
                  ),
                  if (nearestDeadlines.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('Belum ada deadline terdekat.', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ...nearestDeadlines.map((t) => _buildDeadlineItem(context, t)),
                  
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jadwal Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () {}, child: const Text('Lihat semua')),
                    ],
                  ),
                  if (todaySchedules.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('Tidak ada jadwal hari ini.', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ...todaySchedules.map((item) => _buildScheduleItem(item)),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String count, Color bgColor, Color textColor) {
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

  Widget _buildDeadlineItem(BuildContext context, Task task) {
    int daysLeft = task.deadline.difference(DateTime.now()).inDays;
    String timeleft = daysLeft == 0 ? 'Hari ini' : (daysLeft < 0 ? 'Terlewat' : '$daysLeft hari lagi');
    Color tagBg = daysLeft <= 2 ? const Color(0xFFFEE2E2) : const Color(0xFFFFEDD5);
    Color tagText = daysLeft <= 2 ? Colors.red : const Color(0xFFF59E0B);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailTugasScreen(task: task)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(task.course, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text("${task.deadline.day} ${_getMonthName(task.deadline.month)} ${task.deadline.year}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tagBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(timeleft, style: TextStyle(color: tagText, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(Jadwal item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.class_outlined, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.course, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${item.day} | ${item.startTime} - ${item.endTime}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text('Ruangan: ${item.room}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }
}
