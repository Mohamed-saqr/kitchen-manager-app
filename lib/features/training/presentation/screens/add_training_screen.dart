import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart'; // مكتبة اختيار الملفات
import '../../logic/training_cubit.dart';
import '../../models/TrainingModel.dart';

class AddTrainingScreen extends StatefulWidget {
  const AddTrainingScreen({super.key});

  @override
  State<AddTrainingScreen> createState() => _AddTrainingScreenState();
}

class _AddTrainingScreenState extends State<AddTrainingScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedFilePath; // لتخزين مسار الملف المختار من التليفون
  String _selectedType = 'Video'; // النوع الافتراضي

  // دالة لفتح استوديو الموبايل واختيار الملف
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        // تحديد نوع الملفات المسموح بها بناءً على الاختيار
        type: _selectedType == 'Video' ? FileType.video : FileType.custom,
        allowedExtensions: _selectedType == 'PDF' ? ['pdf'] : null,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم اختيار الملف بنجاح ✅")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء اختيار الملف: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة درس جديد"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("بيانات الدرس", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "عنوان الدرس ",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "وصف قصير",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            const Text("نوع المحتوى"),
            Row(
              children: [
                Radio<String>(
                  value: 'Video',
                  groupValue: _selectedType,
                  onChanged: (val) => setState(() {
                    _selectedType = val!;
                    _selectedFilePath = null; // إعادة تعيين الملف عند تغيير النوع
                  }),
                ),
                const Text("فيديو"),
                const SizedBox(width: 20),
                Radio<String>(
                  value: 'PDF',
                  groupValue: _selectedType,
                  onChanged: (val) => setState(() {
                    _selectedType = val!;
                    _selectedFilePath = null;
                  }),
                ),
                const Text("ملف PDF"),
              ],
            ),

            const SizedBox(height: 10),

            // زرار اختيار الملف من الجهاز
            InkWell(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _selectedFilePath != null ? Colors.green : Colors.grey),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFilePath != null ? Icons.check_circle : Icons.cloud_upload,
                      size: 40,
                      color: _selectedFilePath != null ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedFilePath == null
                          ? "اضغط لاختيار ملف $_selectedType من التليفون"
                          : "تم اختيار: ${_selectedFilePath!.split('/').last}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _selectedFilePath != null ? Colors.green : Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_titleController.text.isNotEmpty && _selectedFilePath != null) {
                    final newLesson = TrainingModel(
                      title: _titleController.text,
                      desc: _descController.text,
                      url: _selectedFilePath!, // بنخزن المسار هنا
                      contentType: _selectedType,
                      progress: 0.0,
                    );

                    context.read<TrainingCubit>().addTraining(newLesson);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("برجاء إكمال البيانات واختيار الملف")),
                    );
                  }
                },
                child: const Text(
                  "حفظ في ملفات التدريب",
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}