import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_helper.dart';

class DetailTugasScreen extends StatefulWidget {
  final Task task;
  const DetailTugasScreen({super.key, required this.task});

  @override
  State<DetailTugasScreen> createState() => _DetailTugasScreenState();
}

class _DetailTugasScreenState extends State<DetailTugasScreen> {
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _isDone = widget.task.isDone;
  }

  void _toggleStatus() async {
    setState(() {
      _isDone = !_isDone;
      widget.task.isDone = _isDone;
    });
    // Simpan perubahan status ke SQLite
    await DatabaseHelper.instance.updateTask(widget.task);
    // Notify listeners to update other screens
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    globalTasks.notifyListeners();
  }

  void _hapusTugas() async {
    await DatabaseHelper.instance.deleteTask(widget.task.id);
    globalTasks.value = globalTasks.value.where((t) => t.id != widget.task.id).toList();
    if (mounted) Navigator.pop(context);
  }

  void _editTugas() {
    // Show a simple edit dialog
    final TextEditingController titleController = TextEditingController(text: widget.task.title);
    final TextEditingController descController = TextEditingController(text: widget.task.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tugas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Judul')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Deskripsi')),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Status Selesai: '),
                Switch(
                  value: _isDone,
                  onChanged: (val) {
                    setState(() {
                      _isDone = val;
                      widget.task.isDone = val;
                    });
                    Navigator.pop(context);
                    _editTugas(); // Reopen dialog to show updated status (simple way)
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              setState(() {
                widget.task.title = titleController.text;
                widget.task.description = descController.text;
                widget.task.isDone = _isDone;
              });
              // Simpan perubahan ke SQLite
              await DatabaseHelper.instance.updateTask(widget.task);
              // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
              globalTasks.notifyListeners();
              nav.pop();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int daysLeft = widget.task.deadline.difference(DateTime.now()).inDays;
    String timeleft = daysLeft == 0 ? 'Hari ini' : (daysLeft < 0 ? 'Terlewat' : '$daysLeft hari lagi');

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text('Detail Tugas', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _toggleStatus,
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(6),
                      color: _isDone ? const Color(0xFF10B981) : Colors.transparent,
                      border: Border.all(color: _isDone ? const Color(0xFF10B981) : Colors.grey.shade400)
                    ),
                    child: _isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.task.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: _isDone ? TextDecoration.lineThrough : null)),
                      const SizedBox(height: 4),
                      Text(widget.task.course, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (_isDone || daysLeft > 2) ? Colors.blue.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(timeleft, style: TextStyle(color: (_isDone || daysLeft > 2) ? Colors.blue : Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.calendar_today, 'Deadline', "${widget.task.deadline.day}-${widget.task.deadline.month}-${widget.task.deadline.year}"),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.flag, 'Prioritas', widget.task.priority),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.description, 'Deskripsi', widget.task.description ?? 'Tidak ada deskripsi'),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.access_time, 'Status', _isDone ? 'Selesai' : 'Belum Selesai'),
            
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _editTugas,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB), side: const BorderSide(color: Color(0xFF2563EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14)
                    ),
                    child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _hapusTugas,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14)
                    ),
                    child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }
}
