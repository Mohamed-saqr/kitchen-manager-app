import 'package:hive/hive.dart';

// ✅ لازم السطر ده يكون موجود وبنفس اسم الملف بالظبط
part 'TrainingModel.g.dart';

@HiveType(typeId: 1)
class TrainingModel extends HiveObject {
  @HiveField(0) final String title;
  @HiveField(1) final String desc;
  @HiveField(2) final double progress;
  @HiveField(3) final String contentType;
  @HiveField(4) final String url;

  TrainingModel({
    required this.title,
    required this.desc,
    required this.progress,
    required this.contentType,
    required this.url,
  });
}