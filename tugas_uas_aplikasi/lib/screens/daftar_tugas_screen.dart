import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import 'tambah_tugas_screen.dart';
import 'detail_tugas_screen.dart';

class DaftarTugasScreen extends StatefulWidget {
  const DaftarTugasScreen({super.key});

  @override
  State<DaftarTugasScreen> createState() => _DaftarTugasScreenState();
}

class _DaftarTugasScreenState extends State<DaftarTugasScreen> {
  int _selectedTab = 0; // 0: Semua, 1: Belum Selesai, 2: Selesai

  void _showNotifications(BuildContext context, List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter tasks that are not done and deadline is <= 2 days or overdue
    List<Task> urgentTasks = tasks.where((t) {
      if (t.isDone) return false;
      final taskDate = DateTime(
        t.deadline.year,
        t.deadline.month,
        t.deadline.day,
      );
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
                  ),
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
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Colors.green,
                        ),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: urgentTasks.length,
                    itemBuilder: (context, index) {
                      final task = urgentTasks[index];
                      final taskDate = DateTime(
                        task.deadline.year,
                        task.deadline.month,
                        task.deadline.day,
                      );
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
                                color: task.priority == 'Tinggi'
                                    ? Colors.red
                                    : (task.priority == 'Sedang'
                                          ? Colors.orange
                                          : Colors.green),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    task.course,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
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
      final taskDate = DateTime(
        t.deadline.year,
        t.deadline.month,
        t.deadline.day,
      );
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
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
            title: const Text(
              'Daftar Tugas',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              _buildNotificationBell(context, tasks),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari tugas...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('Semua', 0),
                    const SizedBox(width: 8),
                    _buildFilterChip('Belum Selesai', 1),
                    const SizedBox(width: 8),
                    _buildFilterChip('Selesai', 2),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ValueListenableBuilder<List<Task>>(
                  valueListenable: globalTasks,
                  builder: (context, tasks, child) {
                    List<Task> filteredTasks = tasks.where((t) {
                      if (_selectedTab == 0) return true;
                      if (_selectedTab == 1) return !t.isDone;
                      return t.isDone;
                    }).toList();

                    if (filteredTasks.isEmpty) {
                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: const [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'Belum ada tugas yang ditambahkan.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskItem(filteredTasks[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TambahTugasScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xFF2563EB),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    bool isUrgent = task.priority == 'Tinggi' && !task.isDone;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTugasScreen(task: task),
          ),
        );
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
            GestureDetector(
              onTap: () async {
                task.isDone = !task.isDone;
                await DatabaseHelper.instance.updateTask(task);
                // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                globalTasks.notifyListeners();
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(6),
                  color: task.isDone
                      ? const Color(0xFF10B981)
                      : Colors.transparent,
                  border: Border.all(
                    color: task.isDone
                        ? const Color(0xFF10B981)
                        : Colors.grey.shade400,
                  ),
                ),
                child: task.isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.course,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${task.deadline.day} ${_getMonthName(task.deadline.month)} ${task.deadline.year}",
                    style: TextStyle(
                      color: isUrgent ? Colors.red : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }
}
