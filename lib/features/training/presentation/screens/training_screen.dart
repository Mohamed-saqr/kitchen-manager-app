import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart'; // 👈 الربط مع نظام الترجمة
import '../../logic/training_cubit.dart';
import '../../logic/training_state.dart';
import 'add_training_screen.dart';
import 'training_details_screen.dart';

class TrainingScreen extends StatelessWidget {
  final String userRole;

  const TrainingScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    // نستخدم BlocProvider لتوفير الـ Cubit
    return BlocProvider(
      create: (context) => TrainingCubit()..loadTrainingData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            "training_screen.title".tr(), // 👈 الترجمة
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: BlocBuilder<TrainingCubit, TrainingState>(
          builder: (context, state) {
            if (state is TrainingLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF4D00)),
              );
            }

            if (state is TrainingLoaded) {
              final items = state.trainings;

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.library_books_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "training_screen.no_data".tr(), // 👈 الترجمة
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final lesson = items[index];

                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    onDismissed: (direction) {
                      final deletedTitle = lesson.title;
                      context.read<TrainingCubit>().deleteTraining(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${"training_screen.deleted".tr()} $deletedTitle",
                          ), // 👈 الترجمة
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            lesson.contentType == 'Video'
                                ? Icons.play_circle_fill
                                : Icons.picture_as_pdf,
                            color: const Color(0xFFFF4D00),
                            size: 35,
                          ),
                        ),
                        title: Text(
                          lesson.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            lesson.desc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TrainingDetailsScreen(trainingItem: lesson),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }

            if (state is TrainingError) {
              return Center(child: Text(state.message));
            }

            return Center(
              child: Text("training_screen.start".tr()),
            ); // 👈 الترجمة
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              backgroundColor: const Color(0xFFFF4D00),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (newContext) => BlocProvider.value(
                      value: BlocProvider.of<TrainingCubit>(context),
                      child: const AddTrainingScreen(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                "training_screen.add_content".tr(), // 👈 الترجمة
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
