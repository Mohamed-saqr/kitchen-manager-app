// انسخ هذا الملف في lib/features/training/presentation/widgets/LessonDetailsInfo.dart
import 'package:flutter/material.dart';

class LessonDetailsInfo extends StatelessWidget {
  final String title;
  final String desc;

  const LessonDetailsInfo({super.key, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        Container(height: 4, width: 100, color: const Color(0xFFFF4D00)),
        const SizedBox(height: 10),
        Text(desc, style: TextStyle(fontSize: 20, color: Colors.grey.shade700)),
      ],
    );
  }
}