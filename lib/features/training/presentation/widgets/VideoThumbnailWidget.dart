import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailWidget extends StatelessWidget {
  final String url;
  const VideoThumbnailWidget({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: VideoThumbnail.thumbnailData(
        video: url,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 120, // زيادة العرض قليلاً لتحسين الوضوح
        quality: 50,
      ),
      builder: (context, snapshot) {
        // حالة النجاح
        if (snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              snapshot.data!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          );
        }
        // حالة الخطأ أو عدم وجود ملف
        else if (snapshot.hasError || (snapshot.connectionState == ConnectionState.done && snapshot.data == null)) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.videocam_off, color: Colors.grey),
          );
        }
        // حالة التحميل
        return const SizedBox(
          width: 60,
          height: 60,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}