import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../models/TrainingModel.dart';

class TrainingCard extends StatelessWidget {
  final TrainingModel item;
  final VoidCallback onTap;
  final Widget? thumbnail;

  const TrainingCard({
    super.key,
    required this.item,
    required this.onTap,
    this.thumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 5))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        // 👈 تحويل الكارد بالكامل لزرار تفاعلي
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ الجزء العلوي: غلاف الفيديو
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey.shade100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildThumbnail(),
                    Container(color: Colors.black.withOpacity(0.15)),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getContentIcon(item.contentType),
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // باقي تفاصيل الكارد
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.desc,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "${"progress".tr()}: ${(item.progress * 100).toInt()}%",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 5,
                      color: const Color(0xFFFF4D00),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    // تم حذف الـ ElevatedButton هنا لأن الكارد كله أصبح زرار 🚀
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (thumbnail != null) return thumbnail!;
    final type = item.contentType.toUpperCase();
    if (type == "VIDEO" && item.url.isNotEmpty) {
      return _VideoThumbnailWidget(videoUrl: item.url);
    }
    if ((type == "IMAGES" || type == "GALLERY") && item.url.isNotEmpty) {
      return item.url.startsWith('http')
          ? Image.network(item.url, fit: BoxFit.cover)
          : Image.file(File(item.url), fit: BoxFit.cover);
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade100, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  IconData _getContentIcon(String type) {
    switch (type.toUpperCase()) {
      case "PDF": return Icons.picture_as_pdf_rounded;
      case "VIDEO": return Icons.play_arrow_rounded;
      case "IMAGES":
      case "GALLERY": return Icons.image_rounded;
      default: return Icons.menu_book_rounded;
    }
  }
}

class _VideoThumbnailWidget extends StatelessWidget {
  final String videoUrl;
  const _VideoThumbnailWidget({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 75,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        }
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF4D00)),
          ),
        );
      },
    );
  }
}