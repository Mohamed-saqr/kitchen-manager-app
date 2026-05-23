import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/chef_model.dart';

// 1. الحالات (States)
abstract class ChefState {}
class ChefInitial extends ChefState {}
class ChefLoading extends ChefState {}
class ChefLoaded extends ChefState {
  final List<ChefModel> chefs;
  ChefLoaded(this.chefs);
}

// 2. الـ Cubit
class ChefCubit extends Cubit<ChefState> {
  ChefCubit() : super(ChefInitial());

  void getChefs(int i) { // 1. لا نحتاج تمرير snapshot هنا، الـ Cubit سيجلبها بنفسه
    emit(ChefLoading());

    // 2. يجب استخدام listen للاستماع للتغيرات في قاعدة البيانات
    FirebaseFirestore.instance
        .collection('chefs')
        .limit(10)
        .snapshots()
        .listen((snapshot) { // 3. الـ snapshot تأتي من الـ listen

      final chefs = snapshot.docs
          .map((doc) => ChefModel.fromMap(doc.data(), doc.id))
          .toList();

      emit(ChefLoaded(chefs));
    }, onError: (error) {
      // يفضل دائماً إضافة معالجة للخطأ
      print("Error fetching chefs: $error");
    });
  }
}