import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_helper.dart';

class TambahTugasScreen extends StatefulWidget {
  const TambahTugasScreen({super.key});

  @override
  State<TambahTugasScreen> createState() => _TambahTugasScreenState();
}

class _TambahTugasScreenState extends State<TambahTugasScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedPriority = 'Tinggi';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _deadlineController.text = "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
      });
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  void _simpanTugas() async {
    if (_titleController.text.isEmpty || _courseController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul, Mata Kuliah, dan Deadline harus diisi.')));
      return;
    }

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      course: _courseController.text,
      deadline: _selectedDate!,
      description: _descController.text.isNotEmpty ? _descController.text : null,
      priority: _selectedPriority,
    );

    // Simpan ke SQLite
    await DatabaseHelper.instance.insertTask(newTask);
    // Update in-memory global state
    globalTasks.value = [...globalTasks.value, newTask];
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _deadlineController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text('Tambah Tugas', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Judul Tugas', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Masukkan judul tugas',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Mata Kuliah', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              final courses = globalSchedules.value.map((e) => e.course).toSet().toList();
              if (textEditingValue.text.isEmpty) {
                return courses;
              }
              return courses.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              _courseController.text = selection;
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              // Sync the local controller with autocomplete controller
              if (_courseController.text.isNotEmpty && controller.text.isEmpty) {
                controller.text = _courseController.text;
              }
              controller.addListener(() {
                _courseController.text = controller.text;
              });

              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Masukkan atau pilih mata kuliah',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Deadline', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _deadlineController,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              hintText: 'Pilih tanggal',
              suffixIcon: const Icon(Icons.calendar_today),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Deskripsi (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Masukkan deskripsi tugas',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Prioritas', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPriorityRadio('Rendah', Colors.green),
              const SizedBox(width: 8),
              _buildPriorityRadio('Sedang', Colors.orange),
              const SizedBox(width: 8),
              _buildPriorityRadio('Tinggi', Colors.red),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _simpanTugas,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Simpan Tugas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPriorityRadio(String label, Color color) {
    bool isSelected = _selectedPriority == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? color : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
