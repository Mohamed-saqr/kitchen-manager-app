import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocalizationCubit extends Cubit<String> {
  LocalizationCubit() : super('ar');

  Map<String, dynamic> _localizedValues = {};

  // تحميل ملفات الترجمة
  Future<void> loadTranslations() async {
    String jsonString = await rootBundle.loadString('assets/langs/${state}.json');
    _localizedValues = json.decode(jsonString);
    emit(state);
  }

  void toggleLanguage() {
    emit(state == 'ar' ? 'en' : 'ar');
    loadTranslations(); // إعادة تحميل الملف الجديد
  }

  // دالة لجلب النص
  String translate(String key) {
    List<String> keys = key.split('.');
    dynamic value = _localizedValues;
    for (String k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // في حال عدم العثور على المفتاح
      }
    }
    return value.toString();
  }
}