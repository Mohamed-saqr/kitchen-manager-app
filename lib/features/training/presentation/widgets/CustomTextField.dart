// 1. حقل النص المخصص
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  const CustomTextField({super.key, required this.controller, required this.label, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, maxLines: maxLines,
    decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
  );
}

// 2. اختيار النوع (راديو)
class TypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String?) onChanged;
  const TypeSelector({super.key, required this.selectedType, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
    Radio(value: 'Video', groupValue: selectedType, onChanged: onChanged), const Text("فيديو"),
    const SizedBox(width: 20),
    Radio(value: 'PDF', groupValue: selectedType, onChanged: onChanged), const Text("PDF"),
  ]);
}

// 3. زر اختيار الملف
class FilePickerWidget extends StatelessWidget {
  final String? filePath;
  final String type;
  final VoidCallback onTap;
  const FilePickerWidget({super.key, this.filePath, required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15), border: Border.all(color: filePath != null ? Colors.green : Colors.grey)),
      child: Column(children: [
        Icon(filePath != null ? Icons.check_circle : Icons.cloud_upload, color: filePath != null ? Colors.green : Colors.grey, size: 40),
        Text(filePath == null ? "اختر ملف $type" : filePath!.split('/').last),
      ]),
    ),
  );
}

// 4. زر الحفظ
class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SaveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 55,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4D00)),
      onPressed: onPressed,
      child: const Text("حفظ", style: TextStyle(color: Colors.white, fontSize: 18)),
    ),
  );
}