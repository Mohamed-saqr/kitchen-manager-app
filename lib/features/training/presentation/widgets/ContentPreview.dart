// 1. معاينة المحتوى (الصورة أو الأيقونة)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContentPreview extends StatelessWidget {
  final String type;
  const ContentPreview({super.key, required this.type});

  @override
  Widget build(BuildContext context) => Container(
    height: 200, width: double.infinity,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
    child: Icon(type == "Video" ? Icons.play_circle_fill : Icons.picture_as_pdf, size: 80, color: const Color(0xFFFF4D00)),
  );
}

// 2. معلومات النص
class ContentInfo extends StatelessWidget {
  final String title, desc;
  const ContentInfo({super.key, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text(desc, style: const TextStyle(fontSize: 16, color: Colors.grey)),
    ],
  );
}

// 3. زر الفتح
class OpenContentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String type;
  const OpenContentButton({super.key, required this.onPressed, required this.type});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 60,
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.open_in_new, color: Colors.white),
      label: Text("فتح $type", style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4D00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
    ),
  );
}