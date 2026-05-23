import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../models/TrainingModel.dart';
import 'training_state.dart';

class TrainingCubit extends Cubit<TrainingState> {
  TrainingCubit() : super(TrainingInitial());

  void loadTrainingData() {
    emit(TrainingLoading());
    try {
      final box = Hive.box<TrainingModel>('trainingBox');
      final data = box.values.toList();
      emit(TrainingLoaded(data));
    } catch (e) {
      emit(TrainingError("فيه مشكلة في تحميل الدروس: $e"));
    }
  }

  void addTraining(TrainingModel lesson) async {
    final box = Hive.box<TrainingModel>('trainingBox');
    await box.add(lesson);
    loadTrainingData();
  }

  // ✅ الدالة دي هي اللي ناقصة ومسببة الإيرور الأحمر
  void deleteTraining(int index) async {
    final box = Hive.box<TrainingModel>('trainingBox');

    // 1. بناخد نسخة من القائمة الحالية ونشيل منها العنصر فوراً
    if (state is TrainingLoaded) {
      final currentList = List<TrainingModel>.from((state as TrainingLoaded).trainings);
      currentList.removeAt(index);

      // 2. بنحدث الحالة فوراً بالقائمة الجديدة عشان الـ UI يفهم إنها نقصت
      emit(TrainingLoaded(currentList));
    }

    try {
      // 3. بنمسح من Hive في الخلفية
      await box.deleteAt(index);
    } catch (e) {
      // لو حصل مشكلة نرجع الداتا القديمة
      loadTrainingData();
      emit(TrainingError("فشل الحذف من قاعدة البيانات"));
    }
  }}