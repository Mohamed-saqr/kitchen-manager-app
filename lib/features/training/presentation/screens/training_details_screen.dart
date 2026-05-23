import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'package:video_thumbnail/video_thumbnail.dart'; // 👈 للمكتبة الجديدة

import '../../models/TrainingModel.dart';

class TrainingDetailsScreen extends StatefulWidget {
  final TrainingModel trainingItem;
  const TrainingDetailsScreen({super.key, required this.trainingItem});

  @override
  State<TrainingDetailsScreen> createState() => _TrainingDetailsScreenState();
}

class _TrainingDetailsScreenState extends State<TrainingDetailsScreen> {
  String? _thumbnailPath;

  @override
  void initState() {
    super.initState();
    if (widget.trainingItem.contentType.toLowerCase() == 'video') {
      _generateThumbnail();
    }
  }

// تأكد أن الكود داخل الدالة يبدو كالتالي:
  Future<void> _generateThumbnail() async {
    try {
      final path = await VideoThumbnail.thumbnailFile(
        video: widget.trainingItem.url,
        imageFormat: ImageFormat.JPEG, // تأكد من كتابتها بهذا الشكل
        quality: 75,
      );
      if (mounted) setState(() => _thumbnailPath = path);
    } catch (e) {
      print("Thumbnail Error: $e");
    }
  }
  Future<void> _handleOpeningContent(BuildContext context) async {
    final String path = widget.trainingItem.url;
    try {
      if (path.startsWith('/') || path.contains('content://') || File(path).existsSync()) {
        final result = await OpenFilex.open(path);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("لا يمكن فتح الملف: ${result.message}")));
        }
      } else {
        final Uri url = Uri.parse(path);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw "لا يمكن فتح هذا الرابط";
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.trainingItem.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👈 التعديل هنا: عرض الـ Thumbnail إذا كان فيديو
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.trainingItem.contentType.toLowerCase() == 'video' && _thumbnailPath != null
                    ? Image.file(File(_thumbnailPath!), fit: BoxFit.cover)
                    : Icon(
                  widget.trainingItem.contentType == "Video" ? Icons.play_circle_fill : Icons.picture_as_pdf,
                  size: 80,
                  color: const Color(0xFFFF4D00),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(widget.trainingItem.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.trainingItem.desc, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () => _handleOpeningContent(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: widget.trainingItem.contentType.toLowerCase() == 'video'
                    ? const Icon(Icons.play_circle_fill, color: Colors.white)
                    : const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text(
                  "open_content".tr(args: [widget.trainingItem.contentType]),
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}