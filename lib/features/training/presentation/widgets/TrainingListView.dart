// 1. القائمة التي تعرض الدروس
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/training_cubit.dart';
import '../screens/add_training_screen.dart';
import '../screens/training_details_screen.dart';

class TrainingListView extends StatelessWidget {
  final List items;
  const TrainingListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    itemCount: items.length,
    itemBuilder: (context, index) => TrainingCard(lesson: items[index], index: index),
  );
}

// 2. كارد الدرس الواحد (يشمل منطق الحذف والضغط)
class TrainingCard extends StatelessWidget {
  final dynamic lesson;
  final int index;
  const TrainingCard({super.key, required this.lesson, required this.index});

  @override
  Widget build(BuildContext context) => Dismissible(
    key: UniqueKey(),
    onDismissed: (_) => context.read<TrainingCubit>().deleteTraining(index),
    child: Card(
      child: ListTile(
        leading: Icon(lesson.contentType == 'Video' ? Icons.play_circle : Icons.picture_as_pdf),
        title: Text(lesson.title),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrainingDetailsScreen(trainingItem: lesson))),
      ),
    ),
  );
}

// 3. زر الإضافة (FAB)
class AddContentFAB extends StatelessWidget {
  const AddContentFAB({super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(
      value: BlocProvider.of<TrainingCubit>(context),
      child: const AddTrainingScreen(),
    ))),
    label: const Text("إضافة محتوى"),
  );
}