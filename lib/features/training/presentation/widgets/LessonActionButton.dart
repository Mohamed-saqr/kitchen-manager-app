// انسخ هذا الملف في lib/features/training/presentation/widgets/LessonActionButton.dart
import 'package:flutter/material.dart';

class LessonActionButton extends StatelessWidget {
  final String contentType;
  final VoidCallback onPressed;

  const LessonActionButton({super.key, required this.contentType, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(contentType.toUpperCase() == "VIDEO" ? Icons.play_arrow : Icons.picture_as_pdf),
        label: const Text("تشغيل المحتوى"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4D00),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}