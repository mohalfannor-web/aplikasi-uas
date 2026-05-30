import 'package:flutter/material.dart';
import '../models/task.dart';
import 'tambah_jadwal_screen.dart';


class JadwalKuliahScreen extends StatelessWidget {
  const JadwalKuliahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kuliah', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder<List<Jadwal>>(
        valueListenable: globalSchedules,
        builder: (context, schedules, child) {
          if (schedules.isEmpty) {
            return const Center(
              child: Text('Belum ada jadwal yang ditambahkan.', style: TextStyle(color: Colors.grey)),
            );
          }

          // Sort schedules by day (simple alphabetical or custom order)
          final daysOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
          schedules.sort((a, b) {
            int dayA = daysOrder.indexOf(a.day);
            int dayB = daysOrder.indexOf(b.day);
            if (dayA != dayB) return dayA.compareTo(dayB);
            return a.startTime.compareTo(b.startTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final item = schedules[index];
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
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahJadwalScreen()));
        },
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
